import 'package:Okuna/models/post.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/httpie.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/toast.dart';
import 'package:Okuna/services/user.dart';
import 'package:Okuna/widgets/icon.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:Okuna/widgets/tiles/loading_tile.dart';
import 'package:flutter/material.dart';

class OBClosePostTile extends StatefulWidget {
  final Post post;
  final VoidCallback? onClosePost;
  final VoidCallback? onOpenPost;

  const OBClosePostTile({
    Key? key,
    required this.post,
    this.onClosePost,
    this.onOpenPost,
  }) : super(key: key);

  @override
  OBClosePostTileState createState() {
    return OBClosePostTileState();
  }
}

class OBClosePostTileState extends State<OBClosePostTile> {
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

        bool isPostClosed = post.isClosed ?? false;

        return OBLoadingTile(
          isLoading: _requestInProgress,
          leading: OBIcon(isPostClosed ? OBIcons.openPost : OBIcons.closePost),
          title: OBText(isPostClosed
              ? _localizationService.post__open_post
              : _localizationService.post__close_post),
          onTap: isPostClosed ? _openPost : _closePost,
        );
      },
    );
  }

  void _openPost() async {
    _setRequestInProgress(true);
    try {
      await _userService.openPost(widget.post);
      if (widget.onClosePost != null) widget.onClosePost!();
      _toastService.success(message: _localizationService.post__post_opened, context: context);
    } catch (e) {
      _onError(e);
    } finally {
      _setRequestInProgress(false);
    }
  }

  void _closePost() async {
    _setRequestInProgress(true);
    try {
      await _userService.closePost(widget.post);
      if (widget.onOpenPost != null) widget.onOpenPost!();
      _toastService.success(message: _localizationService.post__post_closed, context: context);
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
