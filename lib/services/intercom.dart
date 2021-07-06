import 'dart:convert';

import 'package:Okuna/models/user.dart';
import 'package:Okuna/services/user.dart';
import 'package:crypto/crypto.dart';
import 'package:meta/meta.dart';
import 'package:intercom_flutter/intercom_flutter.dart';

class IntercomService {
  late UserService _userService;

  late String iosApiKey;
  late String androidApiKey;
  late String appId;

  void setUserService(UserService userService) {
    _userService = userService;
  }

  void bootstrap(
      {required String iosApiKey,
      required String androidApiKey,
      required String appId}) async {
    this.iosApiKey = iosApiKey;
    this.androidApiKey = androidApiKey;
    this.appId = appId;
    await Intercom.initialize(appId,
        iosApiKey: iosApiKey, androidApiKey: androidApiKey);
  }

  Future displayMessenger() {
    return Intercom.displayMessenger();
  }

  Future enableIntercom() async {
    await disableIntercom();
    User? loggedInUser = _userService.getLoggedInUser();
    if (loggedInUser == null) throw 'Cannot enable intercom. Not logged in.';

    assert(loggedInUser.uuid != null && loggedInUser.id != null);

    String userId = _makeUserId(loggedInUser);
    return Intercom.registerIdentifiedUser(userId: userId);
  }

  Future disableIntercom() {
    return Intercom.logout();
  }

  String _makeUserId(User user) {
    var bytes = utf8.encode(user.uuid! + user.id.toString());
    var digest = sha256.convert(bytes);
    return digest.toString();
  }
}
