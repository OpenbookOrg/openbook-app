import 'package:Okuna/models/category.dart';
import 'package:Okuna/models/theme.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/theme_value_parser.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OBCategoryBadge extends StatelessWidget {
  final Category category;
  final OBCategoryBadgeSize size;
  final bool isEnabled;
  final ValueChanged<Category>? onPressed;

  const OBCategoryBadge({
    Key? key,
    required this.category,
    this.size = OBCategoryBadgeSize.medium,
    this.isEnabled = true,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return isEnabled
        ? _buildEnabledBadge(context)
        : _buildDisabledBadge(context);
  }

  Widget _buildDisabledBadge(BuildContext context) {
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
              themeValueParserService.isDarkColor(primaryColor);

          return _buildBadge(
              color: isDarkPrimaryColor
                  ? Color.fromARGB(20, 255, 255, 255)
                  : Color.fromARGB(10, 0, 0, 0),
              textColor: isDarkPrimaryColor ? Colors.white : Colors.black);
        });
  }

  Widget _buildEnabledBadge(BuildContext context) {
    ThemeValueParserService themeValueParserService =
        OpenbookProvider.of(context).themeValueParserService;
    Color badgeColor = themeValueParserService.parseColor(category.color!);
    final bool badgeIsDark = themeValueParserService.isDarkColor(badgeColor);

    return _buildBadge(
        color: badgeColor,
        textColor: badgeIsDark ? Colors.white : Colors.black);
  }

  Widget _buildBadge({required Color color, required Color textColor}) {
    return GestureDetector(
      onTap: _onTapped,
      child: Container(
        decoration:
            BoxDecoration(color: color, borderRadius: BorderRadius.circular(5)),
        padding: _getPadding(),
        child: Text(
          category.name!,
          style: TextStyle(
              color: textColor,
              //fontWeight: isEnabled ? FontWeight.bold : FontWeight.normal,
              fontSize: _getFontSize()),
        ),
      ),
    );
  }

  EdgeInsets _getPadding() {
    EdgeInsets padding;

    switch (size) {
      case OBCategoryBadgeSize.small:
        padding = const EdgeInsets.symmetric(horizontal: 6, vertical: 2);
        break;
      case OBCategoryBadgeSize.medium:
        padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 3);
        break;
      case OBCategoryBadgeSize.large:
        padding = const EdgeInsets.symmetric(horizontal: 15, vertical: 6);
        break;
      default:
        throw 'Unhandled category badge size';
    }

    return padding;
  }

  double _getFontSize() {
    double fontSize;

    switch (size) {
      case OBCategoryBadgeSize.small:
        fontSize = 14;
        break;
      case OBCategoryBadgeSize.medium:
        fontSize = 16;
        break;
      case OBCategoryBadgeSize.large:
        fontSize = 18;
        break;
      default:
        throw 'Unhandled category badge size';
    }

    return fontSize;
  }

  void _onTapped() {
    if (onPressed != null) onPressed!(category);
  }
}

enum OBCategoryBadgeSize { medium, large, small }
