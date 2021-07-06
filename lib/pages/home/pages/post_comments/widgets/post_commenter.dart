import 'package:Okuna/models/post.dart';
import 'package:Okuna/models/post_comment.dart';
import 'package:Okuna/pages/home/modals/save_post/widgets/remaining_post_characters.dart';
import 'package:Okuna/pages/home/lib/draft_editing_controller.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/toast.dart';
import 'package:Okuna/services/user.dart';
import 'package:Okuna/services/validation.dart';
import 'package:Okuna/widgets/alerts/alert.dart';
import 'package:Okuna/widgets/avatars/logged_in_user_avatar.dart';
import 'package:Okuna/widgets/avatars/avatar.dart';
import 'package:Okuna/widgets/buttons/button.dart';
import 'package:Okuna/widgets/fields/text_form_field.dart';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:Okuna/services/httpie.dart';

class OBPostCommenter extends StatefulWidget {
  final Post post;
  final PostComment? postComment;
  final bool autofocus;
  final FocusNode? commentTextFieldFocusNode;
  final ValueChanged<PostComment>? onPostCommentCreated;
  final VoidCallback? onPostCommentWillBeCreated;
  final DraftTextEditingController textController;

  OBPostCommenter(this.post,
      {this.postComment,
      this.autofocus = false,
      this.commentTextFieldFocusNode,
      this.onPostCommentCreated,
      this.onPostCommentWillBeCreated,
      required this.textController});

  @override
  State<StatefulWidget> createState() {
    return OBPostCommenterState();
  }
}

class OBPostCommenterState extends State<OBPostCommenter> {
  late bool _commentInProgress;
  late bool _formWasSubmitted;
  late bool _needsBootstrap;

  late int _charactersCount;
  late bool _isMultiline;

  late UserService _userService;
  late ToastService _toastService;
  late ValidationService _validationService;
  late LocalizationService _localizationService;

