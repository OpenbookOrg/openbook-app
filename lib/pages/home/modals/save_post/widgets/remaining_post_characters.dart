import 'package:Okuna/models/theme.dart';
import 'package:Okuna/provider.dart';
import 'package:flutter/material.dart';

class OBRemainingPostCharacters extends StatelessWidget {
  final int maxCharacters;
  final int currentCharacters;

  const OBRemainingPostCharacters(
      {Key? key, required this.maxCharacters, required this.currentCharacters})
      : super(key: key);

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

          int remainingCharacters = maxCharacters - currentCharacters;
          bool exceededMaxCharacters = remainingCharacters < 0;

          return Text(
            remainingCharacters.toString(),
            style: TextStyle(
                fontSize: 12.0,
                color: exceededMaxCharacters
                    ? themeValueParserService.parseColor(theme!.dangerColor)
                    : themeValueParserService
                        .parseColor(theme!.primaryTextColor),
                fontWeight: exceededMaxCharacters
                    ? FontWeight.bold
                    : FontWeight.normal),
          );
        });
  }
}
