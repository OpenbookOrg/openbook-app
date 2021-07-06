import 'package:Okuna/models/notifications/notification.dart';
import 'package:Okuna/models/notifications/post_user_mention_notification.dart';
import 'package:Okuna/models/post.dart';
import 'package:Okuna/models/post_user_mention.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/widgets/avatars/avatar.dart';
import 'package:Okuna/widgets/theming/secondary_text.dart';
import 'package:Okuna/widgets/tiles/notification_tile/notification_tile_post_media_preview.dart';
import 'package:flutter/material.dart';

import 'notification_tile_skeleton.dart';
import 'notification_tile_title.dart';

class OBPostUserMentionNotificationTile extends StatelessWidget {
  final OBNotification notification;
  final PostUserMentionNotification postUserMentionNotification;
  static final double postImagePreviewSize = 40;
  final VoidCallback? onPressed;

  const OBPostUserMentionNotificationTile(
      {Key? key,
      required this.notification,
      required this.postUserMentionNotification,
      this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    PostUserMention postUserMention =
        postUserMentionNotification.postUserMention!;
    Post post = postUserMention.post!;

    Widget? postImagePreview;
    if (post.hasMediaThumbnail()) {
      postImagePreview = OBNotificationTilePostMediaPreview(
        post: post,
      );
    }
    OpenbookProviderState openbookProvider = OpenbookProvider.of(context);
    var utilsService = openbookProvider.utilsService;

    VoidCallback navigateToMentionerProfile = () {
      openbookProvider.navigationService.navigateToUserProfile(
          user: postUserMention.post!.creator!, context: context);
    };
    LocalizationService _localizationService =
        openbookProvider.localizationService;

    VoidCallback onTileTapped = () {
      if (onPressed != null) onPressed!();
      OpenbookProviderState openbookProvider = OpenbookProvider.of(context);
      openbookProvider.navigationService
          .navigateToPost(post: postUserMention.post!, context: context);
    };
    return OBNotificationTileSkeleton(
      onTap: onTileTapped,
      leading: OBAvatar(
        onPressed: navigateToMentionerProfile,
        size: OBAvatarSize.medium,
        avatarUrl: postUserMention.post!.creator!.getProfileAvatar(),
      ),
      title: OBNotificationTileTitle(
        onUsernamePressed: navigateToMentionerProfile,
        user: postUserMention.post!.creator,
        text: TextSpan(
            text: _localizationService.notifications__mentioned_in_post_tile),
      ),
      trailing: postImagePreview,
      subtitle: OBSecondaryText(
          utilsService.timeAgo(notification.created!, _localizationService)),
    );
  }
}
