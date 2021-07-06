import 'package:flutter/material.dart';

class OBSecondaryButton extends StatelessWidget {
  static const double LARGE_HEIGHT = 53.0;
  static const double NORMAL_HEIGHT = 44.0;

  /// The widget below this widget in the tree.
  ///
  /// Typically a [Text] widget.
  final Widget child;

  /// The callback that is called when the button is tapped or otherwise activated.
  ///
  /// If this is set to null, the button will be disabled.
  final VoidCallback onPressed;

  final bool isLarge;
  final bool isFullWidth;

  const OBSecondaryButton(
      {required this.child,
        required this.onPressed,
        this.isLarge = false,
        this.isFullWidth = false});

  @override
  Widget build(BuildContext context) {
    double height;

    if (isLarge) {
      height = LARGE_HEIGHT;
    } else {
      height = NORMAL_HEIGHT;
    }

    double minWidth;

    if (isFullWidth) {
      minWidth = double.infinity;
    } else {
      minWidth = 88.0;
    }

    return ButtonTheme(
      minWidth: minWidth,
      height: height,
      child: FlatButton(
        textColor: Colors.black87,
        child: this.child,
        onPressed: this.onPressed,
      ),
    );
  }
}
