import 'package:Okuna/models/notifications/notification.dart';
import 'package:Okuna/models/notifications/post_comment_reply_notification.dart';
import 'package:Okuna/models/post.dart';
import 'package:Okuna/models/post_comment.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/widgets/avatars/avatar.dart';
import 'package:Okuna/widgets/theming/actionable_smart_text.dart';
import 'package:Okuna/widgets/theming/secondary_text.dart';
import 'package:Okuna/widgets/tiles/notification_tile/notification_tile_post_media_preview.dart';
import 'package:flutter/material.dart';
import 'notification_tile_skeleton.dart';
import 'notification_tile_title.dart';

class OBPostCommentReplyNotificationTile extends StatelessWidget {
  final OBNotification notification;
  final PostCommentReplyNotification postCommentNotification;
  static final double postImagePreviewSize = 40;
  final VoidCallback? onPressed;

  const OBPostCommentReplyNotificationTile(
      {Key? key,
      required this.notification,
      required this.postCommentNotification,
      this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    PostComment postComment = postCommentNotification.postComment!;
    PostComment parentComment = postComment.parentComment!;
    Post post = postComment.post!;
    String postCommentText = postComment.text!;

    int postCreatorId = postCommentNotification.getPostCreatorId()!;
    OpenbookProviderState openbookProvider = OpenbookProvider.of(context);
    LocalizationService localizationService = openbookProvider.localizationService;

    bool isOwnPostNotification =
        openbookProvider.userService.getLoggedInUser()?.id == postCreatorId;

    Widget? postImagePreview;
    if (post.hasMediaThumbnail()) {
      postImagePreview = OBNotificationTilePostMediaPreview(
        post: post,
      );
    }

    var utilsService = openbookProvider.utilsService;

    VoidCallback navigateToCommenterProfile = () {
      openbookProvider.navigationService
          .navigateToUserProfile(user: postComment.commenter!, context: context);
    };

    return OBNotificationTileSkeleton(
      onTap: () {
        if (onPressed != null) onPressed!();
        OpenbookProviderState openbookProvider = OpenbookProvider.of(context);

        openbookProvider.navigationService.navigateToPostCommentRepliesLinked(
            postComment: postComment,
            context: context,
            parentComment: parentComment);
      },
      leading: OBAvatar(
        onPressed: navigateToCommenterProfile,
        size: OBAvatarSize.medium,
        avatarUrl: postComment.commenter!.getProfileAvatar(),
      ),
      title: OBNotificationTileTitle(
        text: TextSpan(
            text: isOwnPostNotification
                ? localizationService.notifications__comment_reply_notification_tile_user_replied(postCommentText)
                : localizationService.notifications__comment_reply_notification_tile_user_also_replied(postCommentText)),
        onUsernamePressed: navigateToCommenterProfile,
        user: postComment.commenter,
      ),
      subtitle: OBSecondaryText(
        utilsService.timeAgo(notification.created!, localizationService),
        size: OBTextSize.small,
      ),
      trailing: postImagePreview ?? const SizedBox(),
    );
  }
}
