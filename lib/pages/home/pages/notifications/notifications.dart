import 'dart:async';

import 'package:Okuna/models/notifications/notification.dart';
import 'package:Okuna/models/notifications/notifications_list.dart';
import 'package:Okuna/models/push_notification.dart';
import 'package:Okuna/models/theme.dart';
import 'package:Okuna/pages/home/lib/poppable_page_controller.dart';
import 'package:Okuna/pages/home/pages/notifications/pages/general_notifications.dart';
import 'package:Okuna/pages/home/pages/notifications/pages/request_notifications.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/navigation_service.dart';
import 'package:Okuna/services/push_notifications/push_notifications.dart';
import 'package:Okuna/services/theme.dart';
import 'package:Okuna/services/theme_value_parser.dart';
import 'package:Okuna/services/toast.dart';
import 'package:Okuna/services/user.dart';
import 'package:Okuna/widgets/badges/badge.dart';
import 'package:Okuna/widgets/http_list.dart';
import 'package:Okuna/widgets/icon.dart';
import 'package:Okuna/widgets/icon_button.dart';
import 'package:Okuna/widgets/nav_bars/themed_nav_bar.dart';
import 'package:Okuna/widgets/theming/primary_color_container.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:Okuna/widgets/tiles/notification_tile/notification_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:async/async.dart';

class OBNotificationsPage extends StatefulWidget {
  final OBNotificationsPageController? controller;
  final OBNotificationsPageTab selectedTab;

  OBNotificationsPage(
      {this.controller, this.selectedTab = OBNotificationsPageTab.general});

  @override
  OBNotificationsPageState createState() {
    return OBNotificationsPageState();
  }
}

