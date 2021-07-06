import 'dart:async';

import 'package:Okuna/models/communities_list.dart';
import 'package:Okuna/models/community.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/navigation_service.dart';
import 'package:Okuna/services/toast.dart';
import 'package:Okuna/widgets/http_list.dart';
import 'package:Okuna/widgets/nav_bars/themed_nav_bar.dart';
import 'package:Okuna/widgets/page_scaffold.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/user.dart';
import 'package:Okuna/widgets/theming/primary_color_container.dart';
import 'package:Okuna/widgets/tiles/community_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OBTopPostsExcludedCommunitiesPage extends StatefulWidget {
  @override
  State<OBTopPostsExcludedCommunitiesPage> createState() {
    return OBTopPostsExcludedCommunitiesState();
  }
}

class OBTopPostsExcludedCommunitiesState extends State<OBTopPostsExcludedCommunitiesPage> {
  late UserService _userService;
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
      _navigationService = provider.navigationService;
      _localizationService = provider.localizationService;
      _toastService = provider.toastService;
      _needsBootstrap = false;
    }

    return OBCupertinoPageScaffold(
      navigationBar: OBThemedNavigationBar(
        title: _localizationService.community__top_posts_excluded_communities,
      ),
      child: OBPrimaryColorContainer(
        child: OBHttpList<Community>(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          controller: _httpListController,
          listItemBuilder: _buildExcludedCommunityListItem,
          searchResultListItemBuilder: _buildExcludedCommunityListItem,
          listRefresher: _refreshExcludedCommunities,
          listOnScrollLoader: _loadMoreExcludedCommunities,
          listSearcher: _searchExcludedCommunities,
          resourceSingularName: _localizationService.community__excluded_community,
          resourcePluralName: _localizationService.community__excluded_communities,
        ),
      ),
    );
  }

  Widget _buildExcludedCommunityListItem(BuildContext context, Community community) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: OBCommunityTile(
        community,
        size: OBCommunityTileSize.small,
        onCommunityTilePressed: _onExcludedCommunityListItemPressed,
        onCommunityTileDeleted: _onExcludedCommunityListItemDeleted,
      ),
    );
  }

  void _onExcludedCommunityListItemPressed(Community community) {
    _navigationService.navigateToCommunity(
        community: community, context: context);
  }

  void _onExcludedCommunityListItemDeleted(Community excludedCommunity) async {
    try {
      await _userService.undoExcludeCommunityFromTopPosts(excludedCommunity);
      _httpListController.removeListItem(excludedCommunity);
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

  Future<List<Community>> _refreshExcludedCommunities() async {
    CommunitiesList excludedCommunities = await _userService.getTopPostsExcludedCommunities();
    return excludedCommunities.communities ?? [];
  }

  Future<List<Community>> _loadMoreExcludedCommunities(List<Community> excludedCommunitiesList) async {
    var lastExcludedCommunity = excludedCommunitiesList.last;
    var lastExcludedCommunityId = lastExcludedCommunity.id;
    var moreExcludedCommunities = (await _userService.getTopPostsExcludedCommunities(
      offset: lastExcludedCommunityId,
      count: 10,
    )).communities;

    return moreExcludedCommunities ?? [];
  }

  Future<List<Community>> _searchExcludedCommunities(String query) async {
    CommunitiesList results = await _userService.searchTopPostsExcludedCommunities(query: query);

    return results.communities ?? [];
  }
}
