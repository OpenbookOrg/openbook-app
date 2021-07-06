import 'package:Okuna/models/notifications/notification.dart';
import 'package:Okuna/models/notifications/user_new_post_notification.dart';
import 'package:Okuna/models/post.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/widgets/avatars/avatar.dart';
import 'package:Okuna/widgets/theming/secondary_text.dart';
import 'package:Okuna/widgets/tiles/notification_tile/notification_tile_post_media_preview.dart';
import 'package:flutter/material.dart';

import 'notification_tile_skeleton.dart';
import 'notification_tile_title.dart';

class OBUserNewPostNotificationTile extends StatelessWidget {
  final OBNotification notification;
  final UserNewPostNotification userNewPostNotification;
  static final double postImagePreviewSize = 40;
  final VoidCallback? onPressed;

  const OBUserNewPostNotificationTile(
      {Key? key,
      required this.notification,
      required this.userNewPostNotification,
      this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Post post = userNewPostNotification.post!;

    Widget? postImagePreview;
    if (post.hasMediaThumbnail()) {
      postImagePreview = OBNotificationTilePostMediaPreview(
        post: post,
      );
    }
    OpenbookProviderState openbookProvider = OpenbookProvider.of(context);
    var utilsService = openbookProvider.utilsService;

    VoidCallback navigateToCreatorProfile = () {
      openbookProvider.navigationService.navigateToUserProfile(
          user: userNewPostNotification.post!.creator!, context: context);
    };
    LocalizationService _localizationService =
        openbookProvider.localizationService;

    VoidCallback onTileTapped = () {
      if (onPressed != null) onPressed!();
      OpenbookProviderState openbookProvider = OpenbookProvider.of(context);
      openbookProvider.navigationService
          .navigateToPost(post: userNewPostNotification.post!, context: context);
    };
    return OBNotificationTileSkeleton(
      onTap: onTileTapped,
      leading: OBAvatar(
        onPressed: navigateToCreatorProfile,
        size: OBAvatarSize.medium,
        avatarUrl: userNewPostNotification.post!.creator!.getProfileAvatar(),
      ),
      title: OBNotificationTileTitle(
        onUsernamePressed: navigateToCreatorProfile,
        user: userNewPostNotification.post!.creator,
        text: TextSpan(text: _localizationService.notifications__user_new_post_tile),
      ),
      trailing: postImagePreview,
      subtitle: OBSecondaryText(
          utilsService.timeAgo(notification.created!, _localizationService)),
    );
  }
}
