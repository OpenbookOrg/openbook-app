import 'package:Okuna/models/community.dart';
import 'package:Okuna/models/theme.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/theme.dart';
import 'package:Okuna/services/theme_value_parser.dart';
import 'package:Okuna/widgets/buttons/button.dart';
import 'package:Okuna/widgets/buttons/floating_action_button.dart';
import 'package:Okuna/widgets/icon.dart';
import 'package:Okuna/widgets/new_post_data_uploader.dart';
import 'package:flutter/material.dart';
import 'package:tinycolor/tinycolor.dart';

class OBCommunityNewPostButton extends StatelessWidget {
  final bool isDisabled;
  final bool isLoading;
  final Color textColor;
  final OBButtonSize size;
  final double? minWidth;
  final EdgeInsets? padding;
  final OBButtonType type;
  final Community community;
  final ValueChanged<OBNewPostData>? onWantsToUploadNewPostData;

  const OBCommunityNewPostButton({
    this.type = OBButtonType.primary,
    this.size = OBButtonSize.medium,
    this.textColor = Colors.white,
    this.isDisabled = false,
    this.isLoading = false,
    this.padding,
    this.minWidth,
    required this.community,
    this.onWantsToUploadNewPostData,
  });

  Widget build(BuildContext context) {
    LocalizationService _localizationService =
        OpenbookProvider.of(context).localizationService;
    return StreamBuilder(
      stream: community.updateSubject,
      initialData: community,
      builder: (BuildContext context, AsyncSnapshot<Community> snapshot) {
        Community community = snapshot.data!;

        String communityHexColor = community.color!;
        OpenbookProviderState openbookProvider = OpenbookProvider.of(context);
        ThemeValueParserService themeValueParserService =
            openbookProvider.themeValueParserService;
        ThemeService themeService = openbookProvider.themeService;

        OBTheme currentTheme = themeService.getActiveTheme();
        Color currentThemePrimaryColor =
            themeValueParserService.parseColor(currentTheme.primaryColor);
        double currentThemePrimaryColorLuminance =
            currentThemePrimaryColor.computeLuminance();

        Color communityColor =
            themeValueParserService.parseColor(communityHexColor);
        Color textColor = themeValueParserService.isDarkColor(communityColor)
            ? Colors.white
            : Colors.black;
        double communityColorLuminance = communityColor.computeLuminance();

        if (communityColorLuminance > 0.9 &&
            currentThemePrimaryColorLuminance > 0.9) {
          // Is extremely white and our current theem is also extremely white, darken it
          communityColor = TinyColor(communityColor).darken(5).color;
        } else if (communityColorLuminance < 0.1) {
          // Is extremely dark and our current theme is also extremely dark, lighten it
          communityColor = TinyColor(communityColor).lighten(10).color;
        }

        return Semantics(
            button: true,
            label: _localizationService.post__create_new_community_post_label,
            child: OBFloatingActionButton(
                color: communityColor,
                textColor: textColor,
                onPressed: () async {
                  OpenbookProviderState openbookProvider =
                      OpenbookProvider.of(context);
                  OBNewPostData? createPostData = await openbookProvider
                      .modalService
                      .openCreatePost(context: context, community: community);
                  if (createPostData != null &&
                      onWantsToUploadNewPostData != null)
                    onWantsToUploadNewPostData!(createPostData);
                },
                child: OBIcon(OBIcons.createPost,
                    size: OBIconSize.large, color: textColor)));
      },
    );
  }
}
