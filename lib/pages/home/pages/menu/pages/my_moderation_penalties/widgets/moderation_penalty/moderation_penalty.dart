import 'package:Okuna/models/moderation/moderation_penalty.dart';
import 'package:Okuna/pages/home/pages/menu/pages/my_moderation_penalties/widgets/moderation_penalty/widgets/moderation_penalty_actions.dart';
import 'package:Okuna/pages/home/pages/moderated_objects/pages/widgets/moderated_object_category/moderated_object_category.dart';
import 'package:Okuna/pages/home/pages/moderated_objects/widgets/moderated_object/widgets/moderated_object_preview.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:Okuna/widgets/tile_group_title.dart';
import 'package:Okuna/widgets/tiles/moderated_object_status_tile.dart';
import 'package:flutter/material.dart';

class OBModerationPenaltyTile extends StatelessWidget {
  final ModerationPenalty moderationPenalty;

  const OBModerationPenaltyTile({Key? key, required this.moderationPenalty})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        OBTileGroupTitle(
          title: 'Object',
        ),
        OBModeratedObjectPreview(
          moderatedObject: moderationPenalty.moderatedObject!,
        ),
        const SizedBox(
          height: 10,
        ),
        OBModeratedObjectCategory(
          moderatedObject: moderationPenalty.moderatedObject!,
          isEditable: false,
        ),
        Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  OBTileGroupTitle(
                    title: 'Status',
                  ),
                  OBModeratedObjectStatusTile(
                    moderatedObject: moderationPenalty.moderatedObject!,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  OBTileGroupTitle(
                    title: 'Type',
                  ),
                  ListTile(
                    title: OBText(ModerationPenalty
                        .convertModerationPenaltyTypeToHumanReadableString(
                            moderationPenalty.type!,
                            capitalize: true)),
                  )
                ],
              ),
            )
          ],
        ),
        OBTileGroupTitle(
          title: 'Expiration',
        ),
        ListTile(
          title: OBText(moderationPenalty.expiration.toString()),
        ),
        OBModerationPenaltyActions(
          moderationPenalty: moderationPenalty,
        )
      ],
    );
  }
}
