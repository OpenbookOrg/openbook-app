import 'package:Okuna/models/theme.dart';
import 'package:Okuna/provider.dart';
import 'package:flutter/material.dart';

class OBHighlightedColorContainer extends StatelessWidget {
  final Widget? child;
  final BoxDecoration? decoration;
  final MainAxisSize? mainAxisSize;

  const OBHighlightedColorContainer(
      {Key? key,
      this.child,
      this.decoration,
      this.mainAxisSize = MainAxisSize.max})
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

          var primaryColor =
              themeValueParserService.parseColor(theme!.primaryColor);
          final bool isDarkPrimaryColor =
              primaryColor.computeLuminance() < 0.179;

          final highlightedColor = isDarkPrimaryColor
              ? Color.fromARGB(30, 255, 255, 255)
              : Color.fromARGB(10, 0, 0, 0);

          Widget container = DecoratedBox(
              decoration: BoxDecoration(
                  color:
                      themeValueParserService.parseColor(theme.primaryColor),
                  borderRadius: decoration?.borderRadius),
              child: DecoratedBox(
                decoration: BoxDecoration(
                    color: highlightedColor,
                    borderRadius: decoration?.borderRadius),
                child: child,
              ));

          if (mainAxisSize == MainAxisSize.min) {
            return container;
          }

          return Column(
            mainAxisSize: mainAxisSize ?? MainAxisSize.max,
            children: <Widget>[Expanded(child: container)],
          );
        });
  }
}
