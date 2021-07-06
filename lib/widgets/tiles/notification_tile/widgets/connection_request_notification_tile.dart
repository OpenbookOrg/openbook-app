import 'package:Okuna/models/notifications/connection_request_notification.dart';
import 'package:Okuna/models/notifications/notification.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/widgets/avatars/avatar.dart';
import 'package:Okuna/widgets/theming/secondary_text.dart';
import 'package:flutter/material.dart';

import 'notification_tile_skeleton.dart';
import 'notification_tile_title.dart';

class OBConnectionRequestNotificationTile extends StatelessWidget {
  final OBNotification notification;
  final ConnectionRequestNotification connectionRequestNotification;
  final VoidCallback? onPressed;

  const OBConnectionRequestNotificationTile(
      {Key? key,
      required this.notification,
      required this.connectionRequestNotification,
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
          user: connectionRequestNotification.connectionRequester!,
          context: context);
    };

    return OBNotificationTileSkeleton(
      onTap: navigateToRequesterProfile,
      leading: OBAvatar(
        size: OBAvatarSize.medium,
        avatarUrl: connectionRequestNotification.connectionRequester!
            .getProfileAvatar(),
      ),
      title: OBNotificationTileTitle(
          onUsernamePressed: navigateToRequesterProfile,
          user: connectionRequestNotification.connectionRequester,
          text: TextSpan(
            text: _localizationService.notifications__connection_request_tile,
          )),
      subtitle: OBSecondaryText(utilsService.timeAgo(notification.created!, _localizationService)),
    );
  }
}
