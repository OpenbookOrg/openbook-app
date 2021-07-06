import 'package:Okuna/models/theme.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:flutter/material.dart';

class OBSecondaryText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final OBTextSize? size;
  final TextOverflow? overflow;
  final TextAlign? textAlign;
  final int? maxLines;

  const OBSecondaryText(this.text,
      {this.style, this.size, this.overflow, this.textAlign, this.maxLines});

  @override
  Widget build(BuildContext context) {
    var openbookProvider = OpenbookProvider.of(context);
    var themeService = openbookProvider.themeService;
    var themeValueParserService = openbookProvider.themeValueParserService;

    return StreamBuilder(
        stream: themeService.themeChange,
        initialData: themeService.getActiveTheme(),
        builder: (BuildContext context, AsyncSnapshot<OBTheme> snapshot) {
          var theme = snapshot.data;

          TextStyle? finalStyle = style;
          TextStyle themedTextStyle = TextStyle(
              color:
                  themeValueParserService.parseColor(theme!.secondaryTextColor));

          if (finalStyle != null) {
            finalStyle = finalStyle.merge(themedTextStyle);
          } else {
            finalStyle = themedTextStyle;
          }

          return OBText(
            text,
            style: finalStyle,
            size: size ?? OBTextSize.medium,
            overflow: overflow,
            maxLines: maxLines,
            textAlign: textAlign,
          );
        });
  }
}
