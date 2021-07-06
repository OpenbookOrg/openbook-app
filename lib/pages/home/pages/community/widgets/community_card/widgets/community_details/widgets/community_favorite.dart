import 'package:Okuna/models/community.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/widgets/icon.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:flutter/material.dart';

import '../../../../../../../../../provider.dart';

class OBCommunityFavorite extends StatelessWidget {
  final Community community;

  const OBCommunityFavorite(this.community);

  @override
  Widget build(BuildContext context) {
    LocalizationService localizationService = OpenbookProvider.of(context).localizationService;

    return StreamBuilder(
      stream: community.updateSubject,
      initialData: community,
      builder: (BuildContext context, AsyncSnapshot<Community> snapshot) {
        Community community = snapshot.data!;
        if (community.isFavorite == null || !community.isFavorite!)
          return const SizedBox();

        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            OBIcon(
              OBIcons.favoriteCommunity,
              themeColor: OBIconThemeColor.primaryAccent,
              size: OBIconSize.small,
            ),
            const SizedBox(
              width: 10,
            ),
            OBText(
              localizationService.community__details_favorite,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(
              width: 10,
            ),
          ],
        );
      },
    );
  }
}
