import 'package:Okuna/widgets/buttons/button.dart';
import 'package:flutter/material.dart';

class OBSuccessButton extends StatelessWidget {
  final Widget child;
  final Widget? icon;
  final VoidCallback onPressed;
  final bool isDisabled;
  final bool isLoading;
  final OBButtonSize size;
  final double? minWidth;
  final EdgeInsets? padding;

  const OBSuccessButton(
      {required this.child,
      required this.onPressed,
      this.icon,
      this.size = OBButtonSize.medium,
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
      type: OBButtonType.success,
    );
  }
}
