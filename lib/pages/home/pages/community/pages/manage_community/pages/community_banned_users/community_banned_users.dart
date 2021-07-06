import 'dart:async';

import 'package:Okuna/models/community.dart';
import 'package:Okuna/models/user.dart';
import 'package:Okuna/models/users_list.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/modal_service.dart';
import 'package:Okuna/services/navigation_service.dart';
import 'package:Okuna/services/toast.dart';
import 'package:Okuna/widgets/http_list.dart';
import 'package:Okuna/widgets/icon.dart';
import 'package:Okuna/widgets/icon_button.dart';
import 'package:Okuna/widgets/nav_bars/themed_nav_bar.dart';
import 'package:Okuna/widgets/page_scaffold.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/user.dart';
import 'package:Okuna/widgets/theming/primary_color_container.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:Okuna/widgets/tiles/user_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OBCommunityBannedUsersPage extends StatefulWidget {
  final Community community;

  const OBCommunityBannedUsersPage({Key? key, required this.community})
      : super(key: key);

  @override
  State<OBCommunityBannedUsersPage> createState() {
    return OBCommunityBannedUsersPageState();
  }
}

class OBCommunityBannedUsersPageState
    extends State<OBCommunityBannedUsersPage> {
  late UserService _userService;
  late ModalService _modalService;
  late NavigationService _navigationService;
  late ToastService _toastService;
  late LocalizationService _localizationService;

  late OBHttpListController _httpListController;
  late bool _needsBootstrap;

  @override
  void initState() {
    super.initState();
    _httpListController = OBHttpListController();
    _needsBootstrap = true;
  }

  @override
  Widget build(BuildContext context) {
    if (_needsBootstrap) {
      var provider = OpenbookProvider.of(context);
      _userService = provider.userService;
      _modalService = provider.modalService;
      _navigationService = provider.navigationService;
      _localizationService = provider.localizationService;
      _toastService = provider.toastService;
      _needsBootstrap = false;
    }

    return OBCupertinoPageScaffold(
      navigationBar: OBThemedNavigationBar(
        title: _localizationService.community__banned_users_title,
        trailing: OBIconButton(
          OBIcons.add,
          themeColor: OBIconThemeColor.primaryAccent,
          onPressed: _onWantsToAddNewBannedUser,
        ),
      ),
      child: OBPrimaryColorContainer(
        child: OBHttpList<User>(
          controller: _httpListController,
          listItemBuilder: _buildCommunityBannedUserListItem,
          searchResultListItemBuilder: _buildCommunityBannedUserListItem,
          listRefresher: _refreshCommunityBannedUsers,
          listOnScrollLoader: _loadMoreCommunityBannedUsers,
          listSearcher: _searchCommunityBannedUsers,
          resourceSingularName: _localizationService.community__banned_user_text,
          resourcePluralName: _localizationService.community__banned_users_text,
        ),
      ),
    );
  }

  Widget _buildCommunityBannedUserListItem(BuildContext context, User user) {
    bool isLoggedInUser = _userService.isLoggedInUser(user);

    return OBUserTile(
      user,
      onUserTilePressed: _onCommunityBannedUserListItemPressed,
      onUserTileDeleted:
          isLoggedInUser ? null : _onCommunityBannedUserListItemDeleted,
      trailing: isLoggedInUser
          ? OBText(
              _localizationService.community__user_you_text,
              style: TextStyle(fontWeight: FontWeight.bold),
            )
          : null,
    );
  }

  void _onCommunityBannedUserListItemPressed(User communityBannedUser) {
    _navigationService.navigateToUserProfile(
        user: communityBannedUser, context: context);
  }

  void _onCommunityBannedUserListItemDeleted(User communityBannedUser) async {
    try {
      await _userService.unbanCommunityUser(
          community: widget.community, user: communityBannedUser);
      _httpListController.removeListItem(communityBannedUser);
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
      _toastService.error(message: errorMessage ?? _localizationService.error__unknown_error, context: context);
    } else {
      _toastService.error(message: _localizationService.error__unknown_error, context: context);
      throw error;
    }
  }

  Future<List<User>> _refreshCommunityBannedUsers() async {
    UsersList communityBannedUsers =
        await _userService.getBannedUsersForCommunity(widget.community);
    return communityBannedUsers.users ?? [];
  }

  Future<List<User>> _loadMoreCommunityBannedUsers(
      List<User> communityBannedUsersList) async {
    var lastCommunityBannedUser = communityBannedUsersList.last;
    var lastCommunityBannedUserId = lastCommunityBannedUser.id;
    var moreCommunityBannedUsers =
        (await _userService.getBannedUsersForCommunity(
      widget.community,
      maxId: lastCommunityBannedUserId,
      count: 20,
    ))
            .users;
    return moreCommunityBannedUsers ?? [];
  }

  Future<List<User>> _searchCommunityBannedUsers(String query) async {
    UsersList results = await _userService.searchCommunityBannedUsers(
        query: query, community: widget.community);

    return results.users ?? [];
  }

  void _onWantsToAddNewBannedUser() async {
    User? addedCommunityBannedUser = await _modalService.openBanCommunityUser(
        context: context, community: widget.community);

    if (addedCommunityBannedUser != null) {
      _httpListController.insertListItem(addedCommunityBannedUser);
    }
  }
}
