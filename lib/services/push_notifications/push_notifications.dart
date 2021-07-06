import 'dart:convert';
import 'dart:io';

import 'package:Okuna/models/device.dart';
import 'package:Okuna/models/push_notification.dart';
import 'package:Okuna/models/user.dart';
import 'package:Okuna/services/storage.dart';
import 'package:Okuna/services/user.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:rxdart/rxdart.dart';

class PushNotificationsService {
  static const String oneSignalAppId = '66074bf4-9943-4504-a011-531c2635698b';

  late UserService _userService;

  Stream<PushNotification> get pushNotification =>
      _pushNotificationSubject.stream;
  final _pushNotificationSubject = PublishSubject<PushNotification>();

  Stream<PushNotificationOpenedResult> get pushNotificationOpened =>
      _pushNotificationOpenedSubject.stream;
  final _pushNotificationOpenedSubject =
      PublishSubject<PushNotificationOpenedResult>();

  late OBStorage _pushNotificationsStorage;
  static const String promptedUserForPermissionsStorageKey = 'promptedUser';

  void setStorageService(StorageService storageService) {
    _pushNotificationsStorage = storageService.getSystemPreferencesStorage(
        namespace: 'pushNotificationsService');
  }

  void bootstrap() async {
    await OneSignal.shared.setAppId(oneSignalAppId);
    // Deprecated, not sure if we need it.
    // await OneSignal.shared
    //     .setInFocusDisplayType(OSNotificationDisplayType.notification);
    await OneSignal.shared.setLocationShared(false);
    OneSignal.shared.setNotificationWillShowInForegroundHandler(_onNotificationReceived);
    OneSignal.shared.setNotificationOpenedHandler(_onNotificationOpened);
    OneSignal.shared.setSubscriptionObserver(_onSubscriptionChanged);

    bool permissionGranted = await this._getPermissionsState();
    bool promptedBefore = await this.hasPromptedUserForPermission();

    if (!promptedBefore) {
      // Prompt
      permissionGranted = await this.promptUserForPushNotificationPermission();
    }

    if (permissionGranted) {
      // Subscribe
      bool isSubscribed = await this.isSubscribedToPushNotifications();
      if (isSubscribed) {
        debugLog(
            'Push notifications permissions were given and is already subscribed');
        _onSubscribedToPushNotifications();
      } else {
        if (promptedBefore) {
          debugLog(
              'Push notifications permissions were given and is unsubscribed');
          await unsubscribeFromPushNotifications();
        } else {
          debugLog(
              'Push notifications permissions were given and had not prompted before. Subscribing as default.');
          subscribeToPushNotifications();
        }
      }
    } else {
      // Unsubscribe
      debugLog('Push notifications permissions were not given');
      await unsubscribeFromPushNotifications();
    }
  }

  Future<bool> isSubscribedToPushNotifications() async {
    OSDeviceState? osDeviceState =
        await OneSignal.shared.getDeviceState();

    return osDeviceState?.subscribed ?? false;
  }

  Future subscribeToPushNotifications() async {
    bool permissionGranted = await this._getPermissionsState();

    if (permissionGranted) {
      throw new Exception(
          'Tried to subscribe to push notifications without push notification permission');
    }

    bool subscribed = await this._getSubscriptionState();

    if (subscribed) {
      debugLog(
          'Already subscribed to push notifications, not subscribing again');
      _onSubscribedToPushNotifications();
      return null;
    }

    debugLog('Subscribing to push notifications');
    return OneSignal.shared.disablePush(false);
  }

  Future unsubscribeFromPushNotifications() async {
    // This will trigger the _onUnsubscribedFromPushNotifications
    debugLog('Unsubscribing from push notifications');
    return OneSignal.shared.disablePush(true);
  }

  Future<bool> promptUserForPushNotificationPermission() async {
    if (Platform.isAndroid) {
      await this._setPromptedUserForPermission();
      return this._getPermissionsState();
    }
    await OneSignal.shared
        .promptUserForPushNotificationPermission(fallbackToSettings: true);
    return this._getPermissionsState();
  }

  void setUserService(UserService userService) {
    _userService = userService;
  }

