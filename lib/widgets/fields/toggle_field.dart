import 'package:Okuna/widgets/theming/divider.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OBToggleField extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final VoidCallback? onTap;
  final Widget? leading;
  final String title;
  final Widget? subtitle;
  final bool hasDivider;
  final TextStyle? titleStyle;
  final bool isLoading;

  const OBToggleField(
      {Key? key,
      required this.value,
      this.onChanged,
      this.onTap,
      this.leading,
      required this.title,
      this.subtitle,
      this.hasDivider = true,
      this.titleStyle,
      this.isLoading = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget tile = IgnorePointer(
      ignoring: this.isLoading,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          MergeSemantics(
            child: ListTile(
                leading: leading,
                title: OBText(
                  title,
                  style: titleStyle ?? TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: subtitle,
                trailing: CupertinoSwitch(
                  value: value,
                  onChanged: onChanged,
                ),
                onTap: onTap),
          ),
          hasDivider ? OBDivider() : const SizedBox()
        ],
      ),
    );

    if (isLoading) {
      tile = Opacity(
        opacity: 0.5,
        child: tile,
      );
    }

    return tile;
  }
}
