import 'package:Okuna/models/community.dart';
import 'package:Okuna/models/user.dart';
import 'package:Okuna/pages/home/pages/community/widgets/community_card/widgets/community_actions/widgets/community_action_more/community_action_more.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/navigation_service.dart';
import 'package:Okuna/services/user.dart';
import 'package:Okuna/widgets/buttons/actions/join_community_button.dart';
import 'package:Okuna/widgets/buttons/community_button.dart';
import 'package:flutter/material.dart';

class OBCommunityActions extends StatelessWidget {
  final Community? community;

  OBCommunityActions(this.community);

  @override
  Widget build(BuildContext context) {
    var openbookProvider = OpenbookProvider.of(context);
    NavigationService navigationService = openbookProvider.navigationService;
    UserService userService = openbookProvider.userService;
    LocalizationService localizationService = openbookProvider.localizationService;

    User loggedInUser = userService.getLoggedInUser()!;

    bool isCommunityAdmin = community?.isAdministrator(loggedInUser) ?? false;
    bool isCommunityModerator = community?.isModerator(loggedInUser) ?? false;

    List<Widget> actions = [];

    if (isCommunityAdmin || isCommunityModerator) {
      actions.add(_buildManageButton(navigationService, context, localizationService));
    } else {
      actions.addAll([
        OBJoinCommunityButton(community!),
        const SizedBox(
          width: 10,
        ),
        OBCommunityActionMore(community!)
      ]);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: actions,
    );
  }

  _buildManageButton(NavigationService navigationService, context, LocalizationService localizationService) {
    return OBCommunityButton(
        community: community!,
        isLoading: false,
        text: localizationService.community__actions_manage_text,
        onPressed: () {
          navigationService.navigateToManageCommunity(
              community: community!, context: context);
        });
  }
}
