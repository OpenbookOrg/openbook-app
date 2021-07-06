import 'package:Okuna/models/community.dart';
import 'package:Okuna/models/post.dart';
import 'package:Okuna/models/user.dart';
import 'package:Okuna/pages/home/bottom_sheets/rounded_bottom_sheet.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/bottom_sheet.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/modal_service.dart';
import 'package:Okuna/services/toast.dart';
import 'package:Okuna/services/user.dart';
import 'package:Okuna/services/httpie.dart';
import 'package:Okuna/widgets/icon.dart';
import 'package:Okuna/widgets/post/post.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:Okuna/widgets/tiles/actions/close_post_tile.dart';
import 'package:Okuna/widgets/tiles/actions/disable_comments_post_tile.dart';
import 'package:Okuna/widgets/tiles/actions/exclude_community_from_profile_posts_tile.dart';
import 'package:Okuna/widgets/tiles/actions/exclude_community_from_top_posts_tile.dart';
import 'package:Okuna/widgets/tiles/actions/mute_post_tile.dart';
import 'package:Okuna/widgets/tiles/actions/report_post_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OBPostActionsBottomSheet extends StatefulWidget {
  final Post post;
  final ValueChanged<Post> onPostReported;
  final OnPostDeleted onPostDeleted;
  final Function? onCommunityExcluded;
  final Function? onUndoCommunityExcluded;
  final OBPostDisplayContext? displayContext;
  final ValueChanged<Community>? onPostCommunityExcludedFromProfilePosts;

  const OBPostActionsBottomSheet(
      {Key? key,
      required this.post,
      required this.onPostReported,
      required this.onPostDeleted,
      this.onCommunityExcluded,
      this.onUndoCommunityExcluded,
      this.displayContext = OBPostDisplayContext.timelinePosts,
      this.onPostCommunityExcludedFromProfilePosts})
      : super(key: key);

  @override
  OBPostActionsBottomSheetState createState() {
    return OBPostActionsBottomSheetState();
  }
}

class OBPostActionsBottomSheetState extends State<OBPostActionsBottomSheet> {
  late UserService _userService;
  late ModalService _modalService;
  late ToastService _toastService;
  late LocalizationService _localizationService;
  late BottomSheetService _bottomSheetService;

  @override
  Widget build(BuildContext context) {
    var openbookProvider = OpenbookProvider.of(context);
    _userService = openbookProvider.userService;
    _modalService = openbookProvider.modalService;
    _toastService = openbookProvider.toastService;
    _localizationService = openbookProvider.localizationService;
    _bottomSheetService = openbookProvider.bottomSheetService;

    User loggedInUser = _userService.getLoggedInUser()!;

    return StreamBuilder(
        stream: widget.post.updateSubject,
        initialData: widget.post,
        builder: (BuildContext context, AsyncSnapshot<Post> snapshot) {
          Post post = snapshot.data!;
          List<Widget> postActions = [];

          if (widget.displayContext == OBPostDisplayContext.topPosts) {
            postActions.add(OBExcludeCommunityFromTopPostsTile(
              post: post,
              onExcludedPostCommunity: () {
                if (widget.onCommunityExcluded != null) {
                  widget.onCommunityExcluded!(post.community);
                }
                _dismiss();
              },
              onUndoExcludedPostCommunity: () {
                if (widget.onUndoCommunityExcluded != null) {
                  widget.onUndoCommunityExcluded!(post.community);
                }
                _dismiss();
              },
            ));
          } else if (widget.displayContext ==
              OBPostDisplayContext.ownProfilePosts) {
            postActions.add(OBExcludeCommunityFromProfilePostsTile(
                post: post,
                onPostCommunityExcludedFromProfilePosts:
                    widget.onPostCommunityExcludedFromProfilePosts!));
          }

          postActions.add(OBMutePostTile(
            post: post,
            onMutedPost: _dismiss,
            onUnmutedPost: _dismiss,
          ));

          if (loggedInUser.canDisableOrEnableCommentsForPost(post)) {
            postActions.add(OBDisableCommentsPostTile(
              post: post,
              onDisableComments: _dismiss,
              onEnableComments: _dismiss,
            ));
          }

          if (loggedInUser.canCloseOrOpenPost(post)) {
            postActions.add(OBClosePostTile(
              post: post,
              onClosePost: _dismiss,
              onOpenPost: _dismiss,
            ));
          }

          if (loggedInUser.canEditPost(post)) {
            postActions.add(ListTile(
              leading: const OBIcon(OBIcons.editPost),
              title: OBText(
                _localizationService.post__edit_title,
              ),
              onTap: _onWantsToEditPost,
            ));
          }

          if (loggedInUser.canDeletePost(post)) {
            postActions.add(ListTile(
              leading: const OBIcon(OBIcons.deletePost),
              title: OBText(
                _localizationService.post__actions_delete,
              ),
              onTap: _onWantsToDeletePost,
            ));
          } else {
            postActions.add(OBReportPostTile(
              post: widget.post,
              onWantsToReportPost: _dismiss,
              onPostReported: widget.onPostReported,
            ));
          }

          return OBRoundedBottomSheet(
            child: Column(
              children: postActions,
              mainAxisSize: MainAxisSize.min,
            ),
          );
        });
  }

  Future _onWantsToDeletePost() async {
    _bottomSheetService.showConfirmAction(
        context: context,
        subtitle: _localizationService.post__actions_delete_description,
        actionCompleter: (BuildContext context) async {
          await _userService.deletePost(widget.post);
          _toastService.success(
              message: _localizationService.post__actions_deleted,
              context: context);
          widget.onPostDeleted(widget.post);
        });
  }

  Future _onWantsToEditPost() async {
    try {
      await _modalService.openEditPost(context: context, post: widget.post);
      _dismiss();
    } catch (error) {
      _onError(error);
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
      _toastService.error(
          message: _localizationService.error__unknown_error, context: context);
      throw error;
    }
  }

  void _dismiss() {
    _bottomSheetService.dismissActiveBottomSheet(context: context);
  }
}

typedef OnPostDeleted(Post post);
