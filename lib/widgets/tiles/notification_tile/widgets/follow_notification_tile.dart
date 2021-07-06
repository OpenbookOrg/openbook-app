import 'package:Okuna/models/notifications/follow_notification.dart';
import 'package:Okuna/models/notifications/notification.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/widgets/avatars/avatar.dart';
import 'package:Okuna/widgets/theming/secondary_text.dart';
import 'package:flutter/material.dart';

import 'notification_tile_skeleton.dart';
import 'notification_tile_title.dart';

class OBFollowNotificationTile extends StatelessWidget {
  final OBNotification notification;
  final FollowNotification followNotification;
  final VoidCallback? onPressed;

  const OBFollowNotificationTile(
      {Key? key,
      required this.notification,
      required this.followNotification,
      this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    OpenbookProviderState openbookProvider = OpenbookProvider.of(context);
    var utilsService = openbookProvider.utilsService;

    var navigateToFollowerProfile = () {
      if (onPressed != null) onPressed!();
      openbookProvider.navigationService.navigateToUserProfile(
          user: followNotification.follower!, context: context);
    };
    LocalizationService _localizationService = OpenbookProvider.of(context).localizationService;

    return OBNotificationTileSkeleton(
      onTap: navigateToFollowerProfile,
      leading: OBAvatar(
        size: OBAvatarSize.medium,
        avatarUrl: followNotification.follower!.getProfileAvatar(),
      ),
      title: OBNotificationTileTitle(
        onUsernamePressed: navigateToFollowerProfile,
        user: followNotification.follower,
        text: TextSpan(text: _localizationService.notifications__following_you_tile),
      ),
      subtitle: OBSecondaryText(utilsService.timeAgo(notification.created!, _localizationService)),
    );
  }
}
