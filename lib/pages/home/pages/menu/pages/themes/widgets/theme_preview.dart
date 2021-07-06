import 'package:Okuna/models/theme.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:flutter/material.dart';

class OBThemePreview extends StatelessWidget {
  static const maxWidth = 120.0;
  final OBTheme theme;
  final OnThemePreviewPressed? onThemePreviewPressed;

  OBThemePreview(this.theme, {this.onThemePreviewPressed});

  @override
  Widget build(BuildContext context) {
    var openbookProvider = OpenbookProvider.of(context);
    var themeService = openbookProvider.themeService;
    var themeValueParserService = openbookProvider.themeValueParserService;

    return StreamBuilder(
        stream: themeService.themeChange,
        initialData: themeService.getActiveTheme(),
        builder: (BuildContext context, AsyncSnapshot<OBTheme> snapshot) {
          bool isActiveTheme = themeService.isActiveTheme(theme);
          Color activeColor = themeValueParserService
              .parseGradient(theme.primaryAccentColor)
              .colors[0];

          double previewSize = 40;
          return GestureDetector(
            onTap: () {
              if (this.onThemePreviewPressed != null) {
                this.onThemePreviewPressed!(theme);
              }
            },
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: 70, maxWidth: maxWidth),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                      height: previewSize,
                      width: previewSize,
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: isActiveTheme
                                  ? activeColor
                                  : Color.fromARGB(10, 0, 0, 0),
                              width: 3),
                          borderRadius: BorderRadius.circular(50)),
                      child: theme.themePreview == null
                        ? SizedBox()
                        : ClipRRect(
                          borderRadius: BorderRadius.circular(50.0),
                          child: Image.asset(theme.themePreview!),
                        )),
                  const SizedBox(
                    height: 10,
                  ),
                  OBText(
                    theme.name ?? '<unknown>',
                    size: OBTextSize.small,
                    maxLines: 3,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
          );
        });
  }
}

typedef void OnThemePreviewPressed(OBTheme theme);
