import 'package:Okuna/models/community.dart';
import 'package:Okuna/models/theme.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/theme.dart';
import 'package:Okuna/services/theme_value_parser.dart';
import 'package:Okuna/widgets/progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:tinycolor/tinycolor.dart';

class OBCommunityButton extends StatelessWidget {
  final Community community;
  final bool isLoading;
  final String text;
  final VoidCallback onPressed;

  static const borderRadius = 30.0;

  const OBCommunityButton(
      {Key? key,
      this.isLoading = false,
      required this.community,
      required this.text,
      required this.onPressed})
      : super(key: key);

  Widget build(BuildContext context) {
    String communityHexColor = community.color!;
    OpenbookProviderState openbookProviderState = OpenbookProvider.of(context);
    ThemeValueParserService themeValueParserService =
        openbookProviderState.themeValueParserService;
    ThemeService themeService = openbookProviderState.themeService;

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

    return ButtonTheme(
      minWidth: 110,
      child: RaisedButton(
          elevation: 0,
          child: isLoading
              ? _buildLoadingIndicatorWithColor(textColor)
              : Text(
                  text,
                  style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
          color: communityColor,
          onPressed: onPressed,
          shape: new RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius))),
    );
  }

  Widget _buildLoadingIndicatorWithColor(Color color) {
    return OBProgressIndicator(
      color: color,
    );
  }
}
