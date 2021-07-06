import 'dart:math';

import 'package:Okuna/models/post.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/httpie.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/theme.dart';
import 'package:Okuna/services/theme_value_parser.dart';
import 'package:Okuna/services/toast.dart';
import 'package:Okuna/widgets/buttons/stream_load_more_button.dart';
import 'package:Okuna/widgets/post/post.dart';
import 'package:Okuna/widgets/posts_stream/widgets/dr_hoo.dart';
import 'package:Okuna/widgets/theming/secondary_text.dart';
import 'package:Okuna/widgets/tiles/loading_indicator_tile.dart';
import 'package:Okuna/widgets/tiles/retry_tile.dart';
import 'package:flutter/material.dart';
import 'package:async/async.dart';
import 'package:inview_notifier_list/inview_notifier_list.dart';

var rng = new Random();

class OBPostsStream extends StatefulWidget {
  final List<Widget>? prependedItems;
  final OBPostsStreamRefresher refresher;
  final OBPostsStreamOnScrollLoader onScrollLoader;
  final ScrollController? scrollController;
  final OBPostsStreamController? controller;
  final List<Post>? initialPosts;
  final String streamIdentifier;
  final ValueChanged<List<Post>>? onPostsRefreshed;
  final bool refreshOnCreate;
  final OBPostsStreamSecondaryRefresher? secondaryRefresher;
  final OBPostsStreamStatusIndicatorBuilder? statusIndicatorBuilder;
  final OBPostDisplayContext displayContext;
  final OBPostsStreamPostBuilder? postBuilder;
  final Function(ScrollPosition)? onScrollCallback;
  final double refreshIndicatorDisplacement;
  final int? onScrollLoadMoreLimit;
  final String? onScrollLoadMoreLimitLoadMoreText;

  const OBPostsStream({
    Key? key,
    this.prependedItems,
    required this.refresher,
    required this.onScrollLoader,
    this.onScrollCallback,
    this.controller,
    this.initialPosts,
    required this.streamIdentifier,
    this.onPostsRefreshed,
    this.refreshOnCreate = true,
    this.refreshIndicatorDisplacement = 40.0,
    this.secondaryRefresher,
    this.postBuilder,
    this.statusIndicatorBuilder,
    this.onScrollLoadMoreLimit,
    this.onScrollLoadMoreLimitLoadMoreText,
    this.displayContext = OBPostDisplayContext.timelinePosts,
    this.scrollController,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return OBPostsStreamState();
  }
}

class OBPostsStreamState extends State<OBPostsStream>
    with SingleTickerProviderStateMixin {
  late List<Post> _posts;
  late bool _needsBootstrap;
  late ToastService _toastService;
  late LocalizationService _localizationService;
  late ThemeService _themeService;
  late ThemeValueParserService _themeValueParserService;
  late ScrollController _streamScrollController;

  late GlobalKey<RefreshIndicatorState> _refreshIndicatorKey;

  late OBPostsStreamStatus _status;

  CancelableOperation? _refreshOperation;
  CancelableOperation? _secondaryRefresherOperation;
  CancelableOperation? _loadMoreOperation;
  CancelableOperation? _cachePostsInStorage;

  late AnimationController _hideOverlayAnimationController;
  late Animation<double> _animation;
  bool _shouldHideStackedLoadingScreen = true;
  late bool _onScrollLoadMoreLimitRemoved;

  late String _streamUniqueIdentifier;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) widget.controller!.attach(this);
    _posts = widget.initialPosts != null ? widget.initialPosts!.toList() : [];
    if (_posts.isNotEmpty) _shouldHideStackedLoadingScreen = false;
    _needsBootstrap = true;
    _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
    _status = OBPostsStreamStatus.idle;
    _streamScrollController = widget.scrollController ?? ScrollController();
    _streamScrollController.addListener(_onScroll);
    _streamUniqueIdentifier =
        '${widget.streamIdentifier}_${rng.nextInt(1000).toString()}';

