import 'package:Okuna/models/community.dart';
import 'package:Okuna/models/hashtag.dart';
import 'package:Okuna/models/theme.dart';
import 'package:Okuna/models/user.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/theme.dart';
import 'package:Okuna/services/theme_value_parser.dart';
import 'package:Okuna/widgets/icon.dart';
import 'package:Okuna/widgets/progress_indicator.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:Okuna/widgets/tiles/community_tile.dart';
import 'package:Okuna/widgets/tiles/hashtag_tile.dart';
import 'package:Okuna/widgets/tiles/user_tile.dart';
import 'package:flutter/material.dart';

class OBSearchResults extends StatefulWidget {
  final List<User> userResults;
  final List<Community> communityResults;
  final List<Hashtag> hashtagResults;
  final String searchQuery;
  final ValueChanged<User> onUserPressed;
  final ValueChanged<Community> onCommunityPressed;
  final ValueChanged<Hashtag> onHashtagPressed;
  final ValueChanged<OBUserSearchResultsTab> onTabSelectionChanged;
  final VoidCallback onScroll;
  final OBUserSearchResultsTab selectedTab;
  final bool userSearchInProgress;
  final bool communitySearchInProgress;
  final bool hashtagSearchInProgress;

  const OBSearchResults(
      {Key? key,
      required this.userResults,
      this.selectedTab = OBUserSearchResultsTab.users,
      required this.communityResults,
      required this.hashtagResults,
      this.userSearchInProgress = false,
      this.communitySearchInProgress = false,
      this.hashtagSearchInProgress = false,
      required this.searchQuery,
      required this.onUserPressed,
      required this.onScroll,
      required this.onCommunityPressed,
      required this.onHashtagPressed,
      required this.onTabSelectionChanged})
      : super(key: key);

  @override
  OBSearchResultsState createState() {
    return OBSearchResultsState();
  }
}

