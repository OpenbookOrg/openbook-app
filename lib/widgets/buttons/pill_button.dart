import 'package:flutter/material.dart';

class OBPillButton extends StatelessWidget {
  final String text;
  final Widget icon;
  final Color? color;
  final Color? textColor;

  final VoidCallback onPressed;

  const OBPillButton(
      {required this.text,
      required this.icon,
      required this.onPressed,
      this.color,
      this.textColor});

  @override
  Widget build(BuildContext context) {
    var button = FlatButton(
        textColor: textColor ?? Colors.white,
        child: Row(
          children: <Widget>[
            icon,
            const SizedBox(
              width: 10.0,
            ),
            Text(
              text,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        color: color,
        onPressed: onPressed,
        shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(50.0)));
    return button;
  }
}
