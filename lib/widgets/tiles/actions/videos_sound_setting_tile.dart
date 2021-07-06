import 'package:Okuna/provider.dart';
import 'package:Okuna/services/bottom_sheet.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/user_preferences.dart';
import 'package:Okuna/widgets/icon.dart';
import 'package:Okuna/widgets/theming/primary_accent_text.dart';
import 'package:Okuna/widgets/theming/secondary_text.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:flutter/material.dart';

class OBVideosSoundSettingTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    OpenbookProviderState provider = OpenbookProvider.of(context);

    LocalizationService localizationService = provider.localizationService;
    UserPreferencesService userPreferencesService =
        provider.userPreferencesService;
    BottomSheetService bottomSheetService = provider.bottomSheetService;

    Map<VideosSoundSetting, String> videosSoundSettingsLocalizationMap =
        userPreferencesService.getVideosSoundSettingLocalizationMap();

    return FutureBuilder(
      future: userPreferencesService.getVideosSoundSetting(),
      builder:
          (BuildContext context, AsyncSnapshot<VideosSoundSetting?> snapshot) {
        if (snapshot.data == null) return const SizedBox();

        return StreamBuilder(
          stream: userPreferencesService.videosSoundSettingChange,
          initialData: snapshot.data,
          builder: (BuildContext context,
              AsyncSnapshot<VideosSoundSetting> snapshot) {
            VideosSoundSetting currentVideosSoundSetting = snapshot.data!;

            return MergeSemantics(
              child: ListTile(
                leading: OBIcon(OBIcons.sound),
                  title: OBText(
                    localizationService.application_settings__videos_sound,
                  ),
                  subtitle: OBSecondaryText(
                      localizationService.application_settings__tap_to_change, size: OBTextSize.small,),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      OBPrimaryAccentText(
                        videosSoundSettingsLocalizationMap[
                            currentVideosSoundSetting]!,
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  onTap: () {
                    bottomSheetService.showVideosSoundSettingPicker(
                        initialValue: currentVideosSoundSetting,
                        context: context,
                        onChanged: (VideosSoundSetting newVideosSoundSetting) {
                          userPreferencesService
                              .setVideosSoundSetting(newVideosSoundSetting);
                        });
                  }),
            );
          },
        );
      },
    );
  }
}
