import 'package:Okuna/models/notifications/notification.dart';
import 'package:Okuna/models/notifications/post_reaction_notification.dart';
import 'package:Okuna/models/post.dart';
import 'package:Okuna/models/post_reaction.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/widgets/avatars/avatar.dart';
import 'package:Okuna/widgets/emoji_picker/widgets/emoji_groups/widgets/emoji_group/widgets/emoji.dart';
import 'package:Okuna/widgets/theming/secondary_text.dart';
import 'package:Okuna/widgets/tiles/notification_tile/notification_tile_post_media_preview.dart';
import 'package:flutter/material.dart';

import 'notification_tile_skeleton.dart';
import 'notification_tile_title.dart';

class OBPostReactionNotificationTile extends StatelessWidget {
  final OBNotification notification;
  final PostReactionNotification postReactionNotification;
  static final double postImagePreviewSize = 40;
  final VoidCallback? onPressed;

  const OBPostReactionNotificationTile(
      {Key? key,
      required this.notification,
      required this.postReactionNotification,
      this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    PostReaction postReaction = postReactionNotification.postReaction!;
    Post post = postReaction.post!;

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

    VoidCallback navigateToReactorProfile = () {
      openbookProvider.navigationService
          .navigateToUserProfile(user: postReaction.reactor!, context: context);
    };

    return OBNotificationTileSkeleton(
      onTap: () {
        if (onPressed != null) onPressed!();
        OpenbookProviderState openbookProvider = OpenbookProvider.of(context);
        openbookProvider.navigationService
            .navigateToPost(post: postReaction.post!, context: context);
      },
      leading: OBAvatar(
        onPressed: navigateToReactorProfile,
        size: OBAvatarSize.medium,
        avatarUrl: postReaction.reactor!.getProfileAvatar(),
      ),
      title: OBNotificationTileTitle(
        text: TextSpan(
            text: _localizationService.notifications__reacted_to_post_tile),
        onUsernamePressed: navigateToReactorProfile,
        user: postReaction.reactor,
      ),
      subtitle: OBSecondaryText(
          utilsService.timeAgo(notification.created!, _localizationService)),
      trailing: Row(
        children: <Widget>[
          OBEmoji(
            postReaction.emoji!,
          ),
          postImagePreview ?? const SizedBox()
        ],
      ),
    );
  }
}