    _hideOverlayAnimationController = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    _animation = new Tween(begin: 1.0, end: 0.0)
        .animate(_hideOverlayAnimationController);
    _onScrollLoadMoreLimitRemoved = false;
    _animation.addStatusListener(_onAnimationStatusChanged);
  }

  @override
  void dispose() {
    super.dispose();
    _streamScrollController.removeListener(_onScroll);
    _secondaryRefresherOperation?.cancel();
    _refreshOperation?.cancel();
    _loadMoreOperation?.cancel();
    _cachePostsInStorage?.cancel();
  }

  void _bootstrap() {
    if (widget.refreshOnCreate) {
      _status = OBPostsStreamStatus.refreshing;
      Future.delayed(Duration(milliseconds: 100), () {
        _refresh();
      });
    }
    // Pretty darn ugly.... How can we do better?
    if (widget.displayContext == OBPostDisplayContext.topPosts &&
        _posts.isNotEmpty) {
      Future.delayed(Duration(milliseconds: 0), () {
        _scrollToBottom();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_needsBootstrap) {
      var provider = OpenbookProvider.of(context);
      _toastService = provider.toastService;
      _localizationService = provider.localizationService;
      _themeService = provider.themeService;
      _themeValueParserService = provider.themeValueParserService;
      _bootstrap();
      _needsBootstrap = false;
    }

    return RefreshIndicator(
      displacement: widget.refreshIndicatorDisplacement,
      key: _refreshIndicatorKey,
      onRefresh: _refreshPosts,
      child: _buildStream(),
    );
  }

  Widget _buildStream() {
    List<Widget> streamItems = [];
    bool hasPrependedItems =
        widget.prependedItems != null && widget.prependedItems!.isNotEmpty;
    if (hasPrependedItems) streamItems.addAll(widget.prependedItems!);

    if (_posts.isEmpty) {
      OBPostsStreamStatusIndicatorBuilder statusIndicatorBuilder =
          widget.statusIndicatorBuilder ?? defaultStatusIndicatorBuilder;

      streamItems.add(statusIndicatorBuilder(
        context: context,
        streamStatus: _status,
        streamRefresher: _refresh,
        streamPrependedItems: widget.prependedItems ?? [],
      ));
    } else {
      streamItems.addAll(_buildStreamPosts());
      if (_status != OBPostsStreamStatus.idle) {
        Widget? statusTile = _buildStatusTile();
        if (statusTile != null) {
          streamItems.add(statusTile);
        }
      }
    }

    return Stack(
      children: _getPostsStreamStackChildren(streamItems),
    );
  }

  List<Widget> _getPostsStreamStackChildren(List<Widget> streamItems) {
    var theme = _themeService.getActiveTheme();
    var primaryColor = _themeValueParserService.parseColor(theme.primaryColor);
    List<Widget> _stackChildren = [];

    _stackChildren.add(InViewNotifierList(
        key: Key(_streamUniqueIdentifier),
        padding: const EdgeInsets.all(0),
        controller: _streamScrollController,
        isInViewPortCondition: _checkTimelineItemIsInViewport,
        itemCount: streamItems.length,
        builder: (BuildContext context, int index) {
          return streamItems[index];
        }));

    if (!_shouldHideStackedLoadingScreen) {
      _stackChildren.add(Positioned(
        top: 0.0,
        left: 0.0,
        right: 0.0,
        bottom: 0,
        child: IgnorePointer(
            ignoring: true,
            child: FadeTransition(
              opacity: _animation,
              child: DecoratedBox(
                decoration: BoxDecoration(color: primaryColor),
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                  ),
                ),
              ),
            )),
      ));
    }
    return _stackChildren;
  }

  List<Widget> _buildStreamPosts() {
    OBPostsStreamPostBuilder postBuilder =
        widget.postBuilder ?? _defaultStreamPostBuilder;

    return _posts.map((Post post) {
      if (_posts.isNotEmpty && post.id == _posts.last.id) {
        _hideInitialPostsLoadingOverlay();
      }

      String postIdentifier = _makePostUniqueIdentifier(post);

      return postBuilder(
          context: context,
          post: post,
          postIdentifier: postIdentifier,
          displayContext: widget.displayContext,
          onPostDeleted: _onPostDeleted);
    }).toList();
  }

  Widget _defaultStreamPostBuilder({
    BuildContext? context,
    Post? post,
    OBPostDisplayContext? displayContext,
    String? postIdentifier,
    ValueChanged<Post>? onPostDeleted,
  }) {
    return OBPost(
      post!,
      key: Key(postIdentifier!),
      onPostDeleted: onPostDeleted!,
      inViewId: postIdentifier,
      displayContext: displayContext!,
    );
  }

  void _hideInitialPostsLoadingOverlay() {
    Future.delayed(Duration(milliseconds: 0),
        () => _hideOverlayAnimationController.forward());
  }

  Widget? _buildStatusTile() {
    Widget? statusTile;
    Key statusKey = Key('${_streamUniqueIdentifier}_status_tile');

    switch (_status) {
      case OBPostsStreamStatus.loadingMore:
        return Padding(
          key: statusKey,
          padding: const EdgeInsets.all(20),
          child: const OBLoadingIndicatorTile(),
        );
      case OBPostsStreamStatus.loadingMoreFailed:
        return OBRetryTile(
          key: statusKey,
          onWantsToRetry: _loadMorePosts,
        );
      case OBPostsStreamStatus.noMoreToLoad:
        return ListTile(
          key: statusKey,
          title: OBSecondaryText(
            _localizationService.posts_stream__status_tile_no_more_to_load,
            textAlign: TextAlign.center,
          ),
        );
      case OBPostsStreamStatus.onScrollLoadMoreLimitReached:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: OBStreamLoadMoreButton(
            onPressed: _removeOnScrollLoadMoreLimit,
            text: widget.onScrollLoadMoreLimitLoadMoreText,
            key: statusKey,
          ),
        );
      case OBPostsStreamStatus.empty:
        return ListTile(
          key: statusKey,
          title: OBSecondaryText(
            _localizationService.posts_stream__status_tile_empty,
            textAlign: TextAlign.center,
          ),
        );
      default:
    }

    return statusTile;
  }

  bool _checkTimelineItemIsInViewport(
    double deltaTop,
    double deltaBottom,
    double viewPortDimension,
  ) {
    return deltaTop < (0.5 * viewPortDimension) &&
        deltaBottom > (0.5 * viewPortDimension);
  }

  void _onAnimationStatusChanged(status) {
    if (status == AnimationStatus.completed) {
      setState(() {
        _shouldHideStackedLoadingScreen = true;
      });
    }
  }

  void _scrollToTop({bool skipRefresh = false}) {
    if (_streamScrollController.hasClients) {
      if (_streamScrollController.offset == 0 && !skipRefresh) {
        _refreshIndicatorKey.currentState?.show();
      }

      _streamScrollController.animateTo(
        0.0,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 300),
      );
    }
  }

  void _scrollToBottom() {
    var position = _streamScrollController.position.maxScrollExtent;
    _streamScrollController.jumpTo(position);
  }

  void _addPostToTop(Post post) {
    setState(() {
      this._posts.insert(0, post);
      if (this._status == OBPostsStreamStatus.empty)
        _setStatus(OBPostsStreamStatus.idle);
    });
  }

  void _onScroll() {
    if (widget.onScrollCallback != null && _shouldHideStackedLoadingScreen) {
      // trigger this callback only after loading overlay is hidden
      // so that its not registered as a manual scroll
      widget.onScrollCallback!(_streamScrollController.position);
    }

    if (_status == OBPostsStreamStatus.loadingMore ||
        _status == OBPostsStreamStatus.noMoreToLoad) return;

    if (_streamScrollController.position.pixels >
        _streamScrollController.position.maxScrollExtent * 0.1) {
      _loadMorePosts();
    }
  }

  void _ensureNoRefreshPostsInProgress() {
    if (_refreshOperation != null) {
      _refreshOperation!.cancel();
      _refreshOperation = null;
    }
  }

  void _ensureNoLoadMoreInProgress() {
    if (_loadMoreOperation != null) {
      _loadMoreOperation!.cancel();
      _loadMoreOperation = null;
    }
  }

  Future? _refresh() {
    return _refreshIndicatorKey.currentState?.show();
  }

  Future<void> _refreshPosts() async {
    debugLog('Refreshing posts');
    _ensureNoRefreshPostsInProgress();
    _setStatus(OBPostsStreamStatus.refreshing);
    _onScrollLoadMoreLimitRemoved = false;
    try {
      _refreshOperation = CancelableOperation.fromFuture(widget.refresher());

      List<Future> refreshFutures = [_refreshOperation!.value];

      if (widget.secondaryRefresher != null) {
        _secondaryRefresherOperation =
            CancelableOperation.fromFuture(widget.secondaryRefresher!());
        refreshFutures.add(_secondaryRefresherOperation!.value);
      }

      List<dynamic> results = await Future.wait(refreshFutures);
      List<Post> posts = results[0];

      if (!_onScrollLoadMoreLimitRemoved &&
          widget.onScrollLoadMoreLimit != null &&
          posts.length > widget.onScrollLoadMoreLimit!) {
        // Slice the posts to be within the limit
        posts = posts.sublist(0, widget.onScrollLoadMoreLimit! - 1);
        _setStatus(OBPostsStreamStatus.onScrollLoadMoreLimitReached);
      } else if (posts.length == 0) {
        _setStatus(OBPostsStreamStatus.empty);
      } else {
        _setStatus(OBPostsStreamStatus.idle);
      }
      _setPosts(posts);
      if (widget.onPostsRefreshed != null) widget.onPostsRefreshed!(posts);
    } catch (error) {
      _setStatus(OBPostsStreamStatus.loadingMoreFailed);
      _onError(error);
    } finally {
      _refreshOperation = null;
      _secondaryRefresherOperation = null;
    }
  }

  void _removeOnScrollLoadMoreLimit() {
    _onScrollLoadMoreLimitRemoved = true;
    _setStatus(OBPostsStreamStatus.idle);
    _loadMorePosts();
  }

  Future _loadMorePosts() async {
    if (_status == OBPostsStreamStatus.refreshing ||
        _status == OBPostsStreamStatus.noMoreToLoad ||
        _status == OBPostsStreamStatus.loadingMore ||
        _status == OBPostsStreamStatus.onScrollLoadMoreLimitReached ||
        _posts.isEmpty) return null;

    if (!_onScrollLoadMoreLimitRemoved &&
        (widget.onScrollLoadMoreLimit != null &&
            _posts.length >= widget.onScrollLoadMoreLimit!)) {
      debugLog('Load more limit reached');
      _setStatus(OBPostsStreamStatus.onScrollLoadMoreLimitReached);
      return;
    }

    debugLog('Loading more posts');
    _ensureNoLoadMoreInProgress();
    _setStatus(OBPostsStreamStatus.loadingMore);

    try {
      _loadMoreOperation =
          CancelableOperation.fromFuture(widget.onScrollLoader(_posts));

      List<Post> morePosts = await _loadMoreOperation!.value;

      if (!_onScrollLoadMoreLimitRemoved &&
          widget.onScrollLoadMoreLimit != null &&
          _posts.length + morePosts.length > widget.onScrollLoadMoreLimit!) {
        // Slice the posts to be within the limit
        if (morePosts.length == 0) return;
        morePosts =
            morePosts.sublist(0, widget.onScrollLoadMoreLimit! - _posts.length);
        _setStatus(OBPostsStreamStatus.onScrollLoadMoreLimitReached);
      } else if (morePosts.length == 0) {
        _setStatus(OBPostsStreamStatus.noMoreToLoad);
      } else {
        _setStatus(OBPostsStreamStatus.idle);
        _addPosts(morePosts);
      }
    } catch (error) {
      _setStatus(OBPostsStreamStatus.loadingMoreFailed);
      _onError(error);
    } finally {
      _loadMoreOperation = null;
    }
  }

  void _onPostDeleted(Post deletedPost) {
    setState(() {
      _posts.remove(deletedPost);
      if (_posts.isEmpty) _setStatus(OBPostsStreamStatus.empty);
      if (deletedPost.isCommunityPost())
        deletedPost.community!.decrementPostsCount();
    });
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

  void _setStatus(OBPostsStreamStatus status) {
    setState(() {
      _status = status;
    });
  }

  void debugLog(String log) {
    //debugPrint('OBPostsStream:${widget.streamIdentifier}: $log');
  }

  String _makePostUniqueIdentifier(Post post) {
    return '${_streamUniqueIdentifier}_${post.id.toString()}';
  }
}