class OBSearchResultsState extends State<OBSearchResults>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late LocalizationService _localizationService;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    switch (widget.selectedTab) {
      case OBUserSearchResultsTab.users:
        _tabController.index = 0;
        break;
      case OBUserSearchResultsTab.communities:
        _tabController.index = 1;
        break;
      case OBUserSearchResultsTab.hashtags:
        _tabController.index = 2;
        break;
      default:
        throw 'Unhandled tab index';
    }

    _tabController.addListener(_onTabSelectionChanged);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.removeListener(_onTabSelectionChanged);
  }

  @override
  void didUpdateWidget(OBSearchResults oldWidget) {
    if (oldWidget.searchQuery != widget.searchQuery) {
      this._onSearchQueryChanged(widget.searchQuery);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    OpenbookProviderState openbookProvider = OpenbookProvider.of(context);
    ThemeService _themeService = openbookProvider.themeService;
    _localizationService = openbookProvider.localizationService;
    ThemeValueParserService _themeValueParser =
        openbookProvider.themeValueParserService;
    OBTheme theme = _themeService.getActiveTheme();

    Color tabIndicatorColor =
        _themeValueParser.parseGradient(theme.primaryAccentColor).colors[1];

    Color tabLabelColor = _themeValueParser.parseColor(theme.primaryTextColor);

    return Column(
      children: <Widget>[
        TabBar(
          controller: _tabController,
          tabs: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 5),
              child:
                  Tab(text: _localizationService.trans('user_search__users')),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 5),
              child: Tab(
                  text: _localizationService.trans('user_search__communities')),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 5),
              child: Tab(text: _localizationService.user_search__hashtags),
            )
          ],
          isScrollable: false,
          indicatorColor: tabIndicatorColor,
          labelColor: tabLabelColor,
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildUserResults(),
              _buildCommunityResults(),
              _buildHashtagResults()
            ],
          ),
        )
      ],
    );
  }

  Widget _buildUserResults() {
    return NotificationListener(
      onNotification: (ScrollNotification notification) {
        widget.onScroll();
        return true;
      },
      child: ListView.builder(
          padding: EdgeInsets.all(0),
          physics: const ClampingScrollPhysics(),
          itemCount: widget.userResults.length + 1,
          itemBuilder: (BuildContext context, int index) {
            if (index == widget.userResults.length) {
              String searchQuery = widget.searchQuery;
              if (widget.userSearchInProgress) {
                // Search in progress
                return ListTile(
                    leading: OBProgressIndicator(),
                    title: OBText(_localizationService
                        .user_search__searching_for(searchQuery)));
              } else if (widget.userResults.isEmpty) {
                // Results were empty
                return ListTile(
                    leading: OBIcon(OBIcons.sad),
                    title: OBText(_localizationService
                        .user_search__no_users_for(searchQuery)));
              } else {
                return SizedBox();
              }
            }

            User user = widget.userResults[index];

            return OBUserTile(
              user,
              onUserTilePressed: widget.onUserPressed,
            );
          }),
    );
  }

  Widget _buildCommunityResults() {
    return NotificationListener(
      onNotification: (ScrollNotification notification) {
        widget.onScroll();
        return true;
      },
      child: ListView.separated(
          separatorBuilder: (BuildContext context, int index) {
            return SizedBox(
              height: 10,
            );
          },
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          physics: const ClampingScrollPhysics(),
          itemCount: widget.communityResults.length + 1,
          itemBuilder: (BuildContext context, int index) {
            if (index == widget.communityResults.length) {
              String searchQuery = widget.searchQuery;
              if (widget.communitySearchInProgress) {
                // Search in progress
                return ListTile(
                    leading: OBProgressIndicator(),
                    title: OBText(_localizationService
                        .user_search__searching_for(searchQuery)));
              } else if (widget.communityResults.isEmpty) {
                // Results were empty
                return ListTile(
                    leading: OBIcon(OBIcons.sad),
                    title: OBText(_localizationService
                        .user_search__no_communities_for(searchQuery)));
              } else {
                return SizedBox();
              }
            }

            Community community = widget.communityResults[index];

            return OBCommunityTile(
              community,
              onCommunityTilePressed: widget.onCommunityPressed,
            );
          }),
    );
  }

  Widget _buildHashtagResults() {
    return NotificationListener(
      onNotification: (ScrollNotification notification) {
        widget.onScroll();
        return true;
      },
      child: ListView.builder(
          padding: const EdgeInsets.all(0),
          physics: const ClampingScrollPhysics(),
          itemCount: widget.hashtagResults.length + 1,
          itemBuilder: (BuildContext context, int index) {
            if (index == widget.hashtagResults.length) {
              String searchQuery = widget.searchQuery;
              if (widget.hashtagSearchInProgress) {
                // Search in progress
                return ListTile(
                    leading: OBProgressIndicator(),
                    title: OBText(_localizationService
                        .user_search__searching_for(searchQuery)));
              } else if (widget.hashtagResults.isEmpty) {
                // Results were empty
                return ListTile(
                    leading: OBIcon(OBIcons.sad),
                    title: OBText(_localizationService
                        .user_search__no_hashtags_for(searchQuery)));
              } else {
                return SizedBox();
              }
            }

            Hashtag hashtag = widget.hashtagResults[index];

            return OBHashtagTile(
              hashtag,
              key: Key(hashtag.name!),
              onHashtagTilePressed: widget.onHashtagPressed,
            );
          }),
    );
  }

  void _onTabSelectionChanged() {
    OBUserSearchResultsTab newSelection =
        OBUserSearchResultsTab.values[_tabController.previousIndex];
    widget.onTabSelectionChanged(newSelection);
  }

  void _onSearchQueryChanged(String searchQuery) {
    OBUserSearchResultsTab currentTab = _getCurrentTab();

    if (searchQuery.length <= 2) {
      if (searchQuery.startsWith('#') &&
          currentTab != OBUserSearchResultsTab.hashtags) {
        _setCurrentTab(OBUserSearchResultsTab.hashtags);
      } else if (searchQuery.startsWith('@') &&
          currentTab != OBUserSearchResultsTab.users) {
        _setCurrentTab(OBUserSearchResultsTab.users);
      } else if (searchQuery.startsWith('c/') &&
          currentTab != OBUserSearchResultsTab.communities) {
        _setCurrentTab(OBUserSearchResultsTab.communities);
      }
    }
  }

  void _setCurrentTab(OBUserSearchResultsTab tab) {
    int tabIndex = OBUserSearchResultsTab.values.indexOf(tab);
    setState(() {
      _tabController.index = tabIndex;
    });
  }

  OBUserSearchResultsTab _getCurrentTab() {
    return OBUserSearchResultsTab.values[_tabController.index];
  }
}

enum OBUserSearchResultsTab { users, communities, hashtags }
