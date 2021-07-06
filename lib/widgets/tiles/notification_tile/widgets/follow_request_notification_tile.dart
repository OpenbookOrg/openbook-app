import 'package:Okuna/models/notifications/follow_request_notification.dart';
import 'package:Okuna/models/notifications/notification.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/widgets/avatars/avatar.dart';
import 'package:Okuna/widgets/theming/secondary_text.dart';
import 'package:flutter/material.dart';

import 'notification_tile_skeleton.dart';
import 'notification_tile_title.dart';

class OBFollowRequestNotificationTile extends StatelessWidget {
  final OBNotification notification;
  final FollowRequestNotification followRequestNotification;
  final VoidCallback? onPressed;

  const OBFollowRequestNotificationTile(
      {Key? key,
      required this.notification,
      required this.followRequestNotification,
      this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    OpenbookProviderState openbookProvider = OpenbookProvider.of(context);
    var utilsService = openbookProvider.utilsService;
    LocalizationService _localizationService = openbookProvider.localizationService;

    var navigateToRequesterProfile = () {
      if (onPressed != null) onPressed!();
      OpenbookProviderState openbookProvider = OpenbookProvider.of(context);

      openbookProvider.navigationService.navigateToUserProfile(
        user: followRequestNotification.followRequest!.creator!,
          context: context);
    };

    return OBNotificationTileSkeleton(
      onTap: navigateToRequesterProfile,
      leading: OBAvatar(
        size: OBAvatarSize.medium,
        avatarUrl: followRequestNotification.followRequest!.creator!
            .getProfileAvatar(),
      ),
      title: OBNotificationTileTitle(
          onUsernamePressed: navigateToRequesterProfile,
          user: followRequestNotification.followRequest!.creator,
          text: TextSpan(
            text: _localizationService.notifications__follow_request_tile,
          )),
      subtitle: OBSecondaryText(utilsService.timeAgo(notification.created!, _localizationService)),
    );
  }
}
