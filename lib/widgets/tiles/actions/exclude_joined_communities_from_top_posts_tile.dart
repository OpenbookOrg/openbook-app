import 'package:Okuna/provider.dart';
import 'package:Okuna/services/explore_timeline_preferences.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/widgets/fields/toggle_field.dart';
import 'package:Okuna/widgets/theming/secondary_text.dart';
import 'package:flutter/material.dart';


class OBExcludeJoinedCommunitiesTile extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    var provider = OpenbookProvider.of(context);
    LocalizationService localizationService = provider.localizationService;
    ExploreTimelinePreferencesService exploreTimelinePreferencesService = provider.exploreTimelinePreferencesService;

    return FutureBuilder(
      future: exploreTimelinePreferencesService.getExcludeJoinedCommunitiesSetting(),
      builder:
          (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.data == null) return const SizedBox();

        return StreamBuilder(
          stream: exploreTimelinePreferencesService.excludeJoinedCommunitiesSettingChange,
          initialData: snapshot.data,
          builder: (BuildContext context,
              AsyncSnapshot<bool> snapshot) {
            bool currentExcludeJoinedCommunitiesSetting = snapshot.data!;

            return OBToggleField(
              key: Key('toggleExcludeJoinedCommunities'),
              value: currentExcludeJoinedCommunitiesSetting,
              title: localizationService
                  .community__exclude_joined_communities,
              subtitle: OBSecondaryText(localizationService.community__exclude_joined_communities_desc),
              onChanged: (bool value) {
                exploreTimelinePreferencesService.setExcludeJoinedCommunitiesSetting(!currentExcludeJoinedCommunitiesSetting);
              },
              hasDivider: false,
            );
          },
        );
      },
    );
  }
}
