import 'dart:async';

import 'package:Okuna/models/community.dart';
import 'package:Okuna/models/post.dart';
import 'package:Okuna/models/posts_list.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/httpie.dart';
import 'package:Okuna/services/toast.dart';
import 'package:Okuna/services/user.dart';
import 'package:Okuna/widgets/post/post.dart';
import 'package:Okuna/widgets/theming/secondary_text.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:Okuna/widgets/tiles/loading_indicator_tile.dart';
import 'package:Okuna/widgets/tiles/retry_tile.dart';
import 'package:async/async.dart';
import 'package:flutter/material.dart';

class OBCommunityClosedPosts extends StatefulWidget {
  final Community community;

  const OBCommunityClosedPosts({required this.community});

  @override
  OBCommunityClosedPostsState createState() {
    return OBCommunityClosedPostsState();
  }
}

class OBCommunityClosedPostsState extends State<OBCommunityClosedPosts> {
  late List<Post> _posts;
  late bool _needsBootstrap;
  late bool _isFirstLoad;
  late UserService _userService;
  late ToastService _toastService;
  late ScrollController _postsScrollController;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  late OBCommunityClosedPostsStatus _status;
  CancelableOperation? _postsRequest;

  @override
  void initState() {
    super.initState();
    _posts = [];
    _needsBootstrap = true;
    _isFirstLoad = true;
    _status = OBCommunityClosedPostsStatus.refreshingPosts;
    _postsScrollController = ScrollController();
    _postsScrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    super.dispose();
    _postsScrollController.removeListener(_onScroll);
  }

