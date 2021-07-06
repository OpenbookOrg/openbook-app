import 'package:Okuna/provider.dart';
import 'package:Okuna/services/bottom_sheet.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/user_preferences.dart';
import 'package:Okuna/widgets/icon.dart';
import 'package:Okuna/widgets/theming/primary_accent_text.dart';
import 'package:Okuna/widgets/theming/secondary_text.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:flutter/material.dart';

class OBVideosAutoPlaySettingTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    OpenbookProviderState provider = OpenbookProvider.of(context);

    LocalizationService localizationService = provider.localizationService;
    UserPreferencesService userPreferencesService =
        provider.userPreferencesService;
    BottomSheetService bottomSheetService = provider.bottomSheetService;

    Map<VideosAutoPlaySetting, String> videosAutoPlaySettingsLocalizationMap =
        userPreferencesService.getVideosAutoPlaySettingLocalizationMap();

    return FutureBuilder(
      future: userPreferencesService.getVideosAutoPlaySetting(),
      builder:
          (BuildContext context, AsyncSnapshot<VideosAutoPlaySetting?> snapshot) {
        if (snapshot.data == null) return const SizedBox();

        return StreamBuilder(
          stream: userPreferencesService.videosAutoPlaySettingChange,
          initialData: snapshot.data,
          builder: (BuildContext context,
              AsyncSnapshot<VideosAutoPlaySetting> snapshot) {
            VideosAutoPlaySetting currentVideosAutoPlaySetting = snapshot.data!;

            return MergeSemantics(
              child: ListTile(
                leading: OBIcon(OBIcons.play_arrow),
                  title: OBText(
                    localizationService.application_settings__videos_autoplay,
                  ),
                  subtitle: OBSecondaryText(
                      localizationService.application_settings__tap_to_change, size: OBTextSize.small,),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      OBPrimaryAccentText(
                        videosAutoPlaySettingsLocalizationMap[
                            currentVideosAutoPlaySetting]!,
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  onTap: () {
                    bottomSheetService.showVideosAutoPlaySettingPicker(
                        initialValue: currentVideosAutoPlaySetting,
                        context: context,
                        onChanged: (VideosAutoPlaySetting newVideosAutoPlaySetting) {
                          userPreferencesService
                              .setVideosAutoPlaySetting(newVideosAutoPlaySetting);
                        });
                  }),
            );
          },
        );
      },
    );
  }
}
