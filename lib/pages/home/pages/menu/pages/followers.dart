import 'dart:async';

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

class OBFollowersPage extends StatefulWidget {
  @override
  State<OBFollowersPage> createState() {
    return OBFollowersPageState();
  }
}

class OBFollowersPageState extends State<OBFollowersPage> {
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

    return OBCupertinoPageScaffold(
      navigationBar: OBThemedNavigationBar(
        title: _localizationService.user__followers_title,
      ),
      child: OBPrimaryColorContainer(
        child: OBHttpList<User>(
          controller: _httpListController,
          listItemBuilder: _buildFollowerListItem,
          searchResultListItemBuilder: _buildFollowerListItem,
          listRefresher: _refreshFollowers,
          listOnScrollLoader: _loadMoreFollowers,
          listSearcher: _searchFollowers,
          resourceSingularName: _localizationService.user__follower_singular,
          resourcePluralName: _localizationService.user__follower_plural,
        ),
      ),
    );
  }

  Widget _buildFollowerListItem(BuildContext context, User user) {
    return OBUserTile(user,
        onUserTilePressed: _onFollowerListItemPressed,
        trailing: OBFollowButton(
          user,
          size: OBButtonSize.small,
          unfollowButtonType: OBButtonType.highlight,
        ));
  }

  void _onFollowerListItemPressed(User follower) {
    _navigationService.navigateToUserProfile(user: follower, context: context);
  }

  Future<List<User>> _refreshFollowers() async {
    UsersList followers = await _userService.getFollowers();
    return followers.users ?? [];
  }

  Future<List<User>> _loadMoreFollowers(List<User> followersList) async {
    var lastFollower = followersList.last;
    var lastFollowerId = lastFollower.id;
    var moreFollowers = (await _userService.getFollowers(
      maxId: lastFollowerId,
      count: 20,
    ))
        .users;
    return moreFollowers ?? [];
  }

  Future<List<User>> _searchFollowers(String query) async {
    UsersList results = await _userService.searchFollowers(query: query);

    return results.users ?? [];
  }
}
