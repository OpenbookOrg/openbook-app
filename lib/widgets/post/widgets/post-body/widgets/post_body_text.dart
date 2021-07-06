import 'package:Okuna/provider.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/toast.dart';
import 'package:Okuna/models/post.dart';
import 'package:Okuna/services/user.dart';
import 'package:Okuna/widgets/theming/actionable_smart_text.dart';
import 'package:Okuna/widgets/theming/collapsible_smart_text.dart';
import 'package:Okuna/widgets/theming/secondary_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OBPostBodyText extends StatefulWidget {
  final Post post;
  final OnTextExpandedChange? onTextExpandedChange;

  OBPostBodyText(this.post, {this.onTextExpandedChange}) : super();

  @override
  OBPostBodyTextState createState() {
    return OBPostBodyTextState();
  }
}

class OBPostBodyTextState extends State<OBPostBodyText> {
  static const int MAX_LENGTH_LIMIT = 1300;

  late ToastService _toastService;
  late UserService _userService;
  late LocalizationService _localizationService;
  String? _translatedText;
  late bool _translationInProgress;
  late bool _needsBootstrap;

  @override
  void initState() {
    super.initState();
    _translationInProgress = false;
    _translatedText = null;
    _needsBootstrap = true;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_needsBootstrap) {
      OpenbookProviderState openbookProvider = OpenbookProvider.of(context);
      _toastService = openbookProvider.toastService;
      _userService = openbookProvider.userService;
      _localizationService = openbookProvider.localizationService;
      _needsBootstrap = false;
    }

    return GestureDetector(
      onLongPress: _copyText,
      child: _buildFullPostText(),
    );
  }

  Widget _buildFullPostText() {
    return StreamBuilder(
        stream: widget.post.updateSubject,
        initialData: widget.post,
        builder: (BuildContext context, AsyncSnapshot<Post> snapshot) {
          return _buildPostText();
        });
  }

  Widget _buildPostText() {
    return Padding(
        padding: EdgeInsets.only(top: 10, left: 20, right: 20),
        child: _buildActionablePostText());
  }

  Future<String> _translatePostText() async {
    late String translatedText;
    try {
      _setTranslationInProgress(true);
      translatedText = await _userService.translatePost(post: widget.post);
    } catch (error) {
      _onError(error);
    } finally {
      _setTranslationInProgress(false);
    }
    return translatedText;
  }

  Widget _buildActionablePostText() {
    if (widget.post.isEdited != null && widget.post.isEdited!) {
      return OBCollapsibleSmartText(
        text: _translatedText != null ? _translatedText : widget.post.text,
        trailingSmartTextElement: SecondaryTextElement(' (edited)'),
        maxlength: MAX_LENGTH_LIMIT,
        getChild: _buildTranslationButton,
        hashtagsMap: widget.post.hashtagsMap,
        links: widget.post.postLinksList?.postLinks,
      );
    } else {
      return OBCollapsibleSmartText(
        text: _translatedText != null ? _translatedText : widget.post.text,
        maxlength: MAX_LENGTH_LIMIT,
        getChild: _buildTranslationButton,
        hashtagsMap: widget.post.hashtagsMap,
        links: widget.post.postLinksList?.postLinks,
      );
    }
  }

  Widget _buildTranslationButton() {
    if (_userService.getLoggedInUser() != null &&
        !_userService.getLoggedInUser()!.canTranslatePost(widget.post)) {
      return SizedBox();
    }

    if (_translationInProgress) {
      return Padding(
          padding: EdgeInsets.all(10.0),
          child: Container(
            width: 10.0,
            height: 10.0,
            child: CircularProgressIndicator(strokeWidth: 2.0),
          ));
    }

    return GestureDetector(
      onTap: () async {
        if (_translatedText == null) {
          String translatedText = await _translatePostText();
          _setTranslatedText(translatedText);
        } else {
          _setTranslatedText(null);
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: _translatedText != null
            ? OBSecondaryText(
                _localizationService.trans('user__translate_show_original'),
                size: OBTextSize.large)
            : OBSecondaryText(
                _localizationService.trans('user__translate_see_translation'),
                size: OBTextSize.large),
      ),
    );
  }

  void _copyText() {
    Clipboard.setData(ClipboardData(text: widget.post.text));
    _toastService.toast(
        message: _localizationService.post__text_copied,
        context: context,
        type: ToastType.info);
  }

  void _onError(error) async {
    if (error is HttpieConnectionRefusedError) {
      _toastService.error(
          message: error.toHumanReadableMessage(), context: context);
    } else if (error is HttpieRequestError) {
    } else {
      _toastService.error(
          message: _localizationService.error__unknown_error, context: context);
      throw error;
    }
  }

  void _setTranslationInProgress(bool translationInProgress) {
    setState(() {
      _translationInProgress = translationInProgress;
    });
  }

  void _setTranslatedText(String? translatedText) {
    setState(() {
      _translatedText = translatedText;
    });
  }
}

typedef void OnTextExpandedChange(
    {required Post post, required bool isExpanded});
