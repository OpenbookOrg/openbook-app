import 'package:Okuna/models/category.dart';
import 'package:Okuna/models/communities_list.dart';
import 'package:Okuna/models/community.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/navigation_service.dart';
import 'package:Okuna/services/toast.dart';
import 'package:Okuna/services/user.dart';
import 'package:Okuna/widgets/alerts/button_alert.dart';
import 'package:Okuna/widgets/icon.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:Okuna/widgets/tiles/community_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OBTrendingCommunities extends StatefulWidget {
  final Category? category;
  final ScrollController? scrollController;

  const OBTrendingCommunities({Key? key, this.category, this.scrollController})
      : super(key: key);

  @override
  OBTrendingCommunitiesState createState() {
    return OBTrendingCommunitiesState();
  }
}

class OBTrendingCommunitiesState extends State<OBTrendingCommunities>
    with AutomaticKeepAliveClientMixin {
  late bool _needsBootstrap;
  late UserService _userService;
  late ToastService _toastService;
  late NavigationService _navigationService;
  late LocalizationService _localizationService;
  late List<Community> _trendingCommunities;
  late bool _refreshInProgress;
  late GlobalKey<RefreshIndicatorState> _refreshIndicatorKey;

  @override
  void initState() {
    super.initState();
    _needsBootstrap = true;
    _trendingCommunities = [];
    _refreshInProgress = false;
    _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  }

  @override
  Widget build(BuildContext context) {
    if (_needsBootstrap) {
      var openbookProvider = OpenbookProvider.of(context);
      _userService = openbookProvider.userService;
      _toastService = openbookProvider.toastService;
      _navigationService = openbookProvider.navigationService;
      _localizationService = openbookProvider.localizationService;
      _bootstrap();
      _needsBootstrap = false;
    }

    return RefreshIndicator(
      onRefresh: _refreshTrendingCommunities,
      key: _refreshIndicatorKey,
      displacement: 80,
      child: ListView(
        // BUG https://github.com/flutter/flutter/issues/22180
        //controller: widget.scrollController,
        padding: EdgeInsets.all(0),
        children: <Widget>[
          _trendingCommunities.isEmpty && !_refreshInProgress
              ? _buildNoTrendingCommunities()
              : _buildTrendingCommunities()
        ],
      ),
    );
  }

  Widget _buildNoTrendingCommunities() {
    return OBButtonAlert(
      text: _localizationService.community__trending_none_found,
      onPressed: _refreshTrendingCommunities,
      buttonText: _localizationService.community__trending_refresh,
      buttonIcon: OBIcons.refresh,
      assetImage: 'assets/images/stickers/perplexed-owl.png',
      isLoading: _refreshInProgress,
    );
  }

  Widget _buildTrendingCommunities() {
    bool hasCategory = widget.category != null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: OBText(
            hasCategory
                ? _localizationService
                    .community__trending_in_category(widget.category?.title ?? '')
                : _localizationService.community__trending_in_all,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
        ),
        ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            controller: widget.scrollController,
            separatorBuilder: _buildCommunitySeparator,
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
            shrinkWrap: true,
            itemCount: _trendingCommunities.length,
            itemBuilder: _buildCommunity)
      ],
    );
  }

  Widget _buildCommunity(BuildContext context, index) {
    Community community = _trendingCommunities[index];
    return OBCommunityTile(
      community,
      key: Key(community.name!),
      onCommunityTilePressed: _onTrendingCommunityPressed,
    );
  }

  Widget _buildCommunitySeparator(BuildContext context, int index) {
    return const SizedBox(
      height: 10,
    );
  }

  void _bootstrap() {
    Future.delayed(
        Duration(
          milliseconds: 0,
        ), () {
      if (_refreshIndicatorKey.currentState != null) {
        _refreshIndicatorKey.currentState!.show();
      }
    });
  }

  Future<void> _refreshTrendingCommunities() async {
    debugPrint('Refreshing trending communities');
    _setRefreshInProgress(true);
    try {
      CommunitiesList trendingCommunitiesList =
          await _userService.getTrendingCommunities(category: widget.category);
      _setTrendingCommunities(trendingCommunitiesList.communities ?? []);
    } catch (error) {
      _onError(error);
    } finally {
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
      _toastService.error(
          message: _localizationService.error__unknown_error, context: context);
      throw error;
    }
  }

  void _onTrendingCommunityPressed(Community community) {
    _navigationService.navigateToCommunity(
        community: community, context: context);
  }

  void _setTrendingCommunities(List<Community> communities) {
    setState(() {
      _trendingCommunities = communities;
    });
  }

  void _setRefreshInProgress(bool refreshInProgress) {
    setState(() {
      _refreshInProgress = refreshInProgress;
    });
  }

  @override
  bool get wantKeepAlive => true;
}
