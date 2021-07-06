import 'dart:async';
import 'package:Okuna/models/post.dart';
import 'package:Okuna/models/trending_post.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/user.dart';
import 'package:Okuna/widgets/post/post.dart';
import 'package:Okuna/widgets/posts_stream/posts_stream.dart';
import 'package:Okuna/widgets/theming/highlighted_box.dart';
import 'package:Okuna/widgets/theming/primary_accent_text.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:async/async.dart';
import 'package:flutter/material.dart';

class OBTrendingPosts extends StatefulWidget {
  final OBTrendingPostsController? controller;
  final Function(ScrollPosition)? onScrollCallback;
  final double extraTopPadding;

  const OBTrendingPosts({
    this.controller,
    this.onScrollCallback,
    this.extraTopPadding = 0.0,
  });

  @override
  State<StatefulWidget> createState() {
    return OBTrendingPostsState();
  }
}

class OBTrendingPostsState extends State<OBTrendingPosts>
    with AutomaticKeepAliveClientMixin {
  late UserService _userService;
  late LocalizationService _localizationService;

  CancelableOperation? _getTrendingPostsOperation;

  late OBPostsStreamController _obPostsStreamController;
  List<TrendingPost> _currentTrendingPosts = [];
  late List<Post> _currentPosts = [];

  @override
  void initState() {
    super.initState();
    _obPostsStreamController = OBPostsStreamController();
    if (widget.controller != null) widget.controller!.attach(this);
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    super.dispose();
    if (_getTrendingPostsOperation != null) _getTrendingPostsOperation!.cancel();
  }

  Future? refresh() {
    return _obPostsStreamController.refreshPosts();
  }

  void scrollToTop() {
    _obPostsStreamController.scrollToTop();
  }

  @override
  Widget build(BuildContext context) {
    var openbookProvider = OpenbookProvider.of(context);
    _userService = openbookProvider.userService;
    _localizationService = openbookProvider.localizationService;

    return OBPostsStream(
      onScrollLoadMoreLimit: 20,
      onScrollLoadMoreLimitLoadMoreText:
          _localizationService.post__trending_posts_load_more,
      streamIdentifier: 'trendingPosts',
      refresher: _postsStreamRefresher,
      onScrollLoader: _postsStreamOnScrollLoader,
      controller: _obPostsStreamController,
      postBuilder: _trendingPostBuilder,
      onScrollCallback: widget.onScrollCallback,
      refreshIndicatorDisplacement: 110.0,
      prependedItems: <Widget>[
        Padding(
          padding: EdgeInsets.only(
              left: 20, right: 20, bottom: 10, top: widget.extraTopPadding),
          child: OBPrimaryAccentText(
              _localizationService.post__trending_posts_title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
        )
      ],
    );
  }

  Future<List<Post>> _postsStreamRefresher() async {
    List<TrendingPost> trendingPosts =
        (await _userService.getTrendingPosts(count: 10)).posts ?? [];
    List<Post> posts =
        trendingPosts.map((trendingPost) => trendingPost.post!).toList();

    _setTrendingPosts(trendingPosts);
    _setPosts(posts);

    return posts;
  }

  Future<List<Post>> _postsStreamOnScrollLoader(List<Post> posts) async {
    TrendingPost lastTrendingPost = _currentTrendingPosts.last;
    int lastTrendingPostId = lastTrendingPost.id!;

    List<TrendingPost> moreTrendingPosts = (await _userService.getTrendingPosts(
            maxId: lastTrendingPostId, count: 10))
        .posts ?? [];

    List<Post> morePosts =
        moreTrendingPosts.map((trendingPost) => trendingPost.post!).toList();

    _appendCurrentTrendingPosts(moreTrendingPosts);
    _appendCurrentPosts(morePosts);

    return morePosts;
  }

  Widget _trendingPostBuilder(
      {BuildContext? context,
      Post? post,
      OBPostDisplayContext? displayContext,
      String? postIdentifier,
      ValueChanged<Post>? onPostDeleted}) {

    if (context == null || post == null || displayContext == null || postIdentifier == null || onPostDeleted == null) {
      // TODO: very ugly, should probably refactor
      return SizedBox();
    }

    return OBPost(
      post,
      key: Key(postIdentifier),
      onPostDeleted: onPostDeleted,
      displayContext: displayContext,
      inViewId: postIdentifier,
    );
  }

  void _setTrendingPosts(List<TrendingPost> posts) async {
    setState(() {
      _currentTrendingPosts = posts;
    });
  }

  void _setPosts(List<Post> posts) {
    setState(() {
      _currentPosts = posts;
    });
  }

  void _appendCurrentTrendingPosts(List<TrendingPost> posts) {
    List<TrendingPost> newPosts = _currentTrendingPosts + posts;
    _setTrendingPosts(newPosts);
  }

  void _appendCurrentPosts(List<Post> posts) {
    List<Post> newPosts = _currentPosts + posts;
    setState(() {
      _currentPosts = newPosts;
    });
  }
}

class OBTrendingPostsController {
  OBTrendingPostsState? _state;

  void attach(OBTrendingPostsState? state) {
    _state = state;
  }

  Future<void>? refresh() {
    return _state?.refresh();
  }

  void scrollToTop() {
    _state?.scrollToTop();
  }
}
