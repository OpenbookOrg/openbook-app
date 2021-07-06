import 'package:Okuna/widgets/icon.dart';
import 'package:flutter/material.dart';

class OBIconButton extends StatelessWidget {
  final OBIconData iconData;
  final OBIconSize? size;
  final double? customSize;
  final Color? color;
  final OBIconThemeColor? themeColor;
  final VoidCallback? onPressed;

  OBIconButton(this.iconData,
      {this.size,
      this.customSize,
      this.color,
      this.themeColor,
      this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: OBIcon(
        iconData,
        size: size,
        customSize: customSize,
        color: color,
        themeColor: themeColor,
      ),
    );
  }
}
