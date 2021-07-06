import 'package:Okuna/models/post.dart';
import 'package:Okuna/models/post_comment.dart';
import 'package:Okuna/models/user.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/toast.dart';
import 'package:Okuna/services/user.dart';
import 'package:Okuna/widgets/theming/actionable_smart_text.dart';
import 'package:Okuna/widgets/theming/collapsible_smart_text.dart';
import 'package:Okuna/widgets/theming/secondary_text.dart';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OBPostCommentText extends StatefulWidget {
  final PostComment postComment;
  final Post post;
  final VoidCallback? onUsernamePressed;
  final int postCommentMaxVisibleLength = 500;

  OBPostCommentText(this.postComment, this.post,
      {Key? key, this.onUsernamePressed})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return OBPostCommentTextState();
  }
}

class OBPostCommentTextState extends State<OBPostCommentText> {
  String? _translatedText;
  late bool _requestInProgress;
  late UserService _userService;
  late ToastService _toastService;
  late LocalizationService _localizationService;

  @override
  void initState() {
    super.initState();
    _requestInProgress = false;
  }

  @override
  Widget build(BuildContext context) {
    OpenbookProviderState provider = OpenbookProvider.of(context);
    _toastService = provider.toastService;
    _userService = provider.userService;
    _localizationService = provider.localizationService;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Flexible(
              child: GestureDetector(
                onLongPress: () {
                  OpenbookProviderState openbookProvider =
                      OpenbookProvider.of(context);
                  Clipboard.setData(
                      ClipboardData(text: widget.postComment.text));
                  openbookProvider.toastService.toast(
                      message: 'Text copied!',
                      context: context,
                      type: ToastType.info);
                },
                child: _getActionableSmartText(widget.postComment.isEdited ?? false),
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _getPostCommentTranslateButton() {
    if (_requestInProgress) {
      return Padding(
          padding: EdgeInsets.all(10.0),
          child: Container(
            width: 10.0,
            height: 10.0,
            child: CircularProgressIndicator(strokeWidth: 2.0),
          ));
    }

    User? loggedInUser = _userService.getLoggedInUser();
    if (loggedInUser != null &&
        loggedInUser.canTranslatePostComment(widget.postComment, widget.post)) {
      return GestureDetector(
        onTap: _toggleTranslatePostComment,
        child: _translatedText != null
            ? OBSecondaryText(
                _localizationService.user__translate_show_original,
                size: OBTextSize.large)
            : OBSecondaryText(
                _localizationService.user__translate_see_translation,
                size: OBTextSize.large),
      );
    } else {
      return SizedBox();
    }
  }

  void _toggleTranslatePostComment() async {
    try {
      if (_translatedText == null) {
        _setRequestInProgress(true);
        CancelableOperation<String> _getTranslationOperation =
            CancelableOperation.fromFuture(_userService.translatePostComment(
          postComment: widget.postComment,
          post: widget.post,
        ));

        String translatedText = await _getTranslationOperation.value;
        _setPostCommentTranslatedText(translatedText);
      } else {
        _setPostCommentTranslatedText(null);
      }
    } catch (error) {
      _onError(error);
    } finally {
      _setRequestInProgress(false);
    }
  }

  Widget _getActionableSmartText(bool isEdited) {
    if (isEdited) {
      return OBCollapsibleSmartText(
        size: OBTextSize.large,
        text: _translatedText ?? widget.postComment.text,
        trailingSmartTextElement: SecondaryTextElement(' (edited)'),
        maxlength: widget.postCommentMaxVisibleLength,
        getChild: _getPostCommentTranslateButton,
        hashtagsMap: widget.postComment.hashtagsMap,
        links: widget.post.postLinksList?.postLinks,
      );
    } else {
      return OBCollapsibleSmartText(
        size: OBTextSize.large,
        text: _translatedText ?? widget.postComment.text,
        maxlength: widget.postCommentMaxVisibleLength,
        getChild: _getPostCommentTranslateButton,
        hashtagsMap: widget.postComment.hashtagsMap,
        links: widget.post.postLinksList?.postLinks,
      );
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

  void _setRequestInProgress(bool requestInProgress) {
    setState(() {
      _requestInProgress = requestInProgress;
    });
  }

  void _setPostCommentTranslatedText(String? newText) {
    setState(() {
      _translatedText = newText;
    });
  }
}
