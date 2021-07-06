import 'package:Okuna/models/post.dart';
import 'package:Okuna/models/post_comment.dart';
import 'package:Okuna/models/user.dart';
import 'package:Okuna/pages/home/bottom_sheets/rounded_bottom_sheet.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/bottom_sheet.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/modal_service.dart';
import 'package:Okuna/services/navigation_service.dart';
import 'package:Okuna/services/toast.dart';
import 'package:Okuna/services/user.dart';
import 'package:Okuna/widgets/icon.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:Okuna/widgets/tiles/actions/mute_post_comment_tile.dart';
import 'package:async/async.dart';
import 'package:flutter/material.dart';

class OBPostCommentMoreActionsBottomSheet extends StatefulWidget {
  final PostComment postComment;
  final Post post;
  final ValueChanged<PostComment> onPostCommentDeleted;
  final ValueChanged<PostComment> onPostCommentReported;

  const OBPostCommentMoreActionsBottomSheet({
    required this.post,
    required this.postComment,
    Key? key,
    required this.onPostCommentDeleted,
    required this.onPostCommentReported,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return OBPostCommentMoreActionsBottomSheetState();
  }
}

class OBPostCommentMoreActionsBottomSheetState
    extends State<OBPostCommentMoreActionsBottomSheet> {
  late ToastService _toastService;
  late UserService _userService;
  late NavigationService _navigationService;
  late LocalizationService _localizationService;
  late ModalService _modalService;
  late BottomSheetService _bottomSheetService;
  late bool _requestInProgress;
  CancelableOperation? _requestOperation;

  @override
  void initState() {
    _requestInProgress = false;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    if (_requestOperation != null) _requestOperation!.cancel();
  }

  @override
  Widget build(BuildContext context) {
    OpenbookProviderState provider = OpenbookProvider.of(context);
    _toastService = provider.toastService;
    _userService = provider.userService;
    _navigationService = provider.navigationService;
    _localizationService = provider.localizationService;
    _modalService = provider.modalService;
    _bottomSheetService = provider.bottomSheetService;

    return OBRoundedBottomSheet(
      child: Opacity(
        opacity: _requestInProgress ? 0.5 : 1,
        child: Column(
          children: _buildActionTiles(),
          mainAxisSize: MainAxisSize.min,
        ),
      ),
    );
  }

  List<Widget> _buildActionTiles() {
    List<Widget> actionTiles = [
      OBMutePostCommentTile(
        postComment: widget.postComment,
        post: widget.post,
      )
    ];
    User loggedInUser = _userService.getLoggedInUser()!;

    if (loggedInUser.canReportPostComment(widget.postComment)) {
      actionTiles.add(
        Opacity(
          opacity: widget.postComment.isReported ?? false ? 0.5 : 1,
          child: ListTile(
            leading: const OBIcon(OBIcons.report),
            title: OBText(widget.postComment.isReported ?? false
                ? _localizationService.post__actions_reported_text
                : _localizationService.post__actions_report_text),
            onTap: _reportPostComment,
          ),
        ),
      );
    }

    if (loggedInUser.canEditPostComment(widget.postComment, widget.post)) {
      actionTiles.add(
        ListTile(
          leading: const OBIcon(OBIcons.edit),
          title: OBText(
            _localizationService.post__actions_edit_comment,
          ),
          onTap: _editPostComment,
        ),
      );
    }

    if (loggedInUser.canDeletePostComment(widget.post, widget.postComment)) {
      actionTiles.add(
        ListTile(
          leading: const OBIcon(OBIcons.deletePost),
          title: OBText(
            _localizationService.post__actions_delete_comment,
          ),
          onTap: _onWantsToDeletePostComment,
        ),
      );
    }

    return actionTiles;
  }

  void _reportPostComment() async {
    _dismissMoreActions();
    await _navigationService.navigateToReportObject(
        context: context,
        object: widget.postComment,
        extraData: {'post': widget.post},
        onObjectReported: (dynamic reportedObject) {
          if (widget.onPostCommentReported != null && reportedObject != null)
            widget.onPostCommentReported(reportedObject as PostComment);
        });
  }

  Future _onWantsToDeletePostComment() async {
    if (_requestInProgress) return;
    _setRequestInProgress(true);
    _bottomSheetService.showConfirmAction(
        context: context,
        subtitle: _localizationService.post__actions_delete_comment_description,
        actionCompleter: (BuildContext context) async {
          await _userService.deletePostComment(
              postComment: widget.postComment, post: widget.post);
          _toastService.success(
              message: _localizationService.post__actions_comment_deleted,
              context: context);
          if (widget.postComment.parentComment == null)
            widget.post.decreaseCommentsCount();
          if (widget.onPostCommentDeleted != null) {
            widget.onPostCommentDeleted(widget.postComment);
          }
        });
  }

  void _editPostComment() async {
    _dismissMoreActions();
    await _modalService.openExpandedCommenter(
        context: context, post: widget.post, postComment: widget.postComment);
  }

  void _setRequestInProgress(bool requestInProgress) {
    setState(() {
      _requestInProgress = requestInProgress;
    });
  }

  void _dismissMoreActions() {
    _bottomSheetService.dismissActiveBottomSheet(context: context);
  }
}
