import 'package:Okuna/models/post.dart';
import 'package:Okuna/models/post_comment.dart';
import 'package:Okuna/pages/home/lib/draft_editing_controller.dart';
import 'package:Okuna/pages/home/pages/post_comments/post_comments_page_controller.dart';
import 'package:Okuna/pages/home/pages/post_comments/widgets/post_commenter.dart';
import 'package:Okuna/pages/home/pages/post_comments/widgets/post_comment/post_comment.dart';
import 'package:Okuna/pages/home/pages/post_comments/widgets/post_comments_header_bar.dart';
import 'package:Okuna/services/draft.dart';
import 'package:Okuna/pages/home/pages/post_comments/widgets/post_preview.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/theme.dart';
import 'package:Okuna/services/theme_value_parser.dart';
import 'package:Okuna/services/user_preferences.dart';
import 'package:Okuna/services/utils_service.dart';
import 'package:Okuna/widgets/contextual_search_boxes/contextual_search_box_state.dart';
import 'package:Okuna/widgets/link_preview.dart';
import 'package:Okuna/widgets/nav_bars/themed_nav_bar.dart';
import 'package:Okuna/widgets/page_scaffold.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/toast.dart';
import 'package:Okuna/services/user.dart';
import 'package:Okuna/widgets/theming/post_divider.dart';
import 'package:Okuna/widgets/theming/primary_color_container.dart';
import 'package:async/async.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Okuna/widgets/load_more.dart';
import 'package:Okuna/services/httpie.dart';

class OBPostCommentsPage extends StatefulWidget {
  final PostComment? linkedPostComment;
  final Post? post;
  final PostCommentsPageType pageType;
  final bool autofocusCommentInput;
  final bool? showPostPreview;
  final PostComment? postComment;
  final ValueChanged<PostComment>? onCommentDeleted;
  final ValueChanged<PostComment>? onCommentAdded;

  OBPostCommentsPage({
    required this.pageType,
    this.post,
    this.linkedPostComment,
    this.postComment,
    this.onCommentDeleted,
    this.onCommentAdded,
    this.showPostPreview,
    this.autofocusCommentInput: false,
  });

  @override
  State<OBPostCommentsPage> createState() {
    return OBPostCommentsPageState();
  }
}

