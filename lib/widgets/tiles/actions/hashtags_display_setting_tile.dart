import 'package:Okuna/provider.dart';
import 'package:Okuna/services/bottom_sheet.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/user_preferences.dart';
import 'package:Okuna/widgets/icon.dart';
import 'package:Okuna/widgets/theming/primary_accent_text.dart';
import 'package:Okuna/widgets/theming/secondary_text.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:flutter/material.dart';

class OBHashtagsDisplaySettingTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    OpenbookProviderState provider = OpenbookProvider.of(context);

    LocalizationService localizationService = provider.localizationService;
    UserPreferencesService userPreferencesService =
        provider.userPreferencesService;
    BottomSheetService bottomSheetService = provider.bottomSheetService;

    Map<HashtagsDisplaySetting, String> hashtagsDisplaySettingsLocalizationMap =
        userPreferencesService.getHashtagsDisplaySettingLocalizationMap();

    return FutureBuilder(
      future: userPreferencesService.getHashtagsDisplaySetting(),
      builder:
          (BuildContext context, AsyncSnapshot<HashtagsDisplaySetting?> snapshot) {
        if (snapshot.data == null) return const SizedBox();

        return StreamBuilder(
          stream: userPreferencesService.hashtagsDisplaySettingChange,
          initialData: snapshot.data,
          builder: (BuildContext context,
              AsyncSnapshot<HashtagsDisplaySetting> snapshot) {
            HashtagsDisplaySetting currentHashtagsDisplaySetting = snapshot.data!;

            return MergeSemantics(
              child: ListTile(
                leading: OBIcon(OBIcons.hashtag),
                  title: OBText(
                    localizationService.application_settings__hashtags_display,
                  ),
                  subtitle: OBSecondaryText(
                      localizationService.application_settings__tap_to_change, size: OBTextSize.small,),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      OBPrimaryAccentText(
                        hashtagsDisplaySettingsLocalizationMap[
                            currentHashtagsDisplaySetting]!,
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  onTap: () {
                    bottomSheetService.showHashtagsDisplaySettingPicker(
                        initialValue: currentHashtagsDisplaySetting,
                        context: context,
                        onChanged: (HashtagsDisplaySetting newHashtagsDisplaySetting) {
                          userPreferencesService
                              .setHashtagsDisplaySetting(newHashtagsDisplaySetting);
                        });
                  }),
            );
          },
        );
      },
    );
  }
}
