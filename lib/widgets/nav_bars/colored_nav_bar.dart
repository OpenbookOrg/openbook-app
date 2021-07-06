import 'package:Okuna/provider.dart';
import 'package:Okuna/services/theme_value_parser.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// A coloured navigation bar, used in communities.
class OBColoredNavBar extends StatelessWidget
    implements ObstructingPreferredSizeWidget {
  final Color color;
  final Color? textColor;
  final Color? actionsColor;
  final Widget? leading;
  final Widget? middle;
  final Widget? trailing;
  final String? title;

  const OBColoredNavBar(
      {Key? key,
      required this.color,
      this.leading,
      this.trailing,
      this.title,
      this.textColor,
      this.actionsColor,
      this.middle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeValueParserService themeValueParserService =
        OpenbookProvider.of(context).themeValueParserService;
    bool isDarkColor = themeValueParserService.isDarkColor(color);
    Color finalActionsColor =
        actionsColor ?? (isDarkColor ? Colors.white : Colors.black);

    CupertinoThemeData themeData = CupertinoTheme.of(context);

    return CupertinoTheme(
      data: themeData.copyWith(
          primaryColor: finalActionsColor,
          textTheme: CupertinoTextThemeData(
            primaryColor:
                finalActionsColor, //change color of the TOP navbar icon
          )),
      child: CupertinoNavigationBar(
          border: null,
          leading: leading,
          middle: middle ??
              Text(
                title ?? '',
                style: TextStyle(color: textColor ?? finalActionsColor),
              ),
          transitionBetweenRoutes: false,
          backgroundColor: color,
          trailing: trailing),
    );
  }

  @override
  bool get fullObstruction => true;

  @override
  Size get preferredSize {
    return const Size.fromHeight(44);
  }

  @override
  bool shouldFullyObstruct(BuildContext context) {
    return true;
  }
}
