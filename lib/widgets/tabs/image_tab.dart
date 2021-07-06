import 'package:flutter/material.dart';

class OBImageTab extends StatelessWidget {
  static const double borderRadius = 10;
  static const double width = 130;
  static const double height = 80;

  final Color? color;
  final Color textColor;
  final String text;
  final ImageProvider imageProvider;

  const OBImageTab(
      {Key? key,
      this.color,
      required this.textColor,
      required this.text,
      required this.imageProvider})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            image: DecorationImage(fit: BoxFit.cover, image: imageProvider)),
        height: height,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                constraints: BoxConstraints(minWidth: width),
                decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(borderRadius),
                        bottomRight: Radius.circular(borderRadius))),
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: textColor, fontSize: 16),
                ),
              ),
            )
          ],
        ));
  }
}
