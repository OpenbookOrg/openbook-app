import 'package:Okuna/models/theme.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/widgets/theming/divider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OBTextFormField extends StatelessWidget {
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final bool autofocus;
  final bool readOnly;
  final InputDecoration? decoration;
  final int? maxLines;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final OBTextFormFieldSize size;
  final bool obscureText;
  final TextCapitalization textCapitalization;
  final bool autocorrect;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final TextStyle style;
  final bool hasBorder;

  const OBTextFormField(
      {this.controller,
      this.validator,
      this.autofocus = false,
      this.readOnly = false,
      this.keyboardType,
      this.inputFormatters,
      this.obscureText = false,
      this.autocorrect = true,
      this.size = OBTextFormFieldSize.medium,
      this.maxLines,
      this.textInputAction = TextInputAction.done,
      this.decoration,
      this.textCapitalization = TextCapitalization.none,
      this.focusNode,
      this.style = const TextStyle(),
      this.hasBorder = true});

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
          double fontSize;
          double labelHeight;

          switch (size) {
            case OBTextFormFieldSize.small:
              fontSize = 14;
              labelHeight = 0;
              break;
            case OBTextFormFieldSize.medium:
              fontSize = 16;
              labelHeight = 0;
              break;
            case OBTextFormFieldSize.large:
              fontSize = 22;
              labelHeight = 0.60;
              break;
          }

          TextStyle finalStyle = style.merge(TextStyle(
              fontSize: fontSize,
              color:
                  themeValueParserService.parseColor(theme!.primaryTextColor)));

          var primaryColor =
              themeValueParserService.parseColor(theme.primaryColor);
          final bool isDarkPrimaryColor =
              primaryColor.computeLuminance() < 0.179;

          return Column(
            children: <Widget>[
              TextFormField(
                focusNode: focusNode,
                inputFormatters: inputFormatters,
                textCapitalization: textCapitalization,
                textInputAction: textInputAction,
                autofocus: autofocus,
                readOnly: readOnly,
                controller: controller,
                validator: validator,
                keyboardType: keyboardType,
                keyboardAppearance:
                    isDarkPrimaryColor ? Brightness.dark : Brightness.light,
                autocorrect: autocorrect,
                maxLines: obscureText ? 1 : maxLines,
                obscureText: obscureText,
                style: finalStyle,
                decoration: InputDecoration(
                    isDense: true,
                    hintText: decoration?.hintText,
                    labelStyle: TextStyle(
                        height: labelHeight,
                        fontWeight: FontWeight.bold,
                        color: themeValueParserService
                            .parseColor(theme.secondaryTextColor),
                        fontSize: fontSize),
                    hintStyle: TextStyle(
                        color: themeValueParserService
                            .parseColor(theme.primaryTextColor)),
                    contentPadding: decoration?.contentPadding ??
                        EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                    border: InputBorder.none,
                    labelText: decoration?.labelText,
                    prefixIcon: decoration?.prefixIcon,
                    prefixText: decoration?.prefixText,
                    errorMaxLines: decoration?.errorMaxLines ?? 3),
              ),
              hasBorder ? const OBDivider() : const SizedBox()
            ],
          );
        });
  }
}

enum OBTextFormFieldSize { small, medium, large }
