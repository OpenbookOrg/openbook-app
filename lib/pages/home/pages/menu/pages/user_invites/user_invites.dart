import 'package:Okuna/models/user.dart';
import 'package:Okuna/models/user_invite.dart';
import 'package:Okuna/models/user_invites_list.dart';
import 'package:Okuna/pages/home/pages/menu/pages/user_invites/widgets/my_invite_group.dart';
import 'package:Okuna/pages/home/pages/menu/pages/user_invites/widgets/user_invite_count.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/modal_service.dart';
import 'package:Okuna/widgets/alerts/button_alert.dart';
import 'package:Okuna/widgets/icon.dart';
import 'package:Okuna/widgets/icon_button.dart';
import 'package:Okuna/widgets/nav_bars/themed_nav_bar.dart';
import 'package:Okuna/widgets/page_scaffold.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/toast.dart';
import 'package:Okuna/services/user.dart';
import 'package:Okuna/widgets/theming/primary_color_container.dart';
import 'package:async/async.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Okuna/services/httpie.dart';

class OBUserInvitesPage extends StatefulWidget {
  @override
  State<OBUserInvitesPage> createState() {
    return OBUserInvitesPageState();
  }
}

class OBUserInvitesPageState extends State<OBUserInvitesPage> {
  late UserService _userService;
  late ToastService _toastService;
  late ModalService _modalService;
  late LocalizationService _localizationService;

  late User _user;
  late GlobalKey<RefreshIndicatorState> _refreshIndicatorKey;
  late ScrollController _userInvitesScrollController;
  late OBMyInvitesGroupController _acceptedInvitesGroupController;
  late OBMyInvitesGroupController _pendingInvitesGroupController;

  late bool _hasAcceptedInvites;
  late bool _hasPendingInvites;
  late bool _refreshInProgress;

  CancelableOperation? _refreshUserOperation;

  late bool _needsBootstrap;

  @override
  void initState() {
    super.initState();
    _userInvitesScrollController = ScrollController();
    _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
    _acceptedInvitesGroupController = OBMyInvitesGroupController();
    _pendingInvitesGroupController = OBMyInvitesGroupController();
    _hasAcceptedInvites = true;
    _hasPendingInvites = true;
    _needsBootstrap = true;
    _refreshInProgress = true;
  }

  @override
  void dispose() {
    super.dispose();
    if (_refreshUserOperation != null) _refreshUserOperation!.cancel();
  }

