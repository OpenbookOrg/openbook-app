import 'dart:async';

import 'package:Okuna/models/community.dart';
import 'package:Okuna/models/user.dart';
import 'package:Okuna/models/users_list.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/navigation_service.dart';
import 'package:Okuna/widgets/buttons/actions/follow_button.dart';
import 'package:Okuna/widgets/http_list.dart';
import 'package:Okuna/widgets/nav_bars/themed_nav_bar.dart';
import 'package:Okuna/widgets/page_scaffold.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/user.dart';
import 'package:Okuna/widgets/theming/primary_color_container.dart';
import 'package:Okuna/widgets/tiles/user_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OBCommunityMembersPage extends StatefulWidget {
  final Community community;

  const OBCommunityMembersPage({Key? key, required this.community})
      : super(key: key);

  @override
  State<OBCommunityMembersPage> createState() {
    return OBCommunityMembersPageState();
  }
}

class OBCommunityMembersPageState extends State<OBCommunityMembersPage> {
  late UserService _userService;
  late NavigationService _navigationService;
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
      _navigationService = provider.navigationService;
      _localizationService = provider.localizationService;
      _needsBootstrap = false;
    }

    String title = widget.community.usersAdjective ?? _localizationService.community__community_members;
    String singularName = widget.community.userAdjective ?? _localizationService.community__member;
    String pluralName = widget.community.usersAdjective ?? _localizationService.community__member_plural;

    return OBCupertinoPageScaffold(
      navigationBar: OBThemedNavigationBar(
        title: title,
      ),
      child: OBPrimaryColorContainer(
        child: OBHttpList<User>(
          controller: _httpListController,
          listItemBuilder: _buildCommunityMemberListItem,
          searchResultListItemBuilder: _buildCommunityMemberListItem,
          listRefresher: _refreshCommunityMembers,
          listOnScrollLoader: _loadMoreCommunityMembers,
          listSearcher: _searchCommunityMembers,
          resourceSingularName: singularName.toLowerCase(),
          resourcePluralName: pluralName.toLowerCase(),
        ),
      ),
    );
  }

  Widget _buildCommunityMemberListItem(BuildContext context, User user) {
    bool isLoggedInUser = _userService.isLoggedInUser(user);

    return OBUserTile(user,
        onUserTilePressed: _onCommunityMemberListItemPressed,
        trailing: isLoggedInUser
            ? null
            : OBFollowButton(
                user,
                size: OBButtonSize.small,
                unfollowButtonType: OBButtonType.highlight,
              ));
  }

  void _onCommunityMemberListItemPressed(User communityMember) {
    _navigationService.navigateToUserProfile(
        user: communityMember, context: context);
  }

  Future<List<User>> _refreshCommunityMembers() async {
    UsersList communityMembers =
        await _userService.getMembersForCommunity(widget.community);
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
    ))
        .users;
    return moreCommunityMembers ?? [];
  }

  Future<List<User>> _searchCommunityMembers(String query) async {
    UsersList results = await _userService.searchCommunityMembers(
        query: query, community: widget.community);

    return results.users ?? [];
  }
}
