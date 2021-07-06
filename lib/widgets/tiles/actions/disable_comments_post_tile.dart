import 'package:Okuna/models/post.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/httpie.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/toast.dart';
import 'package:Okuna/services/user.dart';
import 'package:Okuna/widgets/icon.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:flutter/material.dart';

class OBDisableCommentsPostTile extends StatefulWidget {
  final Post post;
  final VoidCallback? onDisableComments;
  final VoidCallback? onEnableComments;

  const OBDisableCommentsPostTile({
    Key? key,
    required this.post,
    this.onDisableComments,
    this.onEnableComments,
  }) : super(key: key);

  @override
  OBDisableCommentsPostTileState createState() {
    return OBDisableCommentsPostTileState();
  }
}

class OBDisableCommentsPostTileState extends State<OBDisableCommentsPostTile> {
  late UserService _userService;
  late ToastService _toastService;
  late LocalizationService _localizationService;
  late bool _requestInProgress;

  @override
  void initState() {
    super.initState();
    _requestInProgress = false;
  }

  @override
  Widget build(BuildContext context) {
    var openbookProvider = OpenbookProvider.of(context);
    _userService = openbookProvider.userService;
    _toastService = openbookProvider.toastService;
    _localizationService = openbookProvider.localizationService;

    return StreamBuilder(
      stream: widget.post.updateSubject,
      initialData: widget.post,
      builder: (BuildContext context, AsyncSnapshot<Post> snapshot) {
        var post = snapshot.data!;

        bool areCommentsEnabled = post.areCommentsEnabled ?? false;

        return ListTile(
          enabled: !_requestInProgress,
          leading: OBIcon(areCommentsEnabled ? OBIcons.disableComments : OBIcons.enableComments),
          title: OBText(areCommentsEnabled
              ? _localizationService.post__disable_post_comments
              : _localizationService.post__enable_post_comments),
          onTap: areCommentsEnabled ? _disableComments : _enableComments,
        );
      },
    );
  }

  void _enableComments() async {
    _setRequestInProgress(true);
    try {
      await _userService.enableCommentsForPost(widget.post);
      if (widget.onDisableComments != null) widget.onDisableComments!();
      _toastService.success(message: _localizationService.post__comments_enabled_message, context: context);
    } catch (e) {
      _onError(e);
    } finally {
      _setRequestInProgress(false);
    }
  }

  void _disableComments() async {
    _setRequestInProgress(true);
    try {
      await _userService.disableCommentsForPost(widget.post);
      if (widget.onEnableComments != null) widget.onEnableComments!();
      _toastService.success(message: _localizationService.post__comments_disabled_message, context: context);
    } catch (e) {
      _onError(e);
    } finally {
      _setRequestInProgress(false);
    }
  }

  void _onError(error) async {
    if (error is HttpieConnectionRefusedError) {
      _toastService.error(
          message: error.toHumanReadableMessage(), context: context);
    } else if (error is HttpieRequestError) {
      String? errorMessage = await error.toHumanReadableMessage();
      _toastService.error(message: errorMessage ?? _localizationService.error__unknown_error, context: context);
    } else {
      _toastService.error(message: _localizationService.error__unknown_error, context: context);
      throw error;
    }
  }

  void _setRequestInProgress(bool requestInProgress) {
    setState(() {
      _requestInProgress = requestInProgress;
    });
  }
}
