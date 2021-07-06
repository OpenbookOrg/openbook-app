import 'dart:async';
import 'dart:math';
import 'package:Okuna/models/community.dart';
import 'package:Okuna/models/post.dart';
import 'package:Okuna/models/top_post.dart';
import 'package:Okuna/models/top_posts_list.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/explore_timeline_preferences.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/navigation_service.dart';
import 'package:Okuna/services/user.dart';
import 'package:Okuna/widgets/icon.dart';
import 'package:Okuna/widgets/icon_button.dart';
import 'package:Okuna/widgets/post/post.dart';
import 'package:Okuna/widgets/posts_stream/posts_stream.dart';
import 'package:Okuna/widgets/theming/primary_accent_text.dart';
import 'package:flutter/material.dart';
import 'package:throttling/throttling.dart';

class OBTopPosts extends StatefulWidget {
  final OBTopPostsController? controller;
  final Function(ScrollPosition)? onScrollCallback;
  final double extraTopPadding;

  OBTopPosts({
    this.controller,
    this.onScrollCallback,
    this.extraTopPadding = 0.0,
  });

  @override
  State<StatefulWidget> createState() {
    return OBTopPostsState();
  }
}

class OBTopPostsState extends State<OBTopPosts>
    with AutomaticKeepAliveClientMixin {
  late UserService _userService;
  late LocalizationService _localizationService;
  late NavigationService _navigationService;
  late ExploreTimelinePreferencesService _exploreTimelinePreferencesService;
  late OBPostsStreamController _obPostsStreamController;
  StreamSubscription? _excludeJoinedCommunitiesChangeSubscription;

  late bool _needsBootstrap;
  late bool _excludeJoinedCommunitiesEnabled;
  List<TopPost> _currentTopPosts = [];
  List<Post>? _currentPosts;
  List<int> _excludedCommunities = [];
  int? _topPostLastViewedId;
  late Debouncing _storeLastViewedIdAndCachablePostsDebouncer;

  @override
  void initState() {
    super.initState();
    _needsBootstrap = true;
    _storeLastViewedIdAndCachablePostsDebouncer =
        new Debouncing(duration: Duration(milliseconds: 500));
    _obPostsStreamController = OBPostsStreamController();
    if (widget.controller != null) widget.controller!.attach(this);
  }

  @override
  void dispose() async {
    super.dispose();
    await _userService.setStoredTopPosts(_currentTopPosts);
    _excludeJoinedCommunitiesChangeSubscription?.cancel();
  }

  Future? refresh() {
    return _obPostsStreamController.refresh();
  }

  void scrollToTop() {
    _obPostsStreamController.scrollToTop();
  }

  @override
  Widget build(BuildContext context) {
    var openbookProvider = OpenbookProvider.of(context);
    _userService = openbookProvider.userService;
    _localizationService = openbookProvider.localizationService;
    _navigationService = openbookProvider.navigationService;
    _exploreTimelinePreferencesService =
        openbookProvider.exploreTimelinePreferencesService;

    if (_needsBootstrap) _bootstrap();
    if (!_needsBootstrap) {
      return OBPostsStream(
        streamIdentifier: 'explorePostsTab',
        refresher: _postsStreamRefresher,
        onScrollLoader: _postsStreamOnScrollLoader,
        controller: _obPostsStreamController,
        onScrollCallback: widget.onScrollCallback,
        refreshIndicatorDisplacement: 110.0,
        displayContext: OBPostDisplayContext.topPosts,
        initialPosts: _currentPosts,
        refreshOnCreate: _currentPosts == null,
        postBuilder: _topPostBuilder,
        prependedItems: <Widget>[
          Padding(
            padding: EdgeInsets.only(
                left: 20, right: 20, bottom: 10, top: widget.extraTopPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                OBPrimaryAccentText(_localizationService.post__top_posts_title,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                OBIconButton(
                  OBIcons.settings,
                  themeColor: OBIconThemeColor.primaryAccent,
                  onPressed: _onWantsToSeeTopPostSettings,
                )
              ],
            ),
          )
        ],
      );
    } else {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
  }

  void _bootstrap() async {
    _excludeJoinedCommunitiesEnabled = await _exploreTimelinePreferencesService
        .getExcludeJoinedCommunitiesSetting();

    _excludeJoinedCommunitiesChangeSubscription =
        _exploreTimelinePreferencesService.excludeJoinedCommunitiesSettingChange
            .listen(_onExcludeJoinedCommunitiesEnabledChanged);

    _topPostLastViewedId = await _userService.getStoredTopPostsLastViewedId();
    TopPostsList? topPostsList = await _userService.getStoredTopPosts();
    if (topPostsList.posts != null) {
      _currentTopPosts = topPostsList.posts!;
      List<Post> posts =
          topPostsList.posts!.map((topPost) => topPost.post!).toList();
      _currentPosts = posts;
    }

    Future.delayed(Duration(milliseconds: 0), () {
      setState(() {
        _needsBootstrap = false;
      });
    });
  }

  void _onExcludeJoinedCommunitiesEnabledChanged(
      bool excludeJoinedCommunitiesEnabled) {
    setState(() {
      _excludeJoinedCommunitiesEnabled = excludeJoinedCommunitiesEnabled;
    });
  }

  Widget _topPostBuilder(
      {BuildContext? context,
      Post? post,
      OBPostDisplayContext? displayContext,
      String? postIdentifier,
      ValueChanged<Post>? onPostDeleted}) {
    if (post == null || displayContext == null || postIdentifier == null || onPostDeleted == null) {
      return SizedBox();
    }

    if (post.community != null && _excludedCommunities.contains(post.community!.id)) {
      post.updateIsExcludedFromTopPosts(true);
    } else {
      post.updateIsExcludedFromTopPosts(false);
    }

    return OBPost(
      post,
      key: Key(postIdentifier),
      onPostDeleted: onPostDeleted,
      displayContext: displayContext,
      onPostIsInView: onPostIsInView,
      onCommunityExcluded: _onCommunityExcluded,
      onUndoCommunityExcluded: _onUndoCommunityExcluded,
      inViewId: postIdentifier,
    );
  }

  void onPostIsInView(Post post) async {
    _storeLastViewedIdAndCachablePostsDebouncer
        .debounce(() => _storeLastViewedIdAndCachedPosts(post));
  }

  void _storeLastViewedIdAndCachedPosts(Post post) async {
    List<TopPost> _cachablePosts = [];
    int indexTopPost = _currentTopPosts.indexWhere((topPost) {
      return topPost.post!.id == post.id;
    });
    int lastIndexTopPosts = _currentTopPosts.length - 1;
    int cacheFromIndex = 0;
    int cacheToIndex = min(indexTopPost + 2, lastIndexTopPosts);
    if (indexTopPost >= 4) cacheFromIndex = indexTopPost - 4;
    _cachablePosts = _currentTopPosts.sublist(cacheFromIndex, cacheToIndex);
    _userService.setTopPostsLastViewedId(post.id!);
    _userService.setStoredTopPosts(_cachablePosts);
  }

  void _onWantsToSeeTopPostSettings() async {
    bool excludeJoinedCommunitiesEnabled = _excludeJoinedCommunitiesEnabled;
    Future routePopFuture =
        _navigationService.navigateToTopPostsSettings(context: context);
    await routePopFuture;
    if (excludeJoinedCommunitiesEnabled != _excludeJoinedCommunitiesEnabled)
      refresh();
  }

  void _onCommunityExcluded(Community community) {
    _excludedCommunities.add(community.id!);
    _currentPosts?.forEach((post) {
      if (post.community?.id == community.id) {
        post.updateIsExcludedFromTopPosts(true);
      }
    });
  }

  void _onUndoCommunityExcluded(Community community) {
    _excludedCommunities.remove(community.id);
    _currentPosts?.forEach((post) {
      if (post.community?.id == community.id) {
        post.updateIsExcludedFromTopPosts(false);
      }
    });
  }

  Future<List<Post>> _postsStreamRefresher() async {
    List<TopPost> topPosts = (await _userService.getTopPosts(
            count: 10,
            excludeJoinedCommunities: _excludeJoinedCommunitiesEnabled))
        .posts ?? [];
    List<Post> posts = topPosts.map((topPost) => topPost.post!).toList();
    _setTopPosts(topPosts);
    _setPosts(posts);
    _clearExcludedCommunities();

    return posts;
  }

  Future<List<Post>> _postsStreamOnScrollLoader(List<Post> posts) async {
    TopPost lastTopPost = _currentTopPosts.last;
    int lastTopPostId = lastTopPost.id!;

    List<TopPost> moreTopPosts = (await _userService.getTopPosts(
            maxId: lastTopPostId,
            excludeJoinedCommunities: _excludeJoinedCommunitiesEnabled,
            count: 10))
        .posts ?? [];

    List<Post> morePosts = moreTopPosts.map((topPost) => topPost.post!).toList();

    _appendCurrentTopPosts(moreTopPosts);
    _appendCurrentPosts(morePosts);

    return morePosts;
  }

  void _clearExcludedCommunities() {
    setState(() {
      _excludedCommunities = [];
    });
  }

  void _setTopPosts(List<TopPost> posts) async {
    setState(() {
      _currentTopPosts = posts;
    });
  }

  void _setPosts(List<Post> posts) {
    setState(() {
      _currentPosts = posts;
    });
  }

  void _appendCurrentTopPosts(List<TopPost> posts) {
    List<TopPost> newPosts = _currentTopPosts + posts;
    _setTopPosts(newPosts);
  }

  void _appendCurrentPosts(List<Post> posts) {
    List<Post> newPosts = (_currentPosts ?? []) + posts;
    setState(() {
      _currentPosts = newPosts;
    });
  }

  @override
  bool get wantKeepAlive => true;
}

class OBTopPostsController {
  OBTopPostsState? _state;

  void attach(OBTopPostsState? state) {
    _state = state;
  }

  Future<void>? refresh() {
    return _state?.refresh();
  }

  void scrollToTop() {
    _state?.scrollToTop();
  }
}
