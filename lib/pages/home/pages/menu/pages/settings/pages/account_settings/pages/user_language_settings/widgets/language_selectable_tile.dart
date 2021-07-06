import 'package:Okuna/models/language.dart';
import 'package:Okuna/widgets/fields/checkbox_field.dart';
import 'package:flutter/material.dart';

class OBLanguageSelectableTile extends StatelessWidget {
  final Language language;
  final OnLanguagePressed? onLanguagePressed;
  final bool? isSelected;
  static double circleSize = 15;

  const OBLanguageSelectableTile(this.language,
      {Key? key, this.onLanguagePressed, this.isSelected})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OBCheckboxField(
      value: isSelected ?? false,
      title: language.name!,
      onTap: () {
        if (onLanguagePressed != null) {
          onLanguagePressed!(language);
        }
      },
    );
  }
}

typedef void OnLanguagePressed(Language pressedLanguage);