class OBNotificationsPageState extends State<OBNotificationsPage>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  static const List<NotificationType> _generalTypes = <NotificationType>[
    NotificationType.postReaction,
    NotificationType.postCommentReaction,
    NotificationType.postComment,
    NotificationType.postCommentReply,
    NotificationType.postUserMention,
    NotificationType.postCommentUserMention,
    NotificationType.connectionConfirmed,
    NotificationType.followRequestApproved,
    NotificationType.follow,
    NotificationType.communityNewPost,
    NotificationType.userNewPost
  ];

  static const List<NotificationType> _requestTypes = <NotificationType>[
    NotificationType.connectionRequest,
    NotificationType.communityInvite,
    NotificationType.followRequest,
  ];

  late UserService _userService;
  late ToastService _toastService;
  late NavigationService _navigationService;
  late LocalizationService _localizationService;
  late PushNotificationsService _pushNotificationsService;
  late OBHttpListController<OBNotification> _generalNotificationsListController;
  late OBHttpListController<OBNotification> _requestsNotificationsListController;
  late StreamSubscription _pushNotificationSubscription;
  late OBNotificationsPageController _controller;
  late TabController _tabController;

  CancelableOperation? _getUnreadGeneralNotificationsCountOperation;
  CancelableOperation? _getUnreadRequestNotificationsCountOperation;

  late bool _needsBootstrap;
  bool? _isActivePage;
  late int? _unreadRequestNotificationsCount;
  late int? _unreadGeneralNotificationsCount;

  // Should be the case when the page is visible to the user
  late bool _shouldMarkNotificationsAsRead;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    _generalNotificationsListController = OBHttpListController();
    _requestsNotificationsListController = OBHttpListController();
    _controller = widget.controller ?? OBNotificationsPageController();
    _controller.attach(state: this, context: context);

    _tabController = new TabController(length: 2, vsync: this);

    switch (widget.selectedTab) {
      case OBNotificationsPageTab.general:
        _tabController.index = 0;
        break;
      case OBNotificationsPageTab.requests:
        _tabController.index = 1;
        break;
      default:
        throw "Unhandled tab index: ${widget.selectedTab}";
    }

    _needsBootstrap = true;
    _unreadRequestNotificationsCount = 0;
    _unreadGeneralNotificationsCount = 0;
    _shouldMarkNotificationsAsRead = true;
    if (_isActivePage == null) _isActivePage = false;
  }

  @override
  Widget build(BuildContext context) {
    var openbookProvider = OpenbookProvider.of(context);

    if (_needsBootstrap) {
      _userService = openbookProvider.userService;
      _toastService = openbookProvider.toastService;
      _navigationService = openbookProvider.navigationService;
      _localizationService = openbookProvider.localizationService;
      _pushNotificationsService = openbookProvider.pushNotificationsService;
      _bootstrap();
      _needsBootstrap = false;
    }

    ThemeService themeService = openbookProvider.themeService;
    ThemeValueParserService themeValueParser =
        openbookProvider.themeValueParserService;
    OBTheme theme = themeService.getActiveTheme();

    Color tabIndicatorColor =
        themeValueParser.parseGradient(theme.primaryAccentColor).colors[1];
    Color tabLabelColor = themeValueParser.parseColor(theme.primaryTextColor);

    return CupertinoPageScaffold(
        navigationBar: OBThemedNavigationBar(
          title: 'Notifications',
          trailing: OBIconButton(
            OBIcons.settings,
            themeColor: OBIconThemeColor.primaryAccent,
            onPressed: _onWantsToConfigureNotifications,
          ),
        ),
        child: OBPrimaryColorContainer(
            child: Column(
          children: <Widget>[
            TabBar(
              controller: _tabController,
              tabs: <Widget>[
                Padding(
                    padding: EdgeInsets.symmetric(vertical: 5),
                    child: Tab(
                      child: Stack(
                        overflow: Overflow.visible,
                        children: <Widget>[
                          OBText(_localizationService
                              .notifications__tab_general()),
                          _unreadGeneralNotificationsCount != null &&
                                  _unreadGeneralNotificationsCount! > 0
                              ? Positioned(
                                  right: -15,
                                  child: OBBadge(
                                    size: 10,
                                  ),
                                )
                              : const SizedBox()
                        ],
                      ),
                    )),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: Tab(
                    child: Stack(
                      overflow: Overflow.visible,
                      children: <Widget>[
                        OBText(
                            _localizationService.notifications__tab_requests()),
                        _unreadRequestNotificationsCount != null &&
                                _unreadRequestNotificationsCount! > 0
                            ? Positioned(
                                right: -15,
                                child: OBBadge(
                                  size: 10,
                                ),
                              )
                            : const SizedBox()
                      ],
                    ),
                  ),
                ),
              ],
              isScrollable: false,
              indicatorColor: tabIndicatorColor,
              labelColor: tabLabelColor,
            ),
            Expanded(
                child: TabBarView(
              controller: _tabController,
              children: <Widget>[
                _buildGeneralNotifications(),
                _buildRequestNotifications(),
              ],
            ))
          ],
        )));
  }

  Widget _buildGeneralNotifications() {
    return OBGeneralNotifications(
      controller: _generalNotificationsListController,
      refresher: _refreshGeneralNotifications,
      onScrollLoader: _loadMoreGeneralNotifications,
      itemBuilder: _buildNotification,
      resourceSingularName: 'notification',
      resourcePluralName: 'notifications',
    );
  }

  Widget _buildRequestNotifications() {
    return OBRequestNotifications(
      controller: _requestsNotificationsListController,
      refresher: _refreshRequestNotifications,
      onScrollLoader: _loadMoreRequestNotifications,
      itemBuilder: _buildNotification,
      resourceSingularName: 'notification',
      resourcePluralName: 'notifications',
    );
  }

  void dispose() {
    super.dispose();

    if (_getUnreadGeneralNotificationsCountOperation != null)
      _getUnreadGeneralNotificationsCountOperation!.cancel();

    if (_getUnreadRequestNotificationsCountOperation != null)
      _getUnreadRequestNotificationsCountOperation!.cancel();

    WidgetsBinding.instance?.removeObserver(this);
    _pushNotificationSubscription.cancel();
  }

  void scrollToTop() {
    if (_tabController.index == 0)
      _generalNotificationsListController.scrollToTop();
    if (_tabController.index == 1)
      _requestsNotificationsListController.scrollToTop();
  }

  void setIsActivePage(bool isActivePage) {
    setState(() {
      _isActivePage = isActivePage;
    });
  }

  void setUnreadGeneralNotificationsCount(int count) {
    setState(() {
      _unreadGeneralNotificationsCount = count;
    });
  }

  void setUnreadRequestNotificationsCount(int count) {
    setState(() {
      _unreadRequestNotificationsCount = count;
    });
  }

  Widget _buildNotification(BuildContext context, OBNotification notification) {
    return OBNotificationTile(
      key: Key(notification.id.toString()),
      notification: notification,
      onNotificationTileDeleted: _onNotificationTileDeleted,
      onPressed: _markNotificationAsRead,
    );
  }

  Future<List<OBNotification>> _refreshGeneralNotifications() async {
    List<OBNotification> newNotifications =
        await _refreshNotifications(_generalTypes);
    await _refreshUnreadGeneralNotificationsCount();
    return newNotifications;
  }

  Future<List<OBNotification>> _refreshRequestNotifications() async {
    List<OBNotification> newNotifications =
        await _refreshNotifications(_requestTypes);
    await _refreshUnreadRequestNotificationsCount();
    return newNotifications;
  }

  Future<List<OBNotification>> _refreshNotifications(
      [List<NotificationType>? types]) async {
    await _readNotifications(types: types);

    NotificationsList notificationsList =
        await _userService.getNotifications(types: types);
    return notificationsList.notifications!;
  }

  Future _refreshUnreadGeneralNotificationsCount() async {
    _getUnreadGeneralNotificationsCountOperation =
        CancelableOperation.fromFuture(
            _userService.getUnreadNotificationsCount(types: _generalTypes));
    int unreadCount = await _getUnreadGeneralNotificationsCountOperation!.value;
    setUnreadGeneralNotificationsCount(unreadCount);
  }

  Future _refreshUnreadRequestNotificationsCount() async {
    _getUnreadRequestNotificationsCountOperation =
        CancelableOperation.fromFuture(
            _userService.getUnreadNotificationsCount(types: _requestTypes));
    int unreadCount = await _getUnreadRequestNotificationsCountOperation!.value;
    setUnreadRequestNotificationsCount(unreadCount);
  }

  Future _readNotifications({List<NotificationType>? types}) async {
    if (!_shouldMarkNotificationsAsRead) return;
    OBNotification firstItem;

    if (_tabController.index == 0 &&
        _generalNotificationsListController.hasItems()) {
      firstItem = _generalNotificationsListController.firstItem();
    } else if (_tabController.index == 1 &&
        _requestsNotificationsListController.hasItems()) {
      firstItem = _requestsNotificationsListController.firstItem();
    } else {
      return;
    }

    int maxId = firstItem.id!;
    await _userService.readNotifications(maxId: maxId, types: types);
  }

  Future<List<OBNotification>> _loadMoreGeneralNotifications(
      List<OBNotification> currentNotifications) async {
    return _loadMoreNotifications(currentNotifications, _generalTypes);
  }

  Future<List<OBNotification>> _loadMoreRequestNotifications(
      List<OBNotification> currentNotifications) async {
    return _loadMoreNotifications(currentNotifications, _requestTypes);
  }

  Future<List<OBNotification>> _loadMoreNotifications(
      List<OBNotification> currentNotifications,
      [List<NotificationType>? types]) async {
    OBNotification lastNotification = currentNotifications.last;
    int lastNotificationId = lastNotification.id!;
    NotificationsList moreNotifications = await _userService.getNotifications(
        maxId: lastNotificationId, types: types);
    return moreNotifications.notifications!;
  }

  void _onNotificationTileDeleted(OBNotification notification) async {
    await _deleteNotification(notification);
    _generalNotificationsListController.removeListItem(notification);
    _requestsNotificationsListController.removeListItem(notification);
  }

  Future _deleteNotification(OBNotification notification) async {
    try {
      await _userService.deleteNotification(notification);
    } catch (error) {
      _onError(error);
    }
  }

  void _onError(error) async {
    if (error is HttpieConnectionRefusedError) {
      _toastService.error(
          message: error.toHumanReadableMessage(), context: context);
    } else if (error is HttpieRequestError) {
      String? errorMessage = await error.toHumanReadableMessage();
      _toastService.error(message: errorMessage ?? 'Unknown error', context: context);
    } else {
      _toastService.error(message: 'Unknown error', context: context);
      throw error;
    }
  }

  void _onWantsToConfigureNotifications() {
    _navigationService.navigateToNotificationsSettings(context: context);
  }

  void _bootstrap() {
    _pushNotificationSubscription =
        _pushNotificationsService.pushNotification.listen(_onPushNotification);
    _refreshUnreadGeneralNotificationsCount();
    _refreshUnreadRequestNotificationsCount();
  }

  void _onPushNotification(PushNotification pushNotification) {
    bool isNavigating = _controller.canPop();

    if (_isActivePage == null || !_isActivePage! || isNavigating) {
      _triggerRefreshNotifications(shouldScrollToTop: true);
    } else {
      _showRefreshNotificationsToast();
    }
  }

  void _showRefreshNotificationsToast() {
    _toastService.info(
        duration: Duration(seconds: 2),
        message: '',
        child: Row(
          children: <Widget>[
            const OBIcon(
              OBIcons.arrowUpward,
              color: Colors.white,
              size: OBIconSize.small,
            ),
            const SizedBox(
              width: 10,
            ),
            const Text(
              'Load new notifications',
              style: TextStyle(color: Colors.white),
            )
          ],
          mainAxisSize: MainAxisSize.min,
        ),
        context: context,
        onDismissed: () {
          _triggerRefreshNotifications(
              shouldScrollToTop: true,
              shouldUseRefreshIndicator: true,
              shouldMarkNotificationsAsRead: true);
        });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      _triggerRefreshNotifications(
          shouldScrollToTop: true, shouldUseRefreshIndicator: _isActivePage ?? false);
    }
  }

  void _triggerRefreshNotifications({
    bool shouldScrollToTop = false,
    bool shouldUseRefreshIndicator = false,
    bool shouldMarkNotificationsAsRead = false,
  }) async {
    _setShouldMarkNotificationsAsRead(shouldMarkNotificationsAsRead);
    await _generalNotificationsListController.refresh(
        shouldScrollToTop: shouldScrollToTop,
        shouldUseRefreshIndicator: shouldUseRefreshIndicator);
    await _requestsNotificationsListController.refresh(
        shouldScrollToTop: shouldScrollToTop,
        shouldUseRefreshIndicator: shouldUseRefreshIndicator);
    _setShouldMarkNotificationsAsRead(true);
  }

  void _setShouldMarkNotificationsAsRead(bool shouldMarkNotificationsAsRead) {
    setState(() {
      _shouldMarkNotificationsAsRead = shouldMarkNotificationsAsRead;
    });
  }

  void _markNotificationAsRead(OBNotification notification) {
    try {
      _userService.readNotification(notification);
      notification.markNotificationAsRead();
      if (_generalTypes.contains(notification.type)) {
        setUnreadGeneralNotificationsCount(
            _unreadGeneralNotificationsCount! - 1);
      } else if (_requestTypes.contains(notification.type)) {
        setUnreadRequestNotificationsCount(
            _unreadRequestNotificationsCount! - 1);
      }
    } on HttpieRequestError {
      // Nothing
    } catch (error) {
      print(
          'Couldnt mark notification as read with error: ' + error.toString());
    }
  }
}

class OBNotificationsPageController extends PoppablePageController {
  OBNotificationsPageState? _state;
  bool? _markNotificationsAsRead;
  bool? _isActivePage;

  void attach(
      {required BuildContext context, OBNotificationsPageState? state}) {
    super.attach(context: context);
    _state = state;
    if (_markNotificationsAsRead != null)
      _state?._setShouldMarkNotificationsAsRead(_markNotificationsAsRead!);

    if (_isActivePage != null) _state?.setIsActivePage(_isActivePage!);
  }

  void scrollToTop() {
    _state?.scrollToTop();
  }

  void setIsActivePage(bool isActivePage) {
    if (_state != null) _state!.setIsActivePage(isActivePage);
    _isActivePage = isActivePage;
  }

  void setShouldMarkNotificationsAsRead(bool markNotificationsAsRead) {
    if (_state != null)
      _state!._setShouldMarkNotificationsAsRead(markNotificationsAsRead);

    _markNotificationsAsRead = markNotificationsAsRead;
  }
}

enum OBNotificationsPageTab { general, requests }
