import 'package:Okuna/models/communities_list.dart';
import 'package:Okuna/models/community.dart';
import 'package:Okuna/models/user.dart';
import 'package:Okuna/pages/home/pages/communities/widgets/my_communities/widgets/my_communities_group.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/navigation_service.dart';
import 'package:Okuna/services/user.dart';
import 'package:Okuna/widgets/alerts/button_alert.dart';
import 'package:Okuna/widgets/icon.dart';
import 'package:Okuna/widgets/tiles/community_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OBMyCommunities extends StatefulWidget {
  final ScrollController? scrollController;

  const OBMyCommunities({Key? key, this.scrollController}) : super(key: key);

  @override
  OBMyCommunitiesState createState() {
    return OBMyCommunitiesState();
  }
}

class OBMyCommunitiesState extends State<OBMyCommunities>
    with AutomaticKeepAliveClientMixin {
  late OBMyCommunitiesGroupController _favoriteCommunitiesGroupController;
  late OBMyCommunitiesGroupController _joinedCommunitiesGroupController;
  late OBMyCommunitiesGroupController _moderatedCommunitiesGroupController;
  late OBMyCommunitiesGroupController _administratedCommunitiesGroupController;
  late NavigationService _navigationService;
  late LocalizationService _localizationService;
  late UserService _userService;
  late bool _needsBootstrap;
  late bool _refreshInProgress;
  late GlobalKey<RefreshIndicatorState> _refreshIndicatorKey;

  @override
  void initState() {
    super.initState();
    _favoriteCommunitiesGroupController = OBMyCommunitiesGroupController();
    _joinedCommunitiesGroupController = OBMyCommunitiesGroupController();
    _moderatedCommunitiesGroupController = OBMyCommunitiesGroupController();
    _administratedCommunitiesGroupController = OBMyCommunitiesGroupController();
    _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
    _refreshInProgress = false;
    _needsBootstrap = true;
  }

  @override
  Widget build(BuildContext context) {
    if (_needsBootstrap) {
      OpenbookProviderState openbookProvider = OpenbookProvider.of(context);
      _navigationService = openbookProvider.navigationService;
      _userService = openbookProvider.userService;
      _localizationService = openbookProvider.localizationService;
      _needsBootstrap = false;
    }

    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: _refreshAllGroups,
      child: ListView(
          key: Key('myCommunities'),
          // Need always scrollable for pull to refresh to work
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(0),
          children: <Widget>[
            Column(
              children: <Widget>[
                OBMyCommunitiesGroup(
                  key: Key('FavoriteCommunitiesGroup'),
                  controller: _favoriteCommunitiesGroupController,
                  title: _localizationService.community__favorites_title,
                  groupName: _localizationService.community__favorite_communities,
                  groupItemName: _localizationService.community__favorite_community,
                  maxGroupListPreviewItems: 5,
                  communityGroupListSearcher: _searchFavoriteCommunities,
                  communitySearchResultListItemBuilder: _buildFavoriteCommunityListItem,
                  communityGroupListItemBuilder:
                      _buildFavoriteCommunityListItem,
                  communityGroupListRefresher: _refreshFavoriteCommunities,
                  communityGroupListOnScrollLoader:
                      _loadMoreFavoriteCommunities,
                ),
                OBMyCommunitiesGroup(
                    key: Key('AdministratedCommunitiesGroup'),
                    controller: _administratedCommunitiesGroupController,
                    title: _localizationService.community__administrated_title,
                    groupName: _localizationService.community__administrated_communities,
                    groupItemName: _localizationService.community__administrated_community,
                    maxGroupListPreviewItems: 5,
                    communityGroupListSearcher: _searchAdministratedCommunities,
                    communitySearchResultListItemBuilder: _buildAdministratedCommunityListItem,
                    communityGroupListItemBuilder:
                        _buildAdministratedCommunityListItem,
                    communityGroupListRefresher:
                        _refreshAdministratedCommunities,
                    communityGroupListOnScrollLoader:
                        _loadMoreAdministratedCommunities),
                OBMyCommunitiesGroup(
                  key: Key('ModeratedCommunitiesGroup'),
                  controller: _moderatedCommunitiesGroupController,
                  title: _localizationService.community__moderated_title,
                  groupName: _localizationService.community__moderated_communities,
                  groupItemName: _localizationService.community__moderated_community,
                  maxGroupListPreviewItems: 5,
                  communityGroupListSearcher: _searchModeratedCommunities,
                  communitySearchResultListItemBuilder: _buildModeratedCommunityListItem,
                  communityGroupListItemBuilder:
                      _buildModeratedCommunityListItem,
                  communityGroupListRefresher: _refreshModeratedCommunities,
                  communityGroupListOnScrollLoader:
                      _loadMoreModeratedCommunities,
                ),
                OBMyCommunitiesGroup(
                  key: Key('JoinedCommunitiesGroup'),
                  controller: _joinedCommunitiesGroupController,
                  title: _localizationService.community__joined_title,
                  groupName: _localizationService.community__joined_communities,
                  groupItemName: _localizationService.community__joined_community,
                  maxGroupListPreviewItems: 5,
                  communityGroupListSearcher: _searchJoinedCommunities,
                  communitySearchResultListItemBuilder: _buildJoinedCommunityListItem,
                  communityGroupListItemBuilder: _buildJoinedCommunityListItem,
                  communityGroupListRefresher: _refreshJoinedCommunities,
                  communityGroupListOnScrollLoader: _loadMoreJoinedCommunities,
                  noGroupItemsFallbackBuilder:
                      _buildNoJoinedCommunitiesFallback,
                )
              ],
            )
          ]),
    );
  }

  Future<List<Community>> _refreshJoinedCommunities() async {
    CommunitiesList joinedCommunitiesList =
        await _userService.getJoinedCommunities();
    return joinedCommunitiesList.communities ?? [];
  }

  Future<List<Community>> _loadMoreJoinedCommunities(
      List<Community> currentJoinedCommunities) async {
    int offset = currentJoinedCommunities.length;

    CommunitiesList moreJoinedCommunitiesList =
        await _userService.getJoinedCommunities(offset: offset);
    return moreJoinedCommunitiesList.communities ?? [];
  }

  Future<List<Community>> _refreshFavoriteCommunities() async {
    CommunitiesList favoriteCommunitiesList =
        await _userService.getFavoriteCommunities();
    return favoriteCommunitiesList.communities ?? [];
  }

  Future<List<Community>> _loadMoreFavoriteCommunities(
      List<Community> currentFavoriteCommunities) async {
    int offset = currentFavoriteCommunities.length;

    CommunitiesList moreFavoriteCommunitiesList =
        await _userService.getFavoriteCommunities(offset: offset);
    return moreFavoriteCommunitiesList.communities ?? [];
  }

  Future<List<Community>> _refreshAdministratedCommunities() async {
    CommunitiesList administratedCommunitiesList =
        await _userService.getAdministratedCommunities();
    return administratedCommunitiesList.communities ?? [];
  }

  Future<List<Community>> _loadMoreAdministratedCommunities(
      List<Community> currentAdministratedCommunities) async {
    int offset = currentAdministratedCommunities.length;

    CommunitiesList moreAdministratedCommunitiesList =
        await _userService.getAdministratedCommunities(offset: offset);
    return moreAdministratedCommunitiesList.communities ?? [];
  }

  Future<List<Community>> _refreshModeratedCommunities() async {
    CommunitiesList moderatedCommunitiesList =
        await _userService.getModeratedCommunities();
    return moderatedCommunitiesList.communities ?? [];
  }

  Future<List<Community>> _loadMoreModeratedCommunities(
      List<Community> currentModeratedCommunities) async {
    int offset = currentModeratedCommunities.length;

    CommunitiesList moreModeratedCommunitiesList =
        await _userService.getModeratedCommunities(offset: offset);
    return moreModeratedCommunitiesList.communities ?? [];
  }

  Widget _buildNoJoinedCommunitiesFallback(
      BuildContext context, OBMyCommunitiesGroupRetry retry) {
    return OBButtonAlert(
      text: _localizationService.community__join_communities_desc,
      onPressed: _refreshAllGroups,
      buttonText:_localizationService.community__refresh_text,
      buttonIcon: OBIcons.refresh,
      isLoading: _refreshInProgress,
      assetImage: 'assets/images/stickers/got-it.png',
      //isLoading: _refreshInProgress,
    );
  }

  Widget _buildJoinedCommunityListItem(
      BuildContext context, Community community) {
    return StreamBuilder(
      stream: community.updateSubject,
      initialData: community,
      builder: (BuildContext context, AsyncSnapshot<Community> snapshot) {
        Community latestCommunity = snapshot.data!;

        User loggedInUser = _userService.getLoggedInUser()!;
        return latestCommunity.isMember(loggedInUser)
            ? _buildCommunityListItem(community)
            : const SizedBox();
      },
    );
  }

  Widget _buildModeratedCommunityListItem(
      BuildContext context, Community community) {
    return StreamBuilder(
      stream: community.updateSubject,
      initialData: community,
      builder: (BuildContext context, AsyncSnapshot<Community> snapshot) {
        Community latestCommunity = snapshot.data!;

        User loggedInUser = _userService.getLoggedInUser()!;
        return latestCommunity.isModerator(loggedInUser)
            ? _buildCommunityListItem(community)
            : const SizedBox();
      },
    );
  }

  Widget _buildAdministratedCommunityListItem(
      BuildContext context, Community community) {
    return StreamBuilder(
      stream: community.updateSubject,
      initialData: community,
      builder: (BuildContext context, AsyncSnapshot<Community> snapshot) {
        Community latestCommunity = snapshot.data!;

        User loggedInUser = _userService.getLoggedInUser()!;
        return latestCommunity.isAdministrator(loggedInUser)
            ? _buildCommunityListItem(community)
            : const SizedBox();
      },
    );
  }

  Widget _buildFavoriteCommunityListItem(
      BuildContext context, Community community) {
    return StreamBuilder(
      initialData: community,
      stream: community.updateSubject,
      builder: (BuildContext context, AsyncSnapshot<Community> snapshot) {
        Community latestCommunity = snapshot.data!;

        return latestCommunity.isFavorite == true
            ? _buildCommunityListItem(community)
            : const SizedBox();
      },
    );
  }

  Future<List<Community>> _searchFavoriteCommunities(String query) async {
    CommunitiesList results = await _userService.searchFavoriteCommunities(query: query);

    return results.communities ?? [];
  }

  Future<List<Community>> _searchAdministratedCommunities(String query) async {
    CommunitiesList results = await _userService.searchAdministratedCommunities(query: query);

    return results.communities ?? [];
  }

  Future<List<Community>> _searchModeratedCommunities(String query) async {
    CommunitiesList results = await _userService.searchModeratedCommunities(query: query);

    return results.communities ?? [];
  }

  Future<List<Community>> _searchJoinedCommunities(String query) async {
    CommunitiesList results = await _userService.searchJoinedCommunities(query: query);

    return results.communities ?? [];
  }

  Widget _buildCommunityListItem(Community community) {
    return OBCommunityTile(
      community,
      size: OBCommunityTileSize.small,
      onCommunityTilePressed: _onCommunityPressed,
    );
  }

  void _onCommunityPressed(Community community) {
    _navigationService.navigateToCommunity(
        context: context, community: community);
  }

  Future<void> _refreshAllGroups() async {
    _setRefreshInProgress(true);
    try {
      await Future.wait([
        _favoriteCommunitiesGroupController.refresh(),
        _administratedCommunitiesGroupController.refresh(),
        _moderatedCommunitiesGroupController.refresh(),
        _joinedCommunitiesGroupController.refresh(),
      ]);
    } finally {
      _setRefreshInProgress(false);
    }
  }

  void _setRefreshInProgress(bool refreshInProgress) {
    setState(() {
      _refreshInProgress = refreshInProgress;
    });
  }

  @override
  bool get wantKeepAlive => true;
}
