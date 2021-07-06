import 'package:Okuna/models/community.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/widgets/icon.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:flutter/material.dart';

import '../../../../../../../../../provider.dart';

class OBCommunityType extends StatelessWidget {
  final Community community;

  const OBCommunityType(this.community);

  @override
  Widget build(BuildContext context) {
    CommunityType? type = community.type;
    LocalizationService localizationService = OpenbookProvider.of(context).localizationService;

    if (type == null) {
      return const SizedBox();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        OBIcon(
          type == CommunityType.private ? OBIcons.privateCommunity : OBIcons.publicCommunity,
          customSize: 16,
        ),
        const SizedBox(
          width: 10,
        ),
        Flexible(
          child: OBText(
            type == CommunityType.private ? localizationService.community__type_private : localizationService.community__type_public,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(
          width: 10,
        ),
      ],
    );
  }
}
