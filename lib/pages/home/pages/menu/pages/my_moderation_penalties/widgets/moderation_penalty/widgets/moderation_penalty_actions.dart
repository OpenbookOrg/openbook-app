import 'package:Okuna/models/community.dart';
import 'package:Okuna/models/moderation/moderated_object.dart';
import 'package:Okuna/models/moderation/moderation_penalty.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/widgets/buttons/button.dart';
import 'package:Okuna/widgets/icon.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:flutter/material.dart';

class OBModerationPenaltyActions extends StatelessWidget {
  final ModerationPenalty moderationPenalty;

  OBModerationPenaltyActions({required this.moderationPenalty});

  @override
  Widget build(BuildContext context) {
    LocalizationService _localizationService = OpenbookProvider.of(context).localizationService;

    List<Widget> moderationPenaltyActions = [
      Expanded(
          child: OBButton(
              type: OBButtonType.highlight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const OBIcon(
                    OBIcons.chat,
                    customSize: 20.0,
                  ),
                  const SizedBox(
                    width: 10.0,
                  ),
                  OBText(_localizationService.trans('moderation__actions_chat_with_team')),
                ],
              ),
              onPressed: () {
                OpenbookProviderState openbookProvider =
                    OpenbookProvider.of(context);
                openbookProvider.intercomService.displayMessenger();
              })),
    ];

    return Padding(
        padding: EdgeInsets.only(left: 20.0, top: 10.0, right: 20.0),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.max,
              children: moderationPenaltyActions,
            )
          ],
        ));
  }
}
