import 'package:Okuna/widgets/buttons/button.dart';
import 'package:flutter/material.dart';

class OBDangerButton extends StatelessWidget {
  final Widget child;
  final Widget? icon;
  final VoidCallback onPressed;
  final bool isDisabled;
  final bool isLoading;
  final Color textColor;
  final OBButtonSize size;
  final double? minWidth;
  final EdgeInsets? padding;

  const OBDangerButton(
      {required this.child,
      required this.onPressed,
      this.size = OBButtonSize.medium,
      this.textColor = Colors.white,
      this.icon,
      this.isDisabled = false,
      this.isLoading = false,
      this.padding,
      this.minWidth});

  @override
  Widget build(BuildContext context) {
    return OBButton(
      child: child,
      icon: icon,
      onPressed: onPressed,
      size: size,
      isDisabled: isDisabled,
      isLoading: isLoading,
      padding: padding,
      minWidth: minWidth,
      type: OBButtonType.danger,
    );
  }
}
