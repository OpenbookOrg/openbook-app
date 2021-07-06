import 'package:Okuna/models/notifications/follow_request_approved_notification.dart';
import 'package:Okuna/models/notifications/notification.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/widgets/avatars/avatar.dart';
import 'package:Okuna/widgets/theming/secondary_text.dart';
import 'package:flutter/material.dart';

import 'notification_tile_skeleton.dart';
import 'notification_tile_title.dart';

class OBFollowRequestApprovedNotificationTile extends StatelessWidget {
  final OBNotification notification;
  final FollowRequestApprovedNotification followRequestApprovedNotification;
  final VoidCallback? onPressed;

  const OBFollowRequestApprovedNotificationTile(
      {Key? key,
      required this.notification,
      required this.followRequestApprovedNotification,
      this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    OpenbookProviderState openbookProvider = OpenbookProvider.of(context);
    var utilsService = openbookProvider.utilsService;

    var navigateToConfirmatorProfile = () {
      if (onPressed != null) onPressed!();
      OpenbookProviderState openbookProvider = OpenbookProvider.of(context);
      openbookProvider.navigationService.navigateToUserProfile(
          user: followRequestApprovedNotification.follow!.followedUser!,
          context: context);
    };
    LocalizationService _localizationService = OpenbookProvider.of(context).localizationService;

    return OBNotificationTileSkeleton(
      onTap: navigateToConfirmatorProfile,
      leading: OBAvatar(
        size: OBAvatarSize.medium,
        avatarUrl: followRequestApprovedNotification.follow!.followedUser!
            .getProfileAvatar(),
      ),
      title: OBNotificationTileTitle(
        onUsernamePressed: navigateToConfirmatorProfile,
        user: followRequestApprovedNotification.follow!.followedUser,
        text: TextSpan(text: _localizationService.notifications__approved_follow_request_tile),
      ),
      subtitle: OBSecondaryText(utilsService.timeAgo(notification.created!, _localizationService)),
    );
  }
}