  Future<bool> _getPermissionsState() async {
    OSDeviceState? subscriptionState =
        await this._getOneSignalState();
    return subscriptionState?.hasNotificationPermission ?? false;
  }

  Future<bool> _getSubscriptionState() async {
    OSDeviceState? subscriptionState =
        await this._getOneSignalState();
    return subscriptionState?.subscribed ?? false;
  }

  Future<OSDeviceState?> _getOneSignalState() {
    return OneSignal.shared.getDeviceState();
  }

  void _onNotificationReceived(OSNotificationReceivedEvent event) {
    debugLog('Notification received');
    OSNotification notification = event.notification;
    Map<String, dynamic> notificationData =
        _parseAdditionalData(notification.additionalData);
    PushNotification pushNotification =
        PushNotification.fromJson(notificationData);
    _pushNotificationSubject.add(pushNotification);
    event.complete(notification);
  }

  void _onNotificationOpened(OSNotificationOpenedResult result) {
    debugLog('Notification opened');
    OSNotification notification = result.notification;
    PushNotification pushNotification = _makePushNotification(notification);
    _pushNotificationOpenedSubject.add(PushNotificationOpenedResult(
        pushNotification: pushNotification, action: result.action));
  }

  void _onSubscriptionChanged(OSSubscriptionStateChanges changes) {
    OSSubscriptionState toState = changes.to;
    OSSubscriptionState fromState = changes.from;
    if (!fromState.subscribed && toState.subscribed) {
      // User just subscribed for notifications
      _onSubscribedToPushNotifications();
    } else if (fromState.subscribed && !toState.subscribed) {
      // User just unsubscribed for notifications
      _onUnsubscribedFromPushNotifications();
    }
  }

  Future _onSubscribedToPushNotifications() async {
    return _tagDeviceForPushNotifications();
  }

  Future _onUnsubscribedFromPushNotifications() async {
    await _untagDeviceFromPushNotifications();
  }

  Future _tagDeviceForPushNotifications() async {
    User loggedInUser = _userService.getLoggedInUser()!;
    Device currentDevice = await _userService.getOrCreateCurrentDevice();

    String userId = _makeUserId(loggedInUser);

    return Future.wait([
      OneSignal.shared.sendTag('user_id', userId),
      OneSignal.shared.sendTag('device_uuid', currentDevice.uuid),
    ]);
  }

  Future _untagDeviceFromPushNotifications() {
    return Future.wait([
      OneSignal.shared.deleteTag('user_id'),
      OneSignal.shared.deleteTag('device_uuid')
    ]);
  }

  String _makeUserId(User user) {
    var bytes = utf8.encode(user.uuid! + user.id.toString());
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  void dispose() {
    _pushNotificationSubject.close();
    _pushNotificationOpenedSubject.close();
  }

  PushNotification _makePushNotification(OSNotification notification) {
    Map<String, dynamic> notificationData =
        _parseAdditionalData(notification.additionalData);
    return PushNotification.fromJson(notificationData);
  }

  Map<String, dynamic> _parseAdditionalData(
      Map<dynamic, dynamic>? additionalData) {
    String jsonAdditionalData = json.encode(additionalData);
    return json.decode(jsonAdditionalData);
  }

  Future<bool> hasPromptedUserForPermission() async {
    if (Platform.isIOS) return (await this._getPermissionsState());

    return _getPromptedUserForPermission();
  }

  Future<bool> _getPromptedUserForPermission() async {
    return (await this
            ._pushNotificationsStorage
            .get(promptedUserForPermissionsStorageKey)) ==
        'true';
  }

  Future<void> _setPromptedUserForPermission() {
    return this
        ._pushNotificationsStorage
        .set(promptedUserForPermissionsStorageKey, 'true');
  }

  Future<void> clearPromptedUserForPermission() {
    debugPrint('Clearing prompted user for permission');
    return this
        ._pushNotificationsStorage
        .remove(promptedUserForPermissionsStorageKey);
  }

  void debugLog(String log) {
    debugPrint('OBPushNotificationsService: $log');
  }
}

class PushNotificationOpenedResult {
  final PushNotification? pushNotification;
  final OSNotificationAction? action;

  const PushNotificationOpenedResult({this.pushNotification, this.action});
}
