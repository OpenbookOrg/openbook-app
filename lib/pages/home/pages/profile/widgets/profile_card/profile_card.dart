import 'package:Okuna/models/badge.dart';
import 'package:Okuna/models/community.dart';
import 'package:Okuna/models/theme.dart';
import 'package:Okuna/models/user.dart';
import 'package:Okuna/pages/home/pages/profile/widgets/profile_card/widgets/profile_actions/profile_inline_actions.dart';
import 'package:Okuna/pages/home/pages/profile/widgets/profile_card/widgets/profile_bio.dart';
import 'package:Okuna/pages/home/pages/profile/widgets/profile_card/widgets/profile_connected_in.dart';
import 'package:Okuna/pages/home/pages/profile/widgets/profile_card/widgets/profile_connection_request.dart';
import 'package:Okuna/pages/home/pages/profile/widgets/profile_card/widgets/profile_counts/profile_counts.dart';
import 'package:Okuna/pages/home/pages/profile/widgets/profile_card/widgets/profile_details/profile_details.dart';
import 'package:Okuna/pages/home/pages/profile/widgets/profile_card/widgets/profile_follow_request.dart';
import 'package:Okuna/pages/home/pages/profile/widgets/profile_card/widgets/profile_in_lists.dart';
import 'package:Okuna/pages/home/pages/profile/widgets/profile_card/widgets/profile_name.dart';
import 'package:Okuna/pages/home/pages/profile/widgets/profile_card/widgets/profile_username.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/toast.dart';
import 'package:Okuna/widgets/avatars/avatar.dart';
import 'package:Okuna/widgets/user_badge.dart';
import 'package:flutter/material.dart';

class OBProfileCard extends StatelessWidget {
  final User user;
  final VoidCallback? onUserProfileUpdated;
  final ValueChanged<Community>? onExcludedCommunityRemoved;
  final ValueChanged<List<Community>>? onExcludedCommunitiesAdded;

  const OBProfileCard(
    this.user, {
    Key? key,
    this.onUserProfileUpdated,
    this.onExcludedCommunityRemoved,
    this.onExcludedCommunitiesAdded,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var openbookProvider = OpenbookProvider.of(context);
    var themeService = openbookProvider.themeService;
    var themeValueParserService = openbookProvider.themeValueParserService;
    var toastService = openbookProvider.toastService;

    return Stack(
      overflow: Overflow.visible,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 18.0, right: 18),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Row(
                children: <Widget>[
                  const SizedBox(
                    height: (OBAvatar.AVATAR_SIZE_EXTRA_LARGE * 0.2),
                    width: OBAvatar.AVATAR_SIZE_EXTRA_LARGE,
                  ),
                  Expanded(
                      child: OBProfileInlineActions(user,
                          onUserProfileUpdated: onUserProfileUpdated,
                          onExcludedCommunityRemoved:
                              onExcludedCommunityRemoved,
                          onExcludedCommunitiesAdded:
                              onExcludedCommunitiesAdded)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(
                    height: 20,
                  ),
                  _buildNameRow(
                      user: user, context: context, toastService: toastService),
                  OBProfileUsername(user),
                  OBProfileBio(user),
                  OBProfileDetails(user),
                  OBProfileCounts(user),
                  OBProfileConnectedIn(user),
                  OBProfileConnectionRequest(user),
                  OBProfileFollowRequest(user),
                  OBProfileInLists(user)
                ],
              ),
            ],
          ),
        ),
        Positioned(
          child: StreamBuilder(
              stream: themeService.themeChange,
              initialData: themeService.getActiveTheme(),
              builder: (BuildContext context, AsyncSnapshot<OBTheme> snapshot) {
                var theme = snapshot.data;

                return Container(
                  height: 20,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      color: themeValueParserService
                          .parseColor(theme!.primaryColor),
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(50),
                          topRight: Radius.circular(50))),
                );
              }),
          top: -19,
        ),
        Positioned(
          top: -((OBAvatar.AVATAR_SIZE_EXTRA_LARGE / 2)) - 10,
          left: 18,
          child: StreamBuilder(
              stream: user.updateSubject,
              initialData: user,
              builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
                var user = snapshot.data;

                return OBAvatar(
                  borderWidth: 3,
                  avatarUrl: user?.getProfileAvatar(),
                  size: OBAvatarSize.extraLarge,
                  isZoomable: true,
                );
              }),
        ),
      ],
    );
  }

  Widget _buildNameRow(
      {required User user,
      required BuildContext context,
      required ToastService toastService}) {
    if (user.hasProfileBadges() && user.getProfileBadges()!.length > 0) {
      return Row(children: <Widget>[
        OBProfileName(user),
        _getUserBadge(user: user, toastService: toastService, context: context)
      ]);
    }
    return OBProfileName(user);
  }

  Widget _getUserBadge(
      {required User user,
      required ToastService toastService,
      required BuildContext context}) {
    Badge badge = user.getProfileBadges()![0];
    return GestureDetector(
      onTap: () {
        toastService.info(
            message: _getUserBadgeDescription(user), context: context);
      },
      child: OBUserBadge(badge: badge, size: OBUserBadgeSize.small),
    );
  }

  String _getUserBadgeDescription(User user) {
    Badge badge = user.getProfileBadges()![0];
    return badge.getKeywordDescription()!;
  }
}
