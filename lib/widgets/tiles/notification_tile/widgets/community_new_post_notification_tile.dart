import 'package:Okuna/models/notifications/community_new_post_notification.dart';
import 'package:Okuna/models/notifications/notification.dart';
import 'package:Okuna/models/post.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/widgets/avatars/avatar.dart';
import 'package:Okuna/widgets/avatars/community_avatar.dart';
import 'package:Okuna/widgets/theming/secondary_text.dart';
import 'package:Okuna/widgets/tiles/notification_tile/notification_tile_post_media_preview.dart';
import 'package:flutter/material.dart';

import 'notification_tile_skeleton.dart';
import 'notification_tile_title.dart';

class OBCommunityNewPostNotificationTile extends StatelessWidget {
  final OBNotification notification;
  final CommunityNewPostNotification communityNewPostNotification;
  static final double postImagePreviewSize = 40;
  final VoidCallback? onPressed;

  const OBCommunityNewPostNotificationTile(
      {Key? key,
      required this.notification,
      required this.communityNewPostNotification,
      this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Post post = communityNewPostNotification.post!;

    Widget? postImagePreview;
    if (post.hasMediaThumbnail()) {
      postImagePreview = Padding(
          padding: const EdgeInsets.only(left: 10),
          child: OBNotificationTilePostMediaPreview(
            post: post,
          ));
    }
    OpenbookProviderState openbookProvider = OpenbookProvider.of(context);
    var utilsService = openbookProvider.utilsService;
    LocalizationService _localizationService =
        openbookProvider.localizationService;

    VoidCallback navigateToCommunity = () {
      openbookProvider.navigationService
          .navigateToCommunity(community: post.community!, context: context);
    };

    return OBNotificationTileSkeleton(
      onTap: () {
        if (onPressed != null) onPressed!();
        OpenbookProviderState openbookProvider = OpenbookProvider.of(context);
        openbookProvider.navigationService
            .navigateToPost(post: post, context: context);
      },
      leading: OBCommunityAvatar(
        onPressed: navigateToCommunity,
        size: OBAvatarSize.medium,
        community: post.community!,
      ),
      title: OBNotificationTileTitle(
        text: TextSpan(
          text: _localizationService.notifications__community_new_post_tile(post.community!.name!)),
      ),
      subtitle: OBSecondaryText(
          utilsService.timeAgo(notification.created!, _localizationService)),
      trailing: postImagePreview,
    );
  }
}
