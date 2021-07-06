import 'package:Okuna/models/community.dart';
import 'package:Okuna/models/community_invite.dart';
import 'package:Okuna/models/notifications/community_invite_notification.dart';
import 'package:Okuna/models/notifications/notification.dart';
import 'package:Okuna/models/user.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/widgets/avatars/avatar.dart';
import 'package:Okuna/widgets/avatars/community_avatar.dart';
import 'package:Okuna/widgets/theming/secondary_text.dart';
import 'package:flutter/material.dart';

import 'notification_tile_skeleton.dart';
import 'notification_tile_title.dart';

class OBCommunityInviteNotificationTile extends StatelessWidget {
  final OBNotification notification;
  final CommunityInviteNotification communityInviteNotification;
  final VoidCallback? onPressed;
  static final double postImagePreviewSize = 40;

  const OBCommunityInviteNotificationTile(
      {Key? key,
      required this.notification,
      required this.communityInviteNotification,
      this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    CommunityInvite communityInvite =
        communityInviteNotification.communityInvite!;
    User inviteCreator = communityInvite.creator!;
    Community community = communityInvite.community!;

    String communityName = community.name!;

    OpenbookProviderState openbookProvider = OpenbookProvider.of(context);
    var utilsService = openbookProvider.utilsService;

    VoidCallback navigateToInviteCreatorProfile = () {
      openbookProvider.navigationService
          .navigateToUserProfile(user: inviteCreator, context: context);
    };
    LocalizationService _localizationService = openbookProvider.localizationService;

    return OBNotificationTileSkeleton(
      onTap: () {
        if (onPressed != null) onPressed!();
        OpenbookProviderState openbookProvider = OpenbookProvider.of(context);

        openbookProvider.navigationService
            .navigateToCommunity(community: community, context: context);
      },
      leading: OBAvatar(
        onPressed: navigateToInviteCreatorProfile,
        size: OBAvatarSize.medium,
        avatarUrl: inviteCreator.getProfileAvatar(),
      ),
      title: OBNotificationTileTitle(
        user: inviteCreator,
        onUsernamePressed: navigateToInviteCreatorProfile,
        text: TextSpan(
            text: _localizationService.notifications__user_community_invite_tile(communityName)),
      ),
      trailing: OBCommunityAvatar(
        community: community,
        size: OBAvatarSize.medium,
      ),
      subtitle: OBSecondaryText(utilsService.timeAgo(notification.created!, _localizationService)),
    );
  }
}
