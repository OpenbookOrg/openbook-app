import 'package:Okuna/widgets/checkbox.dart';
import 'package:Okuna/widgets/theming/secondary_text.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OBCheckboxField extends StatelessWidget {
  final bool value;
  final VoidCallback? onTap;
  final Widget? leading;
  final String title;
  final String? subtitle;
  final bool isDisabled;
  final TextStyle? titleStyle;

  OBCheckboxField(
      {required this.value,
      this.subtitle,
      this.onTap,
      this.leading,
      required this.title,
      this.isDisabled = false,
      this.titleStyle});

  @override
  Widget build(BuildContext context) {
    TextStyle finalTitleStyle = TextStyle(fontWeight: FontWeight.bold);
    if (titleStyle != null) finalTitleStyle = finalTitleStyle.merge(titleStyle);

    Widget field = MergeSemantics(
      child: ListTile(
          selected: value,
          leading: leading,
          title: OBText(
            title,
            style: finalTitleStyle,
          ),
          subtitle: subtitle != null ? OBSecondaryText(subtitle!) : null,
          trailing: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              OBCheckbox(
                value: value,
              )
            ],
          ),
          onTap: () {
            if (!isDisabled && onTap != null) onTap!();
          }),
    );

    if (isDisabled) {
      field = Opacity(
        opacity: 0.5,
        child: field,
      );
    }
    return field;
  }
}
