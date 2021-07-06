import 'package:Okuna/models/theme.dart';
import 'package:Okuna/provider.dart';
import 'package:flutter/material.dart';

class OBTextField extends StatelessWidget {
  final TextStyle? style;
  final FocusNode? focusNode;
  final TextEditingController? controller;
  final InputDecoration? decoration;
  final bool autocorrect;
  final bool autofocus;
  final TextInputAction textInputAction;
  final TextInputType? keyboardType;
  final int? maxLines;
  final FormFieldValidator<String>? validator;
  final bool obscureText;
  final TextCapitalization textCapitalization;

  OBTextField(
      {this.style,
      this.focusNode,
      this.controller,
      this.textCapitalization = TextCapitalization.none,
      this.validator,
      this.maxLines,
      this.decoration,
      this.autocorrect = false,
      this.autofocus = false,
      this.obscureText = false,
      this.keyboardType,
      this.textInputAction = TextInputAction.done});

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

          TextStyle themedTextStyle = TextStyle(
              color:
                  themeValueParserService.parseColor(theme!.primaryTextColor));

          if (style != null) {
            themedTextStyle = themedTextStyle.merge(style);
          }

          TextStyle hintTextStyle = TextStyle(
              color:
                  themeValueParserService.parseColor(theme.secondaryTextColor));

          if (decoration != null && decoration!.hintStyle != null) {
            hintTextStyle = hintTextStyle.merge(decoration!.hintStyle);
          }

          var primaryColor =
              themeValueParserService.parseColor(theme.primaryColor);
          final bool isDarkPrimaryColor =
              primaryColor.computeLuminance() < 0.179;

          return TextField(
            textInputAction: textInputAction,
            focusNode: focusNode,
            controller: controller,
            keyboardType: keyboardType,
            style: themedTextStyle,
            maxLines: maxLines,
            obscureText: obscureText,
            textCapitalization: textCapitalization,
            keyboardAppearance:
                isDarkPrimaryColor ? Brightness.dark : Brightness.light,
            decoration: InputDecoration(
                isDense: true,
                hintText: decoration?.hintText,
                hintStyle: hintTextStyle,
                contentPadding: decoration?.contentPadding,
                border: decoration?.border),
            autocorrect: autocorrect,
            autofocus: autofocus,
          );
        });
  }
}