  @override
  Widget build(BuildContext context) {
    if (_needsBootstrap) {
      var provider = OpenbookProvider.of(context);
      _userService = provider.userService;
      _toastService = provider.toastService;
      _modalService = provider.modalService;
      _localizationService = provider.localizationService;
      _user = _userService.getLoggedInUser()!;
      _bootstrap();
      _needsBootstrap = false;
    }

    return OBCupertinoPageScaffold(
        backgroundColor: Color.fromARGB(0, 0, 0, 0),
        navigationBar: OBThemedNavigationBar(
          title: _localizationService.user__invites_title,
          trailing: Opacity(
            opacity: _user.inviteCount == 0 ? 0.5 : 1.0,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                OBUserInviteCount(
                  count: _user.inviteCount,
                ),
                const SizedBox(
                  width: 10,
                ),
                OBIconButton(
                  OBIcons.add,
                  themeColor: OBIconThemeColor.primaryAccent,
                  onPressed: _onWantsToCreateInvite,
                ),
              ],
            ),
          ),
        ),
        child: Stack(
          children: <Widget>[
            OBPrimaryColorContainer(
                child: Column(
              children: <Widget>[
               _hasAcceptedInvites || _hasPendingInvites
                            ? _buildInvitesList()
                            : _buildNoInvitesFallback()
                ],
              )
            ),
          ],
      ),
    );
  }

  Widget _buildInvitesList() {
    return Expanded(
        child: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _refreshInvites,
        child: ListView(
            key: Key('myUserInvites'),
            controller: _userInvitesScrollController,
            // Need always scrollable for pull to refresh to work
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(0),
            children: <Widget>[
              Column(
                children: <Widget>[
                  OBMyInvitesGroup(
                    key: Key('AcceptedInvitesGroup'),
                    controller: _acceptedInvitesGroupController,
                    title: _localizationService.user__invites_accepted_title,
                    groupName: _localizationService.user__invites_accepted_group_name,
                    groupItemName: _localizationService.user__invites_accepted_group_item_name,
                    maxGroupListPreviewItems: 5,
                    inviteListSearcher: _searchAcceptedUserInvites,
                    inviteGroupListItemDeleteCallback:
                        _onUserInviteDeletedCallback,
                    inviteGroupListRefresher: _refreshAcceptedInvites,
                    inviteGroupListOnScrollLoader: _loadMoreAcceptedInvites,
                  ),
                  OBMyInvitesGroup(
                    key: Key('PendingInvitesGroup'),
                    controller: _pendingInvitesGroupController,
                    title: _localizationService.user__invites_pending,
                    groupName: _localizationService.user__invites_pending_group_name,
                    groupItemName: _localizationService.user__invites_pending_group_item_name,
                    maxGroupListPreviewItems: 5,
                    inviteListSearcher: _searchPendingUserInvites,
                    inviteGroupListItemDeleteCallback:
                        _onUserInviteDeletedCallback,
                    inviteGroupListRefresher: _refreshPendingInvites,
                    inviteGroupListOnScrollLoader: _loadMorePendingInvites,
                  ),
                ],
              )
            ]
          ),
        )
    );
  }

  Widget _buildNoInvitesFallback() {
    bool hasInvites = _user.inviteCount != null && _user.inviteCount! > 0;

    String message = hasInvites
        ? _localizationService.user__invites_none_used
        : _localizationService.user__invites_none_left;

    String assetImage = hasInvites
        ? 'assets/images/stickers/perplexed-owl.png'
        : 'assets/images/stickers/owl-instructor.png';

    VoidCallback _onPressed = hasInvites
        ? _onWantsToCreateInvite
        : _refreshInvites;

    String buttonText = hasInvites
        ? _localizationService.user__invites_invite_a_friend
        : _localizationService.user__invites_refresh;

    return OBButtonAlert(
      text: message,
      onPressed: _onPressed,
      buttonText: buttonText,
      buttonIcon: hasInvites ? OBIcons.add : OBIcons.refresh,
      isLoading: _refreshInProgress,
      assetImage: assetImage,
    );
  }

  Widget? _onUserInviteDeletedCallback(
      BuildContext context, UserInvite userInvite) {
    setState(() {
      if (userInvite.createdUser == null) {
        _user.inviteCount = _user.inviteCount! + 1;
      }
    });
  }

  void _bootstrap() async {
    await _refreshInvites();
  }

  Future<void> _refreshInvites() async {
    _setRefreshInProgress(true);
    try {
      await Future.wait([
        _refreshUser(),
        _hasAcceptedInvites ?_acceptedInvitesGroupController.refresh() : _refreshAcceptedInvites(),
        _hasPendingInvites ? _pendingInvitesGroupController.refresh() : _refreshPendingInvites(),
      ]);
      _scrollToTop();
    } catch (error) {
      _onError(error);
    } finally {
      _setRefreshInProgress(false);
    }
  }

  Future<void> _refreshUser() async {
    if (_refreshUserOperation != null) _refreshUserOperation!.cancel();
    _refreshUserOperation =
        CancelableOperation.fromFuture(_userService.refreshUser());
    await _refreshUserOperation!.value;
    User refreshedUser = _userService.getLoggedInUser()!;
    setState(() {
      _user = refreshedUser;
    });
  }

  Future<List<UserInvite>> _refreshPendingInvites() async {
    UserInvitesList pendingInvitesList = await _userService.getUserInvites(
        status: UserInviteFilterByStatus.pending);
    _setHasPendingInvites(pendingInvitesList.invites?.isNotEmpty ?? false);
    return pendingInvitesList.invites ?? [];
  }

  Future<List<UserInvite>> _refreshAcceptedInvites() async {
    UserInvitesList acceptedInvitesList = await _userService.getUserInvites(
        status: UserInviteFilterByStatus.accepted);
    _setHasAcceptedInvites(acceptedInvitesList.invites?.isNotEmpty ?? false);
    return acceptedInvitesList.invites ?? [];
  }

  Future<List<UserInvite>> _loadMorePendingInvites(
      List<UserInvite> currentInviteList) async {
    int offset = currentInviteList.length;

    UserInvitesList morePendingInvites = await _userService.getUserInvites(
        offset: offset, status: UserInviteFilterByStatus.pending);
    return morePendingInvites.invites ?? [];
  }

  Future<List<UserInvite>> _loadMoreAcceptedInvites(
      List<UserInvite> currentInviteList) async {
    int offset = currentInviteList.length;

    UserInvitesList moreAcceptedInvites = await _userService.getUserInvites(
        offset: offset, status: UserInviteFilterByStatus.accepted);
    return moreAcceptedInvites.invites ?? [];
  }

  Future<List<UserInvite>> _searchPendingUserInvites(String query) async {
    UserInvitesList results = await _userService.searchUserInvites(
        query: query, status: UserInviteFilterByStatus.pending);
    return results.invites ?? [];
  }

  Future<List<UserInvite>> _searchAcceptedUserInvites(String query) async {
    UserInvitesList results = await _userService.searchUserInvites(
        query: query, status: UserInviteFilterByStatus.accepted);
    return results.invites ?? [];
  }

  void _onError(error) async {
    if (error is HttpieConnectionRefusedError) {
      _toastService.error(
          message: error.toHumanReadableMessage(), context: context);
    } else if (error is HttpieRequestError) {
      String? errorMessage = await error.toHumanReadableMessage();
      _toastService.error(message: errorMessage ?? _localizationService.error__unknown_error, context: context);
    } else {
      _toastService.error(message: _localizationService.error__unknown_error, context: context);
      throw error;
    }
  }

  void _onWantsToCreateInvite() async {
    if (_user.inviteCount == 0) {
      _showNoInvitesLeft();
      return;
    }
    UserInvite? createdUserInvite =
        await _modalService.openCreateUserInvite(context: context);
    if (createdUserInvite != null) {
      _onUserInviteCreated(createdUserInvite);
    }
  }

  void _showNoInvitesLeft() {
    _toastService.error(message: _localizationService.user__invites_none_left, context: context);
  }

  void _onUserInviteCreated(UserInvite createdUserInvite) {
    _refreshInvites();
    _scrollToTop();
  }

  void _scrollToTop() {
    if (_userInvitesScrollController.hasClients) {
      _userInvitesScrollController.animateTo(
        0.0,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 300),
      );
    }
  }

  void _setHasAcceptedInvites(bool hasAcceptedInvites) {
    setState(() {
      _hasAcceptedInvites = hasAcceptedInvites;
    });
  }

  void _setHasPendingInvites(bool hasPendingInvites) {
    setState(() {
      _hasPendingInvites = hasPendingInvites;
    });
  }

  void _setRefreshInProgress(bool refreshInProgress) {
    setState(() {
      _refreshInProgress = refreshInProgress;
    });
  }
}

typedef Future<UserInvite> OnWantsToCreateUserInvite();
typedef Future<UserInvite> OnWantsToEditUserInvite(UserInvite userInvite);
typedef void OnWantsToSeeUserInvite(UserInvite userInvite);
