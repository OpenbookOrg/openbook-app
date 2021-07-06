import 'package:Okuna/models/theme.dart';
import 'package:Okuna/provider.dart';
import 'package:flutter/material.dart';

class OBText extends StatelessWidget {
  static double getTextSize(OBTextSize size) {
    double fontSize;

    switch (size) {
      case OBTextSize.extraSmall:
        fontSize = 10;
        break;
      case OBTextSize.small:
        fontSize = 12;
        break;
      case OBTextSize.mediumSecondary:
        fontSize = 14;
        break;
      case OBTextSize.medium:
        fontSize = 16;
        break;
      case OBTextSize.large:
        fontSize = 17;
        break;
      case OBTextSize.extraLarge:
        fontSize = 30;
    }

    return fontSize;
  }

  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;
  final OBTextSize size;

  const OBText(this.text,
      {this.style,
      this.textAlign,
      this.overflow,
      this.maxLines,
      this.size = OBTextSize.medium});

  @override
  Widget build(BuildContext context) {
    var openbookProvider = OpenbookProvider.of(context);
    var themeService = openbookProvider.themeService;
    var themeValueParserService = openbookProvider.themeValueParserService;

    double fontSize = getTextSize(size);

    return StreamBuilder(
        stream: themeService.themeChange,
        initialData: themeService.getActiveTheme(),
        builder: (BuildContext context, AsyncSnapshot<OBTheme> snapshot) {
          var theme = snapshot.data;

          TextStyle themedTextStyle = TextStyle(
              color: themeValueParserService.parseColor(theme!.primaryTextColor),
              fontFamilyFallback: ['NunitoSans'],
              fontSize: (style != null && style!.fontSize != null)
                  ? style!.fontSize
                  : fontSize);

          if (style != null) {
            themedTextStyle = themedTextStyle.merge(style);
          }

          return Text(
            text,
            style: themedTextStyle,
            overflow: overflow,
            maxLines: maxLines,
            textAlign: textAlign,
          );
        });
  }
}

enum OBTextSize {
  extraSmall,
  small,
  mediumSecondary,
  medium,
  large,
  extraLarge
}