class OBPostsStreamController {
  OBPostsStreamState? _state;

  /// Register the OBHomePostsState to the controller
  void attach(OBPostsStreamState? state) {
    assert(state != null, 'Cannot attach to empty state');
    _state = state;
  }

  void scrollToTop({bool skipRefresh = false}) {
    _state?._scrollToTop(skipRefresh: skipRefresh);
  }

  void addPostToTop(Post post) {
    _state?._addPostToTop(post);
  }

  Future? refreshPosts() {
    return _state?._refreshPosts();
  }

  Future? refresh() {
    return _state?._refresh();
  }

  bool isAttached() {
    return _state != null;
  }
}

enum OBPostsStreamStatus {
  refreshing,
  loadingMore,
  loadingMoreFailed,
  noMoreToLoad,
  empty,
  idle,
  onScrollLoadMoreLimitReached
}

Widget defaultStatusIndicatorBuilder(
    {BuildContext? context,
    OBPostsStreamStatus? streamStatus,
    List<Widget>? streamPrependedItems,
    Function? streamRefresher}) {
  return OBPostsStreamDrHoo(
    streamStatus: streamStatus,
    streamPrependedItems: streamPrependedItems,
    streamRefresher: () {
      if (streamRefresher != null) {
        streamRefresher();
      }
    },
  );
}

typedef Future<List<Post>> OBPostsStreamRefresher<Post>();
typedef Future<List<Post>> OBPostsStreamOnScrollLoader<T>(List<Post> posts);
typedef Future OBPostsStreamSecondaryRefresher();

typedef OBPostsStreamStatusIndicatorBuilder = Widget Function(
    {required BuildContext context,
    required OBPostsStreamStatus streamStatus,
    required List<Widget> streamPrependedItems,
    required Function streamRefresher});

typedef Widget OBPostsStreamPostBuilder(
    {BuildContext context,
    Post post,
    OBPostDisplayContext displayContext,
    String postIdentifier,
    ValueChanged<Post> onPostDeleted});
