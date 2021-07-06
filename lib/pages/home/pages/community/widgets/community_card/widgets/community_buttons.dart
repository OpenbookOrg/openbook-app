import 'package:Okuna/models/community.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/widgets/buttons/button.dart';
import 'package:Okuna/widgets/icon.dart';
import 'package:flutter/material.dart';

class OBCommunityButtons extends StatelessWidget {
  final Community community;

  const OBCommunityButtons({Key? key, required this.community}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> communityButtons = [];
    OpenbookProviderState openbookProvider = OpenbookProvider.of(context);
    LocalizationService localizationService = openbookProvider.localizationService;
    communityButtons.add(
      OBButton(
        child: Row(
          children: <Widget>[
            const OBIcon(OBIcons.communityStaff, size: OBIconSize.small,),
            const SizedBox(
              width: 10,
            ),
            Text(localizationService.trans('community__button_staff'))
          ],
        ),
        onPressed: () async {
          openbookProvider.navigationService.navigateToCommunityStaffPage(
              context: context, community: community);
        },
        type: OBButtonType.highlight,
      ),
    );

    if (community.rules != null && community.rules!.isNotEmpty) {
      communityButtons.add(
        OBButton(
          child: Row(
            children: <Widget>[
              const OBIcon(OBIcons.rules, size: OBIconSize.small,),
              const SizedBox(
                width: 10,
              ),
              Text(localizationService.trans('community__button_rules'))
            ],
          ),
          onPressed: () async {
            openbookProvider.navigationService.navigateToCommunityRulesPage(
                context: context, community: community);
          },
          type: OBButtonType.highlight,
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: SizedBox(
        height: 35,
        child: ListView.separated(
          itemCount: communityButtons.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (BuildContext context, index) {
            return communityButtons[index];
          },
          separatorBuilder: (BuildContext context, index) {
            return const SizedBox(
              width: 10,
            );
          },
        ),
      ),
    );
  }
}
