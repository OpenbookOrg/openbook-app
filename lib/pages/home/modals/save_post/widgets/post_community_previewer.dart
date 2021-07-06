import 'dart:io';

import 'package:Okuna/models/community.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/widgets/alerts/alert.dart';
import 'package:Okuna/widgets/avatars/community_avatar.dart';
import 'package:Okuna/widgets/theming/secondary_text.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:Okuna/widgets/tiles/community_tile.dart';
import 'package:flutter/material.dart';

import '../../../../../provider.dart';

class OBPostCommunityPreviewer extends StatelessWidget {
  final Community community;

  const OBPostCommunityPreviewer({Key? key, required this.community})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    LocalizationService localizationService = OpenbookProvider.of(context).localizationService;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        OBSecondaryText(localizationService.post__sharing_post_to),
        const SizedBox(
          height: 10,
        ),
        OBCommunityTile(
          community,
          size: OBCommunityTileSize.small,
        )
      ],
    );
  }
}