  @override
  Widget build(BuildContext context) {
    if (_needsBootstrap) {
      var provider = OpenbookProvider.of(context);
      _userService = provider.userService;
      _toastService = provider.toastService;
      _bootstrap();
      _needsBootstrap = false;
    }

    Widget timelinePostsWidget =
        _posts.isEmpty ? _buildLoadingState() : _buildClosedPosts();

    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: _refreshPosts,
      child: timelinePostsWidget,
    );
  }

  Widget _buildClosedPosts() {
    return ListView.builder(
        controller: _postsScrollController,
        cacheExtent: 30,
        padding: const EdgeInsets.all(0),
        itemCount: _posts.length,
        itemBuilder: _buildPostItem);
  }

  Widget _buildPostItem(BuildContext context, int index) {
    Post post = _posts[index];
    return StreamBuilder(
        stream: post.updateSubject,
        initialData: post,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          Post post = snapshot.data;

          OBPost postWidget = OBPost(
            post,
            onPostDeleted: _onPostDeleted,
            key: Key(
              post.id.toString(),
            ),
          );

          bool isLastItem = index == _posts.length - 1;

          if (isLastItem && _status != OBCommunityClosedPostsStatus.idle) {
            switch (_status) {
              case OBCommunityClosedPostsStatus.loadingMorePosts:
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    postWidget,
                    OBLoadingIndicatorTile(),
                  ],
                );
                break;
              case OBCommunityClosedPostsStatus.loadingMorePostsFailed:
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    postWidget,
                    OBRetryTile(
                      onWantsToRetry: _loadMorePosts,
                    ),
                  ],
                );
                break;
              case OBCommunityClosedPostsStatus.noMorePostsToLoad:
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    postWidget,
                    ListTile(
                      title: OBSecondaryText(
                        '🎉  All posts loaded',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                );
              default:
            }
          }

          return postWidget;
        });
  }

  Widget _buildLoadingState() {
    String loadingTitle;

    switch (_status) {
      case OBCommunityClosedPostsStatus.refreshingPosts:
        loadingTitle = 'Loading closed posts.';
        break;
      case OBCommunityClosedPostsStatus.noMorePostsToLoad:
        loadingTitle = 'No closed posts.';
        break;
      case OBCommunityClosedPostsStatus.loadingMorePostsFailed:
        loadingTitle = 'Could not load posts.';
        break;
      default:
        loadingTitle = 'Something\'s not right.';
    }

    List<Widget> loadingColumnItems = [
      OBText(
        loadingTitle,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18.0,
        ),
        textAlign: TextAlign.center,
      ),
    ];

    return SizedBox(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 200),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: loadingColumnItems,
          ),
        ),
      ),
    );
  }

  void scrollToTop() {
    if (_postsScrollController.hasClients) {
      if (_postsScrollController.offset == 0) {
        _refreshIndicatorKey.currentState?.show();
      }

      _postsScrollController.animateTo(
        0.0,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 300),
      );
    }
  }

  void _onScroll() {
    if (_status == OBCommunityClosedPostsStatus.loadingMorePosts ||
        _status == OBCommunityClosedPostsStatus.noMorePostsToLoad) return;
    if (_postsScrollController.position.pixels >
        _postsScrollController.position.maxScrollExtent * 0.1) {
      _loadMorePosts();
    }
  }

  void _cancelPreviousPostsRequest() {
    if (_postsRequest != null) {
      _postsRequest!.cancel();
      _postsRequest = null;
    }
  }

  Future _bootstrap() async {
    PostsList closedPosts =
        await _userService.getClosedPostsForCommunity(widget.community);
    if (closedPosts.posts != null) _setPosts(closedPosts.posts!);
    _refreshIndicatorKey.currentState?.show();
  }

  Future<void> _refreshPosts() async {
    _cancelPreviousPostsRequest();
    _setStatus(OBCommunityClosedPostsStatus.refreshingPosts);
    try {
      Future<PostsList> postsListFuture =
          _userService.getClosedPostsForCommunity(widget.community, count: 10);

      _postsRequest = CancelableOperation.fromFuture(postsListFuture);

      List<Post>? posts = (await postsListFuture).posts;

      if (_isFirstLoad) _isFirstLoad = false;

      if (posts?.length == 0) {
        _setStatus(OBCommunityClosedPostsStatus.noMorePostsToLoad);
      } else {
        _setStatus(OBCommunityClosedPostsStatus.idle);
      }
      _setPosts(posts ?? []);
    } catch (error) {
      _setStatus(OBCommunityClosedPostsStatus.loadingMorePostsFailed);
      _onError(error);
    } finally {
      _postsRequest = null;
    }
  }

  Future _loadMorePosts() async {
    if (_status == OBCommunityClosedPostsStatus.refreshingPosts ||
        _status == OBCommunityClosedPostsStatus.noMorePostsToLoad) return null;
    _cancelPreviousPostsRequest();
    _setStatus(OBCommunityClosedPostsStatus.loadingMorePosts);

    var lastPost = _posts.last;
    var lastPostId = lastPost.id;
    try {
      Future<PostsList> morePostsListFuture =
          _userService.getClosedPostsForCommunity(widget.community,
              maxId: lastPostId, count: 10);

      _postsRequest = CancelableOperation.fromFuture(morePostsListFuture);

      List<Post>? morePosts = (await morePostsListFuture).posts;

      if (morePosts?.length == 0) {
        _setStatus(OBCommunityClosedPostsStatus.noMorePostsToLoad);
      } else {
        _setStatus(OBCommunityClosedPostsStatus.idle);
        _addPosts(morePosts ?? []);
      }
    } catch (error) {
      _setStatus(OBCommunityClosedPostsStatus.loadingMorePostsFailed);
      _onError(error);
    } finally {
      _postsRequest = null;
    }
  }

  void _onPostDeleted(Post deletedPost) {
    setState(() {
      _posts.remove(deletedPost);
    });
  }

  void _onError(error) async {
    if (error is HttpieConnectionRefusedError) {
      _toastService.error(
          message: error.toHumanReadableMessage(), context: context);
    } else if (error is HttpieRequestError) {
      String? errorMessage = await error.toHumanReadableMessage();
      _toastService.error(message: errorMessage ?? 'Unknown error', context: context);
    } else {
      _toastService.error(message: 'Unknown error', context: context);
      throw error;
    }
  }

  void _setPosts(List<Post> posts) {
    setState(() {
      _posts = posts;
    });
  }

  void _addPosts(List<Post> posts) {
    setState(() {
      _posts.addAll(posts);
    });
  }

  void _setStatus(OBCommunityClosedPostsStatus status) {
    setState(() {
      _status = status;
    });
  }
}

enum OBCommunityClosedPostsStatus {
  refreshingPosts,
  loadingMorePosts,
  loadingMorePostsFailed,
  noMorePostsToLoad,
  idle
}
