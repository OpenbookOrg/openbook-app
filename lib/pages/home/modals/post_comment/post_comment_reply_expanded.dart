import 'package:Okuna/models/post.dart';
import 'package:Okuna/models/post_comment.dart';
import 'package:Okuna/pages/home/modals/save_post/widgets/create_post_text.dart';
import 'package:Okuna/pages/home/modals/save_post/widgets/remaining_post_characters.dart';
import 'package:Okuna/pages/home/lib/draft_editing_controller.dart';
import 'package:Okuna/pages/home/pages/post_comments/widgets/post_comment/post_comment.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/draft.dart';
import 'package:Okuna/services/httpie.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/toast.dart';
import 'package:Okuna/services/user.dart';
import 'package:Okuna/services/validation.dart';
import 'package:Okuna/widgets/avatars/logged_in_user_avatar.dart';
import 'package:Okuna/widgets/avatars/avatar.dart';
import 'package:Okuna/widgets/buttons/button.dart';
import 'package:Okuna/widgets/contextual_search_boxes/contextual_search_box_state.dart';
import 'package:Okuna/widgets/icon.dart';
import 'package:Okuna/widgets/nav_bars/themed_nav_bar.dart';
import 'package:Okuna/widgets/theming/post_divider.dart';
import 'package:Okuna/widgets/theming/primary_color_container.dart';
import 'package:async/async.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OBPostCommentReplyExpandedModal extends StatefulWidget {
  final Post? post;
  final PostComment? postComment;
  final Function(PostComment)? onReplyAdded;
  final Function(PostComment)? onReplyDeleted;

  const OBPostCommentReplyExpandedModal(
      {Key? key,
      this.post,
      this.postComment,
      this.onReplyAdded,
      this.onReplyDeleted})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return OBPostCommentReplyExpandedModalState();
  }
}

class OBPostCommentReplyExpandedModalState
    extends OBContextualSearchBoxState<OBPostCommentReplyExpandedModal> {
  late ValidationService _validationService;
  late ToastService _toastService;
  late LocalizationService _localizationService;
  late UserService _userService;
  late DraftService _draftService;

  late DraftTextEditingController _textController;
  late int _charactersCount;
  late bool _isPostCommentTextAllowedLength;
  late List<Widget> _postCommentItemsWidgets;
  late ScrollController _scrollController;

  CancelableOperation? _postCommentReplyOperation;
  late bool _requestInProgress;
  late bool _needsBootstrap;

  @override
  void initState() {
    super.initState();
    _needsBootstrap = true;
    _scrollController = ScrollController();
    _charactersCount = 0;
    _isPostCommentTextAllowedLength = false;
    _requestInProgress = false;
  }

  @override
  void dispose() {
    super.dispose();
    if (_postCommentReplyOperation != null) _postCommentReplyOperation!.cancel();
    _textController.removeListener(_onPostCommentTextChanged);
  }

  @override
  void bootstrap() {
    super.bootstrap();

    _textController = DraftTextEditingController.comment(widget.post!.id!,
        commentId: widget.postComment != null ? widget.postComment!.id : null,
        draftService: _draftService);
    _textController.addListener(_onPostCommentTextChanged);
    setAutocompleteTextController(_textController);

    String hintText =
        _localizationService.post__comment_reply_expanded_reply_hint_text;
    _postCommentItemsWidgets = [
      OBCreatePostText(controller: _textController, hintText: hintText)
    ];

    //Scroll to bottom
    Future.delayed(Duration(milliseconds: 0), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 10),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_needsBootstrap) {
      var openbookProvider = OpenbookProvider.of(context);
      _validationService = openbookProvider.validationService;
      _userService = openbookProvider.userService;
      _localizationService = openbookProvider.localizationService;
      _toastService = openbookProvider.toastService;
      _draftService = openbookProvider.draftService;

      bootstrap();

      _needsBootstrap = false;
    }

    List<Widget> bodyItems = [
      Expanded(
        flex: isAutocompleting ? 3 : 10,
        child: _buildPostCommentEditor(),
      )
    ];

    if (isAutocompleting) {
      bodyItems.add(Expanded(flex: 7, child: buildSearchBox()));
    }

    return CupertinoPageScaffold(
        backgroundColor: Colors.transparent,
        navigationBar: _buildNavigationBar(),
        child: OBPrimaryColorContainer(
            child:
                Column(mainAxisSize: MainAxisSize.max, children: bodyItems)));
  }

  ObstructingPreferredSizeWidget _buildNavigationBar() {
    bool isPrimaryActionButtonIsEnabled =
        (_isPostCommentTextAllowedLength && _charactersCount > 0);

    return OBThemedNavigationBar(
      leading: GestureDetector(
        child: const OBIcon(OBIcons.close),
        onTap: () {
          Navigator.pop(context);
        },
      ),
      title: _localizationService.post__comment_reply_expanded_reply_comment,
      trailing:
          _buildPrimaryActionButton(isEnabled: isPrimaryActionButtonIsEnabled),
    );
  }

  Widget _buildPrimaryActionButton({bool? isEnabled}) {
    return OBButton(
      isDisabled: !(isEnabled ?? false),
      isLoading: _requestInProgress,
      size: OBButtonSize.small,
      onPressed: _onWantsToReplyComment,
      child: Text(_localizationService.post__comment_reply_expanded_post),
    );
  }

  void _onWantsToReplyComment() async {
    if (_requestInProgress) return;
    _setRequestInProgress(true);
    try {
      _postCommentReplyOperation = CancelableOperation.fromFuture(
          _userService.replyPostComment(
              post: widget.post!,
              postComment: widget.postComment!,
              text: _textController.text));

      PostComment comment = await _postCommentReplyOperation?.value;
      if (widget.onReplyAdded != null) widget.onReplyAdded!(comment);
      Navigator.pop(context, comment);
    } catch (error) {
      _onError(error);
    } finally {
      _textController.clearDraft();
      _setRequestInProgress(false);
      _postCommentReplyOperation = null;
    }
  }

  Widget _buildPostCommentEditor() {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          OBPostComment(
            post: widget.post,
            postComment: widget.postComment,
            showActions: false,
            showReactions: false,
            showReplies: false,
            padding: EdgeInsets.all(15),
          ),
          OBPostDivider(),
          Padding(
            padding: EdgeInsets.only(left: 20.0, top: 10.0, bottom: 20.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    OBLoggedInUserAvatar(
                      size: OBAvatarSize.medium,
                    ),
                    const SizedBox(
                      height: 12.0,
                    ),
                    OBRemainingPostCharacters(
                      maxCharacters: ValidationService.POST_COMMENT_MAX_LENGTH,
                      currentCharacters: _charactersCount,
                    ),
                  ],
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                        padding: EdgeInsets.only(
                            left: 20.0, right: 20.0, bottom: 30.0, top: 0.0),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _postCommentItemsWidgets)),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  void _onPostCommentTextChanged() {
    String text = _textController.text;
    setState(() {
      _charactersCount = text.length;
      _isPostCommentTextAllowedLength =
          _validationService.isPostCommentAllowedLength(text);
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

  void _setRequestInProgress(requestInProgress) {
    setState(() {
      _requestInProgress = requestInProgress;
    });
  }

  void debugLog(String log) {
    debugPrint('OBPostCommentReplyExpandedModal:$log');
  }
}