  CancelableOperation? _submitFormOperation;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _commentInProgress = false;
    _formWasSubmitted = false;
    _needsBootstrap = true;
    _charactersCount = 0;
    _isMultiline = false;
  }

  @override
  void dispose() {
    super.dispose();
    if (_submitFormOperation != null) _submitFormOperation!.cancel();
  }

  @override
  Widget build(BuildContext context) {
    if (_needsBootstrap) {
      var provider = OpenbookProvider.of(context);
      _userService = provider.userService;
      _toastService = provider.toastService;
      _validationService = provider.validationService;
      _localizationService = provider.localizationService;
      widget.textController.addListener(_onPostCommentChanged);
      _needsBootstrap = false;
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const SizedBox(
            width: 20.0,
          ),
          Column(
            children: <Widget>[
              OBLoggedInUserAvatar(
                size: OBAvatarSize.medium,
              ),
              _isMultiline
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: OBRemainingPostCharacters(
                        maxCharacters:
                            ValidationService.POST_COMMENT_MAX_LENGTH,
                        currentCharacters: _charactersCount,
                      ),
                    )
                  : const SizedBox()
            ],
          ),
          const SizedBox(
            width: 10.0,
          ),
          Expanded(
            child: OBAlert(
              padding: const EdgeInsets.all(0),
              child: Form(
                  key: _formKey,
                  child: LayoutBuilder(builder: (context, size) {
                    TextStyle style = TextStyle(
                        fontSize: 14.0, fontFamilyFallback: ['NunitoSans']);
                    TextSpan text =
                        new TextSpan(text: widget.textController.text, style: style);

                    TextPainter tp = new TextPainter(
                      text: text,
                      textDirection: TextDirection.ltr,
                      textAlign: TextAlign.left,
                    );
                    tp.layout(maxWidth: size.maxWidth);

                    int lines =
                        (tp.size.height / tp.preferredLineHeight).ceil();

                    _isMultiline = lines > 3;

                    int maxLines = 5;

                    return _buildTextFormField(
                        lines < maxLines ? null : maxLines, style);
                  })),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 20.0, left: 10.0),
            child: OBButton(
              isLoading: _commentInProgress,
              size: OBButtonSize.small,
              onPressed: _submitForm,
              child:
                  Text(_localizationService.trans('post__commenter_post_text')),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTextFormField(int? maxLines, TextStyle style) {
    EdgeInsetsGeometry inputContentPadding =
        EdgeInsets.symmetric(vertical: 8.0, horizontal: 10);

    bool autofocus = widget.autofocus;
    FocusNode? focusNode = widget.commentTextFieldFocusNode ?? null;

    return OBTextFormField(
      controller: widget.textController,
      focusNode: focusNode,
      textCapitalization: TextCapitalization.sentences,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      maxLines: maxLines,
      style: style,
      decoration: InputDecoration(
        hintText: _localizationService.trans('post__commenter_write_something'),
        contentPadding: inputContentPadding,
      ),
      hasBorder: false,
      autofocus: autofocus,
      autocorrect: true,
      validator: (String? comment) {
        if (!_formWasSubmitted) return null;
        return _validationService.validatePostComment(widget.textController.text);
      },
    );
  }

  void _submitForm() async {
    if (_submitFormOperation != null) _submitFormOperation!.cancel();
    _setFormWasSubmitted(true);

    bool formIsValid = _validateForm();

    if (!formIsValid) return;

    _setCommentInProgress(true);
    try {
      if (widget.onPostCommentWillBeCreated != null) {
        widget.onPostCommentWillBeCreated!();
      } else {
        await Future.value();
      }

      String commentText = widget.textController.text;
      if (widget.postComment != null) {
        _submitFormOperation = CancelableOperation.fromFuture(
            _userService.replyPostComment(
                text: commentText,
                post: widget.post,
                postComment: widget.postComment!));
      } else {
        _submitFormOperation = CancelableOperation.fromFuture(
            _userService.commentPost(text: commentText, post: widget.post));
      }

      PostComment createdPostComment = await _submitFormOperation?.value;
      if (createdPostComment.parentComment == null)
        widget.post.incrementCommentsCount();
      widget.textController.clear();
      _setFormWasSubmitted(false);
      _validateForm();
      _setCommentInProgress(false);
      if (widget.onPostCommentCreated != null)
        widget.onPostCommentCreated!(createdPostComment);
    } catch (error) {
      _onError(error);
    } finally {
      _submitFormOperation = null;
      widget.textController.clearDraft();
      _setCommentInProgress(false);
    }
  }

  void _onPostCommentChanged() {
    int charactersCount = widget.textController.text.length;
    _setCharactersCount(charactersCount);
    if (charactersCount == 0) _setFormWasSubmitted(false);
    if (!_formWasSubmitted) return;
    _validateForm();
  }

  bool _validateForm() {
    return _formKey.currentState?.validate() ?? false;
  }

  void _onError(error) async {
    if (error is HttpieConnectionRefusedError) {
      _toastService.error(
          message: error.toHumanReadableMessage(), context: context);
    } else if (error is HttpieRequestError) {
      String? errorMessage = await error.toHumanReadableMessage();
      _toastService.error(message: errorMessage ?? _localizationService.trans('error__unknown_error'), context: context);
    } else {
      _toastService.error(
          message: _localizationService.trans('error__unknown_error'),
          context: context);
      throw error;
    }
  }

  void _setCommentInProgress(bool commentInProgress) {
    setState(() {
      _commentInProgress = commentInProgress;
    });
  }

  void _setFormWasSubmitted(bool formWasSubmitted) {
    setState(() {
      _formWasSubmitted = formWasSubmitted;
    });
  }

  void _setCharactersCount(int charactersCount) {
    setState(() {
      _charactersCount = charactersCount;
    });
  }

  void debugLog(String log) {
    debugPrint('OBPostCommenter:$log');
  }
}
