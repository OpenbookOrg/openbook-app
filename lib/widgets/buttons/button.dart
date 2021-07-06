import 'package:Okuna/models/theme.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/theme_value_parser.dart';
import 'package:flutter/material.dart';

class OBButton extends StatelessWidget {
  final Widget child;
  final Widget? icon;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPressed;
  final bool isDisabled;
  final bool isLoading;
  final OBButtonSize? size;
  final double? minWidth;
  final EdgeInsets? padding;
  final OBButtonType type;
  final ShapeBorder? shape;
  final double? minHeight;
  final List<BoxShadow>? boxShadow;
  final TextStyle? textStyle;
  final Color? color;
  final Color? textColor;

  const OBButton(
      {required this.child,
      required this.onPressed,
      this.minHeight,
      this.minWidth,
      this.type = OBButtonType.primary,
      this.icon,
      this.size = OBButtonSize.medium,
      this.shape,
      this.boxShadow,
      this.isDisabled = false,
      this.isLoading = false,
      this.padding,
      this.textStyle,
      this.color,
      this.textColor, this.onLongPressed});

  @override
  Widget build(BuildContext context) {
    var provider = OpenbookProvider.of(context);
    var themeService = provider.themeService;
    var themeValueParser = provider.themeValueParserService;

    return color != null
        ? _buildButton(color: color!, textColor: textColor!)
        : StreamBuilder(
            stream: themeService.themeChange,
            initialData: themeService.getActiveTheme(),
            builder: (BuildContext context, AsyncSnapshot<OBTheme> snapshot) {
              var theme = snapshot.data;
              Color buttonTextColor = _getButtonTextColorForType(type,
                  themeValueParser: themeValueParser, theme: theme!);
              Gradient gradient = _getButtonGradientForType(type,
                  themeValueParser: themeValueParser, theme: theme);

              return _buildButton(
                  gradient: gradient, textColor: buttonTextColor);
            });
  }

  Widget _buildButton(
      {Gradient? gradient, Color? color, required Color textColor}) {
    EdgeInsets buttonPadding = _getButtonPaddingForSize(size!);
    double buttonMinWidth = minWidth ?? _getButtonMinWidthForSize(size!);
    double buttonMinHeight = minHeight ?? 20;
    var finalOnPressed = isLoading || isDisabled ? () {} : onPressed;
    var finalOnLongPressed = isLoading || isDisabled ? () {} : onLongPressed;

    var buttonChild = isLoading ? _getLoadingIndicator(textColor) : child;

    if (isDisabled) buttonChild = Opacity(opacity: 0.5, child: buttonChild);

    if (icon != null && !isLoading) {
      buttonChild = Row(
        children: <Widget>[
          icon!,
          const SizedBox(
            width: 5,
          ),
          buttonChild
        ],
      );
    }

    TextStyle defaultTextStyle =
        _getButtonTextStyleForSize(size: size!, color: textColor);

    if (textStyle != null) {
      defaultTextStyle = defaultTextStyle.merge(textStyle);
    }

    return GestureDetector(
      child: Container(
          constraints: BoxConstraints(
              minWidth: buttonMinWidth, minHeight: buttonMinHeight),
          decoration: BoxDecoration(
              boxShadow: boxShadow ?? [],
              gradient: gradient,
              color: color,
              borderRadius: BorderRadius.circular(50.0)),
          child: Material(
            color: Colors.transparent,
            textStyle: defaultTextStyle,
            child: Padding(
              padding: buttonPadding,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[buttonChild],
              ),
            ),
          )),
      onTap: finalOnPressed,
      onLongPress: finalOnLongPressed,
    );
  }

  Widget _getLoadingIndicator(Color color) {
    return SizedBox(
      height: 18.0,
      width: 18.0,
      child: CircularProgressIndicator(
          strokeWidth: 2.0, valueColor: AlwaysStoppedAnimation<Color>(color)),
    );
  }

  Gradient _getButtonGradientForType(OBButtonType type,
      {required ThemeValueParserService themeValueParser,
      required OBTheme theme}) {
    late Gradient buttonGradient;

    switch (type) {
      case OBButtonType.danger:
        buttonGradient = themeValueParser.parseGradient(theme.dangerColor);
        break;
      case OBButtonType.primary:
        buttonGradient =
            themeValueParser.parseGradient(theme.primaryAccentColor);
        break;
      case OBButtonType.success:
        buttonGradient = themeValueParser.parseGradient(theme.successColor);
        break;
      case OBButtonType.highlight:
        Color primaryColor = themeValueParser.parseColor(theme.primaryColor);
        final bool isDarkPrimaryColor = primaryColor.computeLuminance() < 0.179;
        Color gradientColor = isDarkPrimaryColor
            ? Color.fromARGB(30, 255, 255, 255)
            : Color.fromARGB(10, 0, 0, 0);

        buttonGradient = themeValueParser
            .makeGradientWithColors([gradientColor, gradientColor]);
        break;
      default:
    }

    return buttonGradient;
  }

  Color _getButtonTextColorForType(OBButtonType type,
      {required ThemeValueParserService themeValueParser,
      required OBTheme theme}) {
    late Color buttonTextColor;

    switch (type) {
      case OBButtonType.danger:
        buttonTextColor = themeValueParser.parseColor(theme.dangerColorAccent);
        break;
      case OBButtonType.primary:
        buttonTextColor = Colors.white;
        break;
      case OBButtonType.success:
        buttonTextColor = themeValueParser.parseColor(theme.successColorAccent);
        break;
      case OBButtonType.highlight:
        buttonTextColor = themeValueParser.parseColor(theme.primaryTextColor);
        break;
      default:
    }

    return buttonTextColor;
  }

  EdgeInsets _getButtonPaddingForSize(OBButtonSize type) {
    if (padding != null) return padding!;

    late EdgeInsets buttonPadding;

    switch (size) {
      case OBButtonSize.large:
        buttonPadding = EdgeInsets.symmetric(vertical: 10, horizontal: 20.0);
        break;
      case OBButtonSize.medium:
        buttonPadding = EdgeInsets.symmetric(vertical: 8, horizontal: 12);
        break;
      case OBButtonSize.small:
        buttonPadding = EdgeInsets.symmetric(vertical: 6, horizontal: 10);
        break;
      default:
    }

    return buttonPadding;
  }

  TextStyle _getButtonTextStyleForSize(
      {OBButtonSize? size, required Color color}) {
    late TextStyle textStyle;

    switch (size) {
      case OBButtonSize.large:
        textStyle = TextStyle(color: color, fontSize: 16);
        break;
      case OBButtonSize.medium:
      case OBButtonSize.small:
        textStyle = TextStyle(color: color);
        break;
      default:
    }

    return textStyle;
  }

  double _getButtonMinWidthForSize(OBButtonSize type) {
    if (minWidth != null) return minWidth!;

    late double buttonMinWidth;

    switch (size) {
      case OBButtonSize.large:
      case OBButtonSize.medium:
        buttonMinWidth = 100;
        break;
      case OBButtonSize.small:
        buttonMinWidth = 70;
        break;
      default:
    }

    return buttonMinWidth;
  }
}

enum OBButtonType { primary, success, danger, highlight }

enum OBButtonSize { small, medium, large }
