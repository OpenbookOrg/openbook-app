import 'package:Okuna/models/community.dart';
import 'package:Okuna/models/user.dart';
import 'package:Okuna/pages/home/pages/profile/widgets/profile_card/widgets/profile_actions/widgets/profile_inline_action_more_button.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/navigation_service.dart';
import 'package:Okuna/widgets/buttons/actions/block_button.dart';
import 'package:Okuna/widgets/buttons/button.dart';
import 'package:Okuna/widgets/buttons/actions/follow_button.dart';
import 'package:flutter/material.dart';

class OBProfileInlineActions extends StatelessWidget {
  final User user;
  final VoidCallback? onUserProfileUpdated;
  final ValueChanged<Community>? onExcludedCommunityRemoved;
  final ValueChanged<List<Community>>? onExcludedCommunitiesAdded;

  const OBProfileInlineActions(this.user,
      {required this.onUserProfileUpdated,
      this.onExcludedCommunityRemoved,
      this.onExcludedCommunitiesAdded});

  @override
  Widget build(BuildContext context) {
    var openbookProvider = OpenbookProvider.of(context);
    var userService = openbookProvider.userService;
    var navigationService = openbookProvider.navigationService;
    LocalizationService localizationService =
        openbookProvider.localizationService;

    return StreamBuilder(
      stream: user.updateSubject,
      initialData: user,
      builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
        bool isLoggedInUser = userService.isLoggedInUser(user);

        List<Widget> actions = [];

        if (isLoggedInUser) {
          actions.add(Padding(
            // The margin compensates for the height of the (missing) OBProfileActionMore
            // Fixes cut-off Edit profile button, and level out layout distances
            padding: EdgeInsets.only(top: 6.5, bottom: 6.5),
            child: _buildManageButton(
                navigationService, localizationService, context),
          ));
        } else {
          bool isBlocked = user.isBlocked ?? false;
          if (isBlocked) {
            actions.add(OBBlockButton(user));
          } else {
            actions.add(
              OBFollowButton(user),
            );
          }

          actions.addAll([
            const SizedBox(
              width: 10,
            ),
            OBProfileInlineActionsMoreButton(user)
          ]);
        }
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: actions,
        );
      },
    );
  }

  _buildManageButton(NavigationService navigationService,
      LocalizationService localizationService, context) {
    return OBButton(
        child: Text(
          localizationService.user__manage,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          navigationService.navigateToManageProfile(
              user: user,
              context: context,
              onUserProfileUpdated: onUserProfileUpdated,
              onExcludedCommunitiesAdded: onExcludedCommunitiesAdded,
              onExcludedCommunityRemoved: onExcludedCommunityRemoved);
        });
  }
}
