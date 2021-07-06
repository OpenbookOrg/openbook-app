import 'package:Okuna/models/post.dart';
import 'package:Okuna/models/post_comment.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/httpie.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/toast.dart';
import 'package:Okuna/services/user.dart';
import 'package:Okuna/widgets/icon.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:Okuna/widgets/tiles/loading_tile.dart';
import 'package:flutter/material.dart';

class OBMutePostCommentTile extends StatefulWidget {
  final Post post;
  final PostComment postComment;
  final VoidCallback? onMutedPostComment;
  final VoidCallback? onUnmutedPostComment;

  const OBMutePostCommentTile({
    Key? key,
    required this.postComment,
    this.onMutedPostComment,
    this.onUnmutedPostComment,
    required this.post,
  }) : super(key: key);

  @override
  OBMutePostCommentTileState createState() {
    return OBMutePostCommentTileState();
  }
}

class OBMutePostCommentTileState extends State<OBMutePostCommentTile> {
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
      stream: widget.postComment.updateSubject,
      initialData: widget.postComment,
      builder: (BuildContext context, AsyncSnapshot<PostComment> snapshot) {
        var postComment = snapshot.data;

        bool isMuted = postComment?.isMuted ?? false;

        return OBLoadingTile(
          isLoading: _requestInProgress,
          leading: OBIcon(
              isMuted ? OBIcons.unmutePostComment : OBIcons.mutePostComment),
          title: OBText(isMuted
              ? _localizationService.notifications__mute_post_turn_on_post_comment_notifications
              : _localizationService.notifications__mute_post_turn_off_post_comment_notifications),
          onTap: isMuted ? _unmutePostComment : _mutePostComment,
        );
      },
    );
  }

  void _mutePostComment() async {
    _setRequestInProgress(true);
    try {
      await _userService.mutePostComment(
          post: widget.post, postComment: widget.postComment);
      widget.postComment.setIsMuted(true);
      if (widget.onMutedPostComment != null) widget.onMutedPostComment!();
    } catch (e) {
      _onError(e);
    } finally {
      _setRequestInProgress(false);
    }
  }

  void _unmutePostComment() async {
    _setRequestInProgress(true);
    try {
      await _userService.unmutePostComment(
          post: widget.post, postComment: widget.postComment);
      widget.postComment.setIsMuted(false);
      if (widget.onUnmutedPostComment != null) widget.onUnmutedPostComment!();
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
