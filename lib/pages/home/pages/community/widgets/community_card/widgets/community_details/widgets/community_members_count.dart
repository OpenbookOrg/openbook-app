import 'package:Okuna/libs/pretty_count.dart';
import 'package:Okuna/models/theme.dart';
import 'package:Okuna/models/community.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/localization.dart';
import 'package:flutter/material.dart';

class OBCommunityMembersCount extends StatelessWidget {
  final Community community;

  OBCommunityMembersCount(this.community);

  @override
  Widget build(BuildContext context) {
    int? membersCount = community.membersCount;
    LocalizationService localizationService = OpenbookProvider.of(context).localizationService;

    if (membersCount == null || membersCount == 0) return const SizedBox();

    String count = getPrettyCount(membersCount, localizationService);

    String userAdjective = community.userAdjective ?? localizationService.community__member_capitalized;
    String usersAdjective = community.usersAdjective ?? localizationService.community__members_capitalized;

    var openbookProvider = OpenbookProvider.of(context);
    var themeService = openbookProvider.themeService;
    var themeValueParserService = openbookProvider.themeValueParserService;
    var userService = openbookProvider.userService;
    var navigationService = openbookProvider.navigationService;

    return StreamBuilder(
        stream: themeService.themeChange,
        initialData: themeService.getActiveTheme(),
        builder: (BuildContext context, AsyncSnapshot<OBTheme> snapshot) {
          var theme = snapshot.data;

          return GestureDetector(
            onTap: () {
              bool isPublicCommunity = community.isPublic();
              bool isLoggedInUserMember =
                  community.isMember(userService.getLoggedInUser()!);

              if (isPublicCommunity || isLoggedInUserMember) {
                navigationService.navigateToCommunityMembers(
                    community: community, context: context);
              }
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Flexible(
                  child: RichText(
                      text: TextSpan(children: [
                    TextSpan(
                        text: count,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: themeValueParserService
                                .parseColor(theme!.primaryTextColor))),
                    TextSpan(text: ' '),
                    TextSpan(
                        text:
                            membersCount == 1 ? userAdjective : usersAdjective,
                        style: TextStyle(
                            fontSize: 16,
                            color: themeValueParserService
                                .parseColor(theme.secondaryTextColor)))
                  ])),
                ),
                const SizedBox(
                  width: 10,
                ),
              ],
            ),
          );
        });
  }
}