class OBPostCommentsPageState
    extends OBContextualSearchBoxState<OBPostCommentsPage>
    with SingleTickerProviderStateMixin {
  late UserService _userService;
  late UserPreferencesService _userPreferencesService;
  late ToastService _toastService;
  late ThemeService _themeService;
  late DraftService _draftService;
  late UtilsService _utilsService;
  late LocalizationService _localizationService;
  late ThemeValueParserService _themeValueParserService;
  late Post _post;
  late AnimationController _animationController;
  late Animation<double> _animation;

  late double _positionTopCommentSection;
  ScrollController? _postCommentsScrollController;
  List<PostComment> _postComments = [];
  late bool _noMoreBottomItemsToLoad;
  late bool _noMoreTopItemsToLoad;
  late bool _needsBootstrap;
  late bool _shouldHideStackedLoadingScreen;
  late bool _startScrollWasInitialised;
  late PostCommentsSortType _currentSort;
  late FocusNode _commentInputFocusNode;
  late GlobalKey<RefreshIndicatorState> _refreshIndicatorKey;
  late OBPostCommentsPageController _commentsPageController;
  late Map<String, String> _pageTextMap;

  late DraftTextEditingController _postCommenterTextController;

  static const int MAX_POST_TEXT_LENGTH_LIMIT = 1300;
  static const int MAX_COMMENT_TEXT_LENGTH_LIMIT = 500;

  static const OFFSET_TOP_HEADER = 64.0;
  static const HEIGHT_POST_HEADER = 72.0;
  static const HEIGHT_POST_REACTIONS = 35.0;
  static const HEIGHT_POST_CIRCLES = 26.0;
  static const HEIGHT_POST_ACTIONS = 46.0;
  static const TOTAL_PADDING_POST_TEXT = 40.0;
  static const HEIGHT_POST_DIVIDER = 5.5;
  static const HEIGHT_SIZED_BOX = 16.0;
  static const HEIGHT_SHOW_MORE_TEXT = 45.0;
  static const HEIGHT_COMMENTS_RELATIVE_TIMESTAMP_TEXT = 21.0;
  static const COMMENTS_MIN_HEIGHT = 20.0;

  static const TOTAL_FIXED_OFFSET_Y = OFFSET_TOP_HEADER +
      HEIGHT_POST_HEADER +
      HEIGHT_POST_REACTIONS +
      HEIGHT_POST_CIRCLES +
      HEIGHT_POST_ACTIONS +
      HEIGHT_SIZED_BOX +
      HEIGHT_POST_DIVIDER;

  CancelableOperation? _refreshPostOperation;
  CancelableOperation? _refreshPostCommentOperation;

  @override
  void initState() {
    super.initState();
    if (widget.linkedPostComment != null) _post = widget.linkedPostComment!.post!;
    if (widget.post != null) _post = widget.post!;
    _needsBootstrap = true;
    _postComments = [];
    _noMoreBottomItemsToLoad = true;
    _positionTopCommentSection = 0.0;
    _currentSort = PostCommentsSortType.dec;
    _noMoreTopItemsToLoad = false;
    _startScrollWasInitialised = false;
    _shouldHideStackedLoadingScreen = false;
    _commentInputFocusNode = FocusNode();
    _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
    _animationController = AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this);
    _animation = new Tween(begin: 1.0, end: 0.0).animate(_animationController);
    _animation.addStatusListener(_onAnimationStatusChanged);
  }

  @override
  void bootstrap() {
    super.bootstrap();

    _bootstrapAsync();

    _postCommenterTextController = DraftTextEditingController.comment(
        widget.post!.id!,
        commentId: widget.postComment?.id,
        draftService: _draftService);

    setAutocompleteTextController(_postCommenterTextController);
  }

  void _bootstrapAsync() async {
    await _setPostCommentsSortTypeFromPreferences();
    _initialiseCommentsPageController();
    if (widget.post != null) _refreshPost();
    if (widget.postComment != null) _refreshPostComment();
  }

  @override
  Widget build(BuildContext context) {
    if (_needsBootstrap) {
      var provider = OpenbookProvider.of(context);
      _userService = provider.userService;
      _userPreferencesService = provider.userPreferencesService;
      _toastService = provider.toastService;
      _themeValueParserService = provider.themeValueParserService;
      _themeService = provider.themeService;
      _localizationService = provider.localizationService;
      _draftService = provider.draftService;
      _utilsService = provider.utilsService;
      bootstrap();
      _needsBootstrap = false;
    }

    if (widget.pageType == PostCommentsPageType.comments) {
      _pageTextMap = this.getPageCommentsMap(_localizationService);
    } else {
      _pageTextMap = this.getPageRepliesMap(_localizationService);
    }

    return OBCupertinoPageScaffold(
        backgroundColor: Color.fromARGB(0, 0, 0, 0),
        navigationBar: OBThemedNavigationBar(
          title: _pageTextMap['TITLE'],
        ),
        child: OBPrimaryColorContainer(
          child: Stack(
            children: _getStackChildren(),
          ),
        ));
  }

  Future _setPostCommentsSortTypeFromPreferences() async {
    PostCommentsSortType sortType =
        await _userPreferencesService.getPostCommentsSortType();
    _currentSort = sortType;
  }

  void _initialiseCommentsPageController() {
    _commentsPageController = OBPostCommentsPageController(
        pageType: widget.pageType,
        userService: _userService,
        userPreferencesService: _userPreferencesService,
        currentSort: _currentSort,
        post: _post,
        postComment: widget.postComment,
        linkedPostComment: widget.linkedPostComment,
        addPostComments: _addPostComments,
        addToStartPostComments: _addToStartPostComments,
        setPostComments: _setPostComments,
        setCurrentSortValue: _setCurrentSortValue,
        setNoMoreBottomItemsToLoad: _setNoMoreBottomItemsToLoad,
        setNoMoreTopItemsToLoad: _setNoMoreTopItemsToLoad,
        showNoMoreTopItemsToLoadToast: _showNoMoreTopItemsToLoadToast,
        scrollToNewComment: _scrollToNewComment,
        scrollToTop: _scrollToTop,
        unfocusCommentInput: _unfocusCommentInput,
        onError: _onError);
  }

  void dispose() {
    super.dispose();
    _animation.removeStatusListener(_onAnimationStatusChanged);
    if (_refreshPostOperation != null) _refreshPostOperation!.cancel();
    _commentsPageController.dispose();
  }

  void _onAnimationStatusChanged(status) {
    if (status == AnimationStatus.completed) {
      setState(() {
        _shouldHideStackedLoadingScreen = true;
      });
    }
  }

  List<Widget> _getStackChildren() {
    var theme = _themeService.getActiveTheme();
    var primaryColor = _themeValueParserService.parseColor(theme.primaryColor);

    List<Widget> _stackChildren = [];

    if (_shouldHideStackedLoadingScreen) {
      _stackChildren.add(Column(
        children: _buildPostPageContentItems(),
      ));
    } else {
      _stackChildren.addAll([
        Column(
          children: _buildPostPageContentItems(),
        ),
        Positioned(
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
        )
      ]);
    }

    return _stackChildren;
  }

  List<Widget> _buildPostPageContentItems() {
    List<Widget> _contentItems = [];
    _postCommentsScrollController = ScrollController(
        initialScrollOffset: _calculatePositionTopCommentSection());

    _contentItems.addAll([_buildPostComments(), _buildPostCommenter()]);

    return _contentItems;
  }

  Widget _buildPostComments() {
    List<Widget> postCommentsStackItems = [
      RefreshIndicator(
          key: _refreshIndicatorKey,
          child: GestureDetector(
            onTap: _unfocusCommentInput,
            child: LoadMore(
                whenEmptyLoad: false,
                isFinish: _noMoreBottomItemsToLoad,
                delegate: OBInfinitePostCommentsLoadMoreDelegate(_pageTextMap),
                child: new ListView.builder(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    controller: _postCommentsScrollController,
                    padding: EdgeInsets.all(0),
                    itemCount: _postComments.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        if (_postComments.length > 0) {
                          _beginAnimations();
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            _getPostPreview(),
                            _getCommentPreview(),
                            _getDivider(),
                            OBPostCommentsHeaderBar(
                                pageType: widget.pageType,
                                noMoreTopItemsToLoad: _noMoreTopItemsToLoad,
                                postComments: _postComments,
                                currentSort: _currentSort,
                                onWantsToToggleSortComments: () =>
                                    _commentsPageController
                                        .onWantsToToggleSortComments(),
                                loadMoreTopComments: () =>
                                    _commentsPageController
                                        .loadMoreTopComments(),
                                onWantsToRefreshComments: () =>
                                    _commentsPageController
                                        .onWantsToRefreshComments()),
                          ],
                        );
                      } else {
                        return _getCommentTile(index);
                      }
                    }),
                onLoadMore: () =>
                    _commentsPageController.loadMoreBottomComments()),
          ),
          onRefresh: () => _commentsPageController.onWantsToRefreshComments())
    ];

    if (isAutocompleting) {
      postCommentsStackItems.add(Positioned(
        key: Key('obPostCommentsAutoComplete'),
        child: OBPrimaryColorContainer(
          child: buildSearchBox(),
        ),
        left: 0,
        right: 0,
        bottom: 0,
        top: 0,
      ));
    }

    return Expanded(
      child: Stack(
        children: postCommentsStackItems,
      ),
    );
  }

  Widget _buildPostCommenter() {
    return OBPostCommenter(_post,
        postComment: widget.postComment,
        autofocus: widget.autofocusCommentInput,
        commentTextFieldFocusNode: _commentInputFocusNode,
        textController: _postCommenterTextController,
        onPostCommentCreated: _onPostCommentCreated);
  }

  void _onPostCommentCreated(PostComment createdPostComment) {
    _commentsPageController
        .refreshCommentsWithCreatedPostCommentVisible(createdPostComment);
    if (widget.onCommentAdded != null) {
      widget.onCommentAdded!(createdPostComment);
    }
  }

  void _beginAnimations() {
    if (_animationController.status != AnimationStatus.completed &&
        !_startScrollWasInitialised &&
        widget.showPostPreview == true) {
      Future.delayed(Duration(milliseconds: 0), () {
        if (_positionTopCommentSection == 0.0) _setPositionTopCommentSection();
        _postCommentsScrollController?.animateTo(
            _positionTopCommentSection - 100.0,
            duration: Duration(milliseconds: 5),
            curve: Curves.easeIn);
      });
    }

    _animationController.forward();
    Future.delayed(Duration(milliseconds: 0), () {
      if (!_startScrollWasInitialised) {
        setState(() {
          _startScrollWasInitialised = true;
        });
      }
    });
  }

  Widget _getDivider() {
    if (widget.postComment != null) {
      return OBPostDivider();
    }
    return SizedBox();
  }

  Widget _getCommentPreview() {
    if (widget.postComment == null) {
      return SizedBox();
    }
    return OBPostComment(
      post: widget.post,
      postComment: widget.postComment,
      showReplies: false,
      showReplyAction: false,
      onPostCommentDeleted: _onPostCommentDeleted,
      onPostCommentReported: _onPostCommentReported,
    );
  }

  void _onPostCommentReported(PostComment postComment) {
    Navigator.of(context).pop();
  }

  void _onPostCommentDeleted(PostComment postComment) {
    Navigator.of(context).pop();
  }

  Widget _getCommentTile(int index) {
    int commentIndex = index - 1;
    var postComment = _postComments[commentIndex];
    var onPostCommentDeletedCallback = (PostComment comment) {
      _removePostCommentAtIndex(commentIndex);
      if (widget.onCommentDeleted != null) widget.onCommentDeleted!(postComment);
    };

    if (widget.linkedPostComment != null &&
        postComment.id == widget.linkedPostComment!.id) {
      var theme = _themeService.getActiveTheme();
      var primaryColor =
          _themeValueParserService.parseColor(theme.primaryColor);
      final bool isDarkPrimaryColor = primaryColor.computeLuminance() < 0.179;
      return DecoratedBox(
        decoration: BoxDecoration(
          color: isDarkPrimaryColor
              ? Color.fromARGB(30, 255, 255, 255)
              : Color.fromARGB(20, 0, 0, 0),
        ),
        child: OBPostComment(
          key: Key('postComment#${widget.pageType}#${postComment.id}'),
          postComment: postComment,
          post: _post,
          onPostCommentDeleted: onPostCommentDeletedCallback,
          onPostCommentReported: onPostCommentDeletedCallback,
        ),
      );
    } else {
      return OBPostComment(
        key: Key('postComment#${widget.pageType}#${postComment.id}'),
        postComment: postComment,
        post: _post,
        onPostCommentDeleted: onPostCommentDeletedCallback,
        onPostCommentReported: onPostCommentDeletedCallback,
      );
    }
  }

  Widget _getPostPreview() {
    if (widget.post == null || !(widget.showPostPreview ?? false)) {
      return SizedBox();
    }

    bool _showViewAllCommentsAction = true;

    if ((widget.pageType == PostCommentsPageType.replies &&
            widget.linkedPostComment == null) ||
        (widget.pageType == PostCommentsPageType.comments)) {
      _showViewAllCommentsAction = false;
    }

    return OBPostPreview(
        post: _post,
        onPostDeleted: _onPostDeleted,
        focusCommentInput: _focusCommentInput,
        showViewAllCommentsAction: _showViewAllCommentsAction);
  }

  void _scrollToTop() {
    if (!_postCommentsScrollController!.hasListeners) return;
    Future.delayed(Duration(milliseconds: 0), () {
      _postCommentsScrollController!.animateTo(
        0.0,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 300),
      );
    });
  }

  void _setPositionTopCommentSection() {
    setState(() {
      _positionTopCommentSection = _calculatePositionTopCommentSection();
    });
  }

  Future<void> _refreshPost() async {
    if (_refreshPostOperation != null) _refreshPostOperation!.cancel();
    try {
      // This will trigger the updateSubject of the post
      _refreshPostOperation = CancelableOperation.fromFuture(
          _userService.getPostWithUuid(_post.uuid!));

      await _refreshPostOperation?.value;
    } catch (error) {
      _onError(error);
    } finally {
      _refreshPostOperation = null;
    }
  }

  Future<void> _refreshPostComment() async {
    if (_refreshPostCommentOperation != null)
      _refreshPostCommentOperation!.cancel();
    try {
      // This will trigger the updateSubject of the postComment
      _refreshPostCommentOperation = CancelableOperation.fromFuture(_userService
          .getPostComment(post: widget.post!, postComment: widget.postComment!));

      await _refreshPostCommentOperation?.value;
      _setPositionTopCommentSection();
    } catch (error) {
      _onError(error);
    } finally {
      _refreshPostCommentOperation = null;
    }
  }

  void _removePostCommentAtIndex(int index) {
    setState(() {
      _postComments.removeAt(index);
    });
  }

  void _onPostDeleted(Post post) {
    Navigator.of(context).pop();
  }

  void _focusCommentInput() {
    FocusScope.of(context).requestFocus(_commentInputFocusNode);
  }

  void _unfocusCommentInput() {
    FocusScope.of(context).requestFocus(new FocusNode());
  }

  void _addPostComments(List<PostComment> postComments) {
    setState(() {
      this._postComments.addAll(postComments);
    });
    _commentsPageController.updateControllerPostComments(this._postComments);
  }

  void _addToStartPostComments(List<PostComment> postComments) {
    postComments.reversed.forEach((comment) {
      setState(() {
        this._postComments.insert(0, comment);
      });
    });
    _commentsPageController.updateControllerPostComments(this._postComments);
  }

  void _setPostComments(List<PostComment> postComments) {
    setState(() {
      this._postComments = postComments;
    });
    _commentsPageController.updateControllerPostComments(this._postComments);
    if (this._postComments.length == 0) {
      _animationController.forward();
    }
  }

  void _setNoMoreBottomItemsToLoad(bool noMoreItemsToLoad) {
    setState(() {
      _noMoreBottomItemsToLoad = noMoreItemsToLoad;
    });
  }

  void _setNoMoreTopItemsToLoad(bool noMoreItemsToLoad) {
    setState(() {
      _noMoreTopItemsToLoad = noMoreItemsToLoad;
    });
  }

  void _showNoMoreTopItemsToLoadToast() {
    _toastService.info(
        context: context, message: _pageTextMap['NO_MORE_TO_LOAD']!);
  }

  void _setCurrentSortValue(PostCommentsSortType newSortValue) {
    setState(() {
      _currentSort = newSortValue;
    });
  }

  void _scrollToNewComment() {
    if (_currentSort == PostCommentsSortType.asc) {
      _postCommentsScrollController?.animateTo(
          _postCommentsScrollController!.position.maxScrollExtent,
          duration: const Duration(milliseconds: 50),
          curve: Curves.easeIn);
    } else if (_currentSort == PostCommentsSortType.dec) {
      _postCommentsScrollController?.animateTo(
          _positionTopCommentSection - 100.0,
          duration: Duration(milliseconds: 5),
          curve: Curves.easeIn);
    }
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

  Map<String, String> getPageCommentsMap(
      LocalizationService _localizationService) {
    return {
      'TITLE': _localizationService.post__comments_page_title,
      'NO_MORE_TO_LOAD':
          _localizationService.post__comments_page_no_more_to_load,
      'TAP_TO_RETRY': _localizationService.post__comments_page_tap_to_retry,
    };
  }

  Map<String, String> getPageRepliesMap(
      LocalizationService _localizationService) {
    return {
      'TITLE': _localizationService.post__comments_page_replies_title,
      'NO_MORE_TO_LOAD':
          _localizationService.post__comments_page_no_more_replies_to_load,
      'TAP_TO_RETRY':
          _localizationService.post__comments_page_tap_to_retry_replies,
    };
  }

  double _calculatePositionTopCommentSection() {
    double aspectRatio;
    double finalMediaScreenHeight = 0.0;
    double finalTextHeight = 0.0;
    double finalCommentHeight = 0.0;
    double finalPostHeight = 0.0;
    double totalOffsetY = 0.0;

    if (widget.post == null) return totalOffsetY;

    double screenWidth = MediaQuery.of(context).size.width;

    if (widget.showPostPreview == true && widget.post != null) {
      if (_post.hasMediaThumbnail()) {
        aspectRatio = _post.mediaWidth! / _post.mediaHeight!;
        finalMediaScreenHeight = screenWidth / aspectRatio;
      }

      if (_post.hasText()) {
        TextStyle style = TextStyle(fontSize: 16.0);
        String postText = _post.text ?? '';
        if (postText.length > MAX_POST_TEXT_LENGTH_LIMIT)
          postText = postText.substring(0, MAX_POST_TEXT_LENGTH_LIMIT);
        TextSpan text = new TextSpan(text: postText, style: style);

        TextPainter textPainter = new TextPainter(
          text: text,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.left,
        );
        textPainter.layout(
            maxWidth: screenWidth - 40.0); //padding is 20 in OBPostBodyText
        finalTextHeight = textPainter.size.height + TOTAL_PADDING_POST_TEXT;

        if (_post.text!.length > MAX_POST_TEXT_LENGTH_LIMIT) {
          finalTextHeight = finalTextHeight + HEIGHT_SHOW_MORE_TEXT;
        }
      }

      if (_post.hasCircles() ||
          (_post.isEncircled != null && _post.isEncircled!)) {
        finalPostHeight = finalPostHeight + HEIGHT_POST_CIRCLES;
      }

      finalPostHeight = finalPostHeight +
          finalTextHeight +
          finalMediaScreenHeight +
          TOTAL_FIXED_OFFSET_Y;

      if (widget.post!.text != null &&
          _utilsService.hasLinkToPreview(widget.post!.text)) {
        // Approx height of link preview without image..
        finalPostHeight += OBLinkPreviewState.linkPreviewHeight;
      }
    }

    // linked comment

    if (widget.postComment != null) {
      TextStyle style = TextStyle(fontSize: 16.0);
      String commentText = widget.postComment?.text ?? '';
      if (commentText.length > MAX_COMMENT_TEXT_LENGTH_LIMIT)
        commentText = commentText.substring(0, MAX_COMMENT_TEXT_LENGTH_LIMIT);

      TextSpan text = new TextSpan(text: commentText, style: style);

      TextPainter textPainter = new TextPainter(
        text: text,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.left,
      );
      textPainter.layout(
          maxWidth: screenWidth - 80.0); //padding is 100 around comments
      finalCommentHeight = textPainter.size.height +
          COMMENTS_MIN_HEIGHT +
          HEIGHT_COMMENTS_RELATIVE_TIMESTAMP_TEXT;

      if (widget.postComment!.text!.length > MAX_COMMENT_TEXT_LENGTH_LIMIT) {
        finalCommentHeight = finalCommentHeight + HEIGHT_SHOW_MORE_TEXT;
      }
    }

    totalOffsetY = totalOffsetY + finalPostHeight + finalCommentHeight;

    return totalOffsetY;
  }
}

class OBInfinitePostCommentsLoadMoreDelegate extends LoadMoreDelegate {
  Map<String, String> pageTextMap;

  OBInfinitePostCommentsLoadMoreDelegate(this.pageTextMap);

  @override
  Widget buildChild(LoadMoreStatus status,
      {LoadMoreTextBuilder builder = DefaultLoadMoreTextBuilder.english}) {
    String text = builder(status);

    if (status == LoadMoreStatus.fail) {
      return SizedBox(
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.refresh),
            const SizedBox(
              width: 10.0,
            ),
            Text(pageTextMap['TAP_TO_RETRY']!)
          ],
        ),
      );
    }
    if (status == LoadMoreStatus.idle) {
      // No clue why is this even a state.
      return const SizedBox();
    }
    if (status == LoadMoreStatus.loading) {
      return SizedBox(
          child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: 20.0,
            maxWidth: 20.0,
          ),
          child: CircularProgressIndicator(
            strokeWidth: 2.0,
          ),
        ),
      ));
    }
    if (status == LoadMoreStatus.nomore) {
      return const SizedBox();
    }

    return Text(text);
  }
}
