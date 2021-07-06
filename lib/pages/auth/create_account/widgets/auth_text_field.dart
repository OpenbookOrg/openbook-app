import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OBAuthTextField extends StatelessWidget {
  final TextEditingController? controller;

  final FocusNode? focusNode;

  final TextInputAction? textInputAction;

  final TextCapitalization textCapitalization;

  final TextAlign textAlign;

  final bool autofocus;

  final bool obscureText;

  final bool autocorrect;

  final int? maxLength;

  final bool maxLengthEnforced;

  final VoidCallback? onEditingComplete;

  final List<TextInputFormatter>? inputFormatters;

  final FormFieldValidator<String>? validator;

  final bool? enabled;

  final Brightness? keyboardAppearance;

  final int maxLines;

  final String? hintText;

  final Widget? prefixIcon;

  final Widget? suffixIcon;

  final double fontSize;

  final EdgeInsetsGeometry contentPadding;

  final ValueChanged<String>? onFieldSubmitted;

  OBAuthTextField({
    Key? key,
    this.controller,
    this.focusNode,
    this.textInputAction,
    this.hintText,
    this.textCapitalization = TextCapitalization.none,
    this.textAlign = TextAlign.start,
    this.autofocus = false,
    this.obscureText = false,
    this.autocorrect = false,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.maxLength,
    this.maxLengthEnforced = true,
    this.onEditingComplete,
    this.validator,
    this.inputFormatters,
    this.enabled,
    this.keyboardAppearance,
    this.fontSize = 18.0,
    this.contentPadding = const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: key,
      controller: controller,
      focusNode: focusNode,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      textAlign: textAlign,
      obscureText: obscureText,
      maxLines: maxLines,
      maxLength: maxLength,
      maxLengthEnforcement: maxLengthEnforced ? MaxLengthEnforcement.enforced : MaxLengthEnforcement.none,
      validator: validator,
      onEditingComplete: onEditingComplete,
      inputFormatters: inputFormatters,
      enabled: enabled,
      keyboardAppearance: keyboardAppearance,
      autocorrect: autocorrect,
      style: TextStyle(fontSize: fontSize, color: Colors.black),
      decoration: new InputDecoration(
        contentPadding: contentPadding,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        hintText: hintText,
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
        errorStyle: TextStyle(color: Colors.white),
        errorMaxLines: 2
      ),
      autofocus: autofocus,
      onFieldSubmitted: onFieldSubmitted,
    );
  }
}
