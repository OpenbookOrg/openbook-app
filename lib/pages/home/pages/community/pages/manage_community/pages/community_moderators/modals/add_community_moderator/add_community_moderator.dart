import 'dart:async';

import 'package:Okuna/models/community.dart';
import 'package:Okuna/models/user.dart';
import 'package:Okuna/models/users_list.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/navigation_service.dart';
import 'package:Okuna/widgets/http_list.dart';
import 'package:Okuna/widgets/nav_bars/themed_nav_bar.dart';
import 'package:Okuna/widgets/page_scaffold.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/user.dart';
import 'package:Okuna/widgets/theming/primary_color_container.dart';
import 'package:Okuna/widgets/tiles/user_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OBAddCommunityModeratorModal extends StatefulWidget {
  final Community community;

  const OBAddCommunityModeratorModal({Key? key, required this.community})
      : super(key: key);

  @override
  State<OBAddCommunityModeratorModal> createState() {
    return OBAddCommunityModeratorModalState();
  }
}

class OBAddCommunityModeratorModalState
    extends State<OBAddCommunityModeratorModal> {
  late UserService _userService;
  late NavigationService _navigationService;
  late LocalizationService _localizationService;

  late bool _needsBootstrap;

  @override
  void initState() {
    super.initState();
    _needsBootstrap = true;
  }

  @override
  Widget build(BuildContext context) {
    if (_needsBootstrap) {
      var provider = OpenbookProvider.of(context);
      _userService = provider.userService;
      _navigationService = provider.navigationService;
      _localizationService = provider.localizationService;
      _needsBootstrap = false;
    }

    return OBCupertinoPageScaffold(
      navigationBar: OBThemedNavigationBar(
        title: _localizationService.community__add_moderator_title,
      ),
      child: OBPrimaryColorContainer(
        child: OBHttpList<User>(
          listItemBuilder: _buildCommunityMemberListItem,
          searchResultListItemBuilder: _buildCommunityMemberListItem,
          listRefresher: _refreshCommunityMembers,
          listOnScrollLoader: _loadMoreCommunityMembers,
          listSearcher: _searchCommunityMembers,
          resourceSingularName: _localizationService.community__member,
          resourcePluralName: _localizationService.community__member_plural,
        ),
      ),
    );
  }

  Widget _buildCommunityMemberListItem(BuildContext context, User user) {
    return OBUserTile(
      user,
      onUserTilePressed: _onWantsToAddNewModerator,
    );
  }

  Future<List<User>> _refreshCommunityMembers() async {
    UsersList communityMembers = await _userService
        .getMembersForCommunity(widget.community, exclude: [
      CommunityMembersExclusion.administrators,
      CommunityMembersExclusion.moderators
    ]);
    return communityMembers.users ?? [];
  }

  Future<List<User>> _loadMoreCommunityMembers(
      List<User> communityMembersList) async {
    var lastCommunityMember = communityMembersList.last;
    var lastCommunityMemberId = lastCommunityMember.id;
    var moreCommunityMembers = (await _userService.getMembersForCommunity(
            widget.community,
            maxId: lastCommunityMemberId,
            count: 20,
            exclude: [
          CommunityMembersExclusion.administrators,
          CommunityMembersExclusion.moderators
        ]))
        .users;
    return moreCommunityMembers ?? [];
  }

  Future<List<User>> _searchCommunityMembers(String query) async {
    UsersList results = await _userService.searchCommunityMembers(
        query: query,
        community: widget.community,
        exclude: [
          CommunityMembersExclusion.administrators,
          CommunityMembersExclusion.moderators
        ]);

    return results.users ?? [];
  }

  void _onWantsToAddNewModerator(User user) async {
    var addedCommunityModerator =
        await _navigationService.navigateToConfirmAddCommunityModerator(
            context: context, community: widget.community, user: user);

    if (addedCommunityModerator != null && addedCommunityModerator) {
      Navigator.of(context).pop(user);
    }
  }
}
