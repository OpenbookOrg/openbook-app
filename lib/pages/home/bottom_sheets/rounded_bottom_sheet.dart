import 'package:Okuna/widgets/theming/highlighted_box.dart';
import 'package:Okuna/widgets/theming/highlighted_color_container.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OBRoundedBottomSheet extends StatelessWidget {
  final Widget child;

  const OBRoundedBottomSheet({required this.child});

  @override
  Widget build(BuildContext context) {
    const borderRadius = Radius.circular(10);

    return OBHighlightedColorContainer(
        mainAxisSize: MainAxisSize.min,
        child: child,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topRight: borderRadius, topLeft: borderRadius)));
  }
}
