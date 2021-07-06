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

class OBCommunityModeratorsPage extends StatefulWidget {
  final Community community;

  const OBCommunityModeratorsPage({Key? key, required this.community})
      : super(key: key);

  @override
  State<OBCommunityModeratorsPage> createState() {
    return OBCommunityModeratorsPageState();
  }
}

class OBCommunityModeratorsPageState
    extends State<OBCommunityModeratorsPage> {
  late UserService _userService;
  late ModalService _modalService;
  late NavigationService _navigationService;
  late LocalizationService _localizationService;
  late ToastService _toastService;

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
      _toastService = provider.toastService;
      _localizationService = provider.localizationService;
      _needsBootstrap = false;
    }

    return OBCupertinoPageScaffold(
      navigationBar: OBThemedNavigationBar(
        title: _localizationService.trans('community__moderators_title'),
        trailing: OBIconButton(
          OBIcons.add,
          themeColor: OBIconThemeColor.primaryAccent,
          onPressed: _onWantsToAddNewModerator,
        ),
      ),
      child: OBPrimaryColorContainer(
        child: OBHttpList<User>(
          controller: _httpListController,
          listItemBuilder: _buildCommunityModeratorListItem,
          searchResultListItemBuilder: _buildCommunityModeratorListItem,
          listRefresher: _refreshCommunityModerators,
          listOnScrollLoader: _loadMoreCommunityModerators,
          listSearcher: _searchCommunityModerators,
          resourceSingularName: _localizationService.trans('community__moderator_resource_name'),
          resourcePluralName: _localizationService.trans('community__moderators_resource_name'),
        ),
      ),
    );
  }

  Widget _buildCommunityModeratorListItem(BuildContext context, User user) {
    bool isLoggedInUser = _userService.isLoggedInUser(user);

    return OBUserTile(
      user,
      onUserTilePressed: _onCommunityModeratorListItemPressed,
      onUserTileDeleted:
          isLoggedInUser ? null : _onCommunityModeratorListItemDeleted,
      trailing: isLoggedInUser ? OBText(_localizationService.trans('community__moderators_you'),
        style: TextStyle(fontWeight: FontWeight.bold),) : null,
    );
  }

  void _onCommunityModeratorListItemPressed(User communityModerator) {
    _navigationService.navigateToUserProfile(
        user: communityModerator, context: context);
  }

  void _onCommunityModeratorListItemDeleted(
      User communityModerator) async {
    try {
      await _userService.removeCommunityModerator(
          community: widget.community, user: communityModerator);
      _httpListController.removeListItem(communityModerator);
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
      _toastService.error(message: errorMessage ?? _localizationService.trans('error__unknown_error'), context: context);
    } else {
      _toastService.error(message: _localizationService.trans('error__unknown_error'), context: context);
      throw error;
    }
  }

  Future<List<User>> _refreshCommunityModerators() async {
    UsersList communityModerators =
        await _userService.getModeratorsForCommunity(widget.community);
    return communityModerators.users ?? [];
  }

  Future<List<User>> _loadMoreCommunityModerators(
      List<User> communityModeratorsList) async {
    var lastCommunityModerator = communityModeratorsList.last;
    var lastCommunityModeratorId = lastCommunityModerator.id;
    var moreCommunityModerators =
        (await _userService.getModeratorsForCommunity(
      widget.community,
      maxId: lastCommunityModeratorId,
      count: 20,
    ))
            .users;
    return moreCommunityModerators ?? [];
  }

  Future<List<User>> _searchCommunityModerators(String query) async {
    UsersList results = await _userService.searchCommunityModerators(
        query: query, community: widget.community);

    return results.users ?? [];
  }

  void _onWantsToAddNewModerator() async {
    User? addedCommunityModerator =
        await _modalService.openAddCommunityModerator(
            context: context, community: widget.community);

    if (addedCommunityModerator != null) {
      _httpListController.insertListItem(addedCommunityModerator);
    }
  }
}

typedef Future<User> OnWantsToCreateCommunityModerator();
typedef Future<User> OnWantsToEditCommunityModerator(
    User communityModerator);
typedef void OnWantsToSeeCommunityModerator(User communityModerator);
