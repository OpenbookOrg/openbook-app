import 'package:Okuna/libs/str_utils.dart';
import 'package:Okuna/models/user_invite.dart';
import 'package:Okuna/pages/home/pages/menu/pages/user_invites/widgets/user_invite_tile.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/httpie.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/navigation_service.dart';
import 'package:Okuna/services/toast.dart';
import 'package:Okuna/widgets/http_list.dart';
import 'package:Okuna/widgets/icon.dart';
import 'package:Okuna/widgets/theming/secondary_text.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:async/async.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OBMyInvitesGroup extends StatefulWidget {
  final OBHttpListRefresher<UserInvite> inviteGroupListRefresher;
  final OBHttpListSearcher<UserInvite> inviteListSearcher;
  final void Function(BuildContext, UserInvite) inviteGroupListItemDeleteCallback;
  final OBHttpListOnScrollLoader<UserInvite> inviteGroupListOnScrollLoader;
  final OBMyInvitesGroupFallbackBuilder? noGroupItemsFallbackBuilder;
  final OBMyInvitesGroupController? controller;
  final String groupItemName;
  final String groupName;
  final int maxGroupListPreviewItems;
  final String title;

  const OBMyInvitesGroup({
    Key? key,
    required this.inviteGroupListRefresher,
    required this.inviteGroupListOnScrollLoader,
    required this.groupItemName,
    required this.inviteListSearcher,
    required this.groupName,
    required this.title,
    required this.maxGroupListPreviewItems,
    required this.inviteGroupListItemDeleteCallback,
    this.noGroupItemsFallbackBuilder,
    this.controller,
  }) : super(key: key);

  @override
  OBMyInvitesGroupState createState() {
    return OBMyInvitesGroupState();
  }
}

class OBMyInvitesGroupState extends State<OBMyInvitesGroup> {
  late bool _needsBootstrap;
  late ToastService _toastService;
  late NavigationService _navigationService;
  late LocalizationService _localizationService;
  late List<UserInvite> _inviteGroupList;
  late bool _refreshInProgress;
  CancelableOperation? _refreshOperation;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) widget.controller!.attach(this);
    _needsBootstrap = true;
    _inviteGroupList = [];
    _refreshInProgress = false;
  }

  @override
  Widget build(BuildContext context) {
    if (_needsBootstrap) {
      var openbookProvider = OpenbookProvider.of(context);
      _toastService = openbookProvider.toastService;
      _navigationService = openbookProvider.navigationService;
      _localizationService = openbookProvider.localizationService;
      _bootstrap();
      _needsBootstrap = false;
    }

    int listItemCount =
    _inviteGroupList.length < widget.maxGroupListPreviewItems
        ? _inviteGroupList.length
        : widget.maxGroupListPreviewItems;

    if (listItemCount == 0) {
      if (widget.noGroupItemsFallbackBuilder != null && !_refreshInProgress) {
        return widget.noGroupItemsFallbackBuilder!(
            context, _refreshInvites);
      }
      return const SizedBox();
    }

    List<Widget> columnItems = [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: OBText(
          widget.title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
      ),
      ListView.separated(
          key: Key(widget.groupName + 'invitesGroup'),
          physics: const NeverScrollableScrollPhysics(),
          separatorBuilder: _buildInviteSeparator,
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
          shrinkWrap: true,
          itemCount: listItemCount,
          itemBuilder: _buildGroupListPreviewItem),
    ];

    if (_inviteGroupList.length > widget.maxGroupListPreviewItems) {
      columnItems.add(_buildSeeAllButton());
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: columnItems,
    );
  }

  @override
  void dispose() {
    super.dispose();
    if (widget.controller != null) widget.controller!.detach();
    if (_refreshOperation != null) _refreshOperation!.cancel();
  }

  Widget _buildSeeAllButton() {
    return GestureDetector(
      onTap: _onWantsToSeeAll,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            OBSecondaryText(_localizationService.user__groups_see_all(widget.groupName),
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(
              width: 5,
            ),
            OBIcon(OBIcons.seeMore, themeColor: OBIconThemeColor.secondaryText)
          ],
        ),
      ),
    );
  }

  Widget _buildGroupListPreviewItem(BuildContext context, index) {
    UserInvite userInvite = _inviteGroupList[index];
    return _buildInviteTile(context, userInvite);
  }

  Widget _buildInviteTile(BuildContext context, UserInvite userInvite) {
    var onUserInviteDeletedCallback = () {
      _removeUserInvite(userInvite);
      widget.inviteGroupListItemDeleteCallback(context, userInvite);
      if (_inviteGroupList.length == 0) _refreshInvites();
    };

    return OBUserInviteTile(
      userInvite: userInvite,
      onUserInviteDeletedCallback: onUserInviteDeletedCallback,
    );
  }

  Widget _buildInviteSeparator(BuildContext context, int index) {
    return const SizedBox();
  }

  void _bootstrap() {
    _refreshInvites();
  }

  void _removeUserInvite(UserInvite userInvite) {
    setState(() {
      _inviteGroupList.remove(userInvite);
    });
  }

  Future<void> _refreshInvites() async {
    if (_refreshOperation != null) _refreshOperation!.cancel();
    _setRefreshInProgress(true);
    try {
      _refreshOperation =
          CancelableOperation.fromFuture(widget.inviteGroupListRefresher());

      List<UserInvite> groupInvites = await _refreshOperation!.value;

      _setUserInviteGroupList(groupInvites);
    } catch (error) {
      _onError(error);
    } finally {
      _refreshOperation = null;
      _setRefreshInProgress(false);
    }
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

  void _onWantsToSeeAll() {
    _navigationService.navigateToBlankPageWithWidget(
        context: context,
        key: Key('obMyUserInvitesGroup' + widget.groupItemName),
        navBarTitle: toCapital(widget.groupName),
        widget: _buildSeeAllGroupItemsPage());
  }

  Widget _buildSeeAllGroupItemsPage() {
    return Column(
      children: <Widget>[
        Expanded(
            child: OBHttpList<UserInvite>(
                  separatorBuilder: _buildInviteSeparator,
                  listSearcher: widget.inviteListSearcher,
                  searchResultListItemBuilder: _buildInviteTile,
                  listItemBuilder: _buildInviteTile,
                  listRefresher: widget.inviteGroupListRefresher,
                  listOnScrollLoader: widget.inviteGroupListOnScrollLoader,
                  resourcePluralName: widget.groupName,
                  resourceSingularName: widget.groupItemName
              ),
            ),
      ],
    );
  }

  void _setUserInviteGroupList(List<UserInvite> invites) {
    setState(() {
      _inviteGroupList = invites;
    });
  }

  void _setRefreshInProgress(bool refreshInProgress) {
    setState(() {
      _refreshInProgress = refreshInProgress;
    });
  }
}

class OBMyInvitesGroupController {
  OBMyInvitesGroupState? _state;

  void attach(OBMyInvitesGroupState state) {
    this._state = state;
  }

  void detach() {
    this._state = null;
  }

  Future<void> refresh() {
    if (_state == null) return Future.value();
    return _state!._refreshInvites();
  }
}

typedef Future<void> OBMyInvitesGroupRetry();

typedef Widget OBMyInvitesGroupFallbackBuilder(
    BuildContext context, OBMyInvitesGroupRetry retry);
