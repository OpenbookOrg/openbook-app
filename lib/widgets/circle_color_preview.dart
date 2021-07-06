import 'package:Okuna/models/circle.dart';
import 'package:flutter/material.dart';
import 'package:pigment/pigment.dart';

class OBCircleColorPreview extends StatelessWidget {
  final Circle circle;
  final OBCircleColorPreviewSize size;
  static double circleSizeLarge = 45;
  static double circleSizeMedium = 25;
  static double circleSizeSmall = 15;
  static double circleSizeExtraSmall = 10;

  OBCircleColorPreview(this.circle,
      {this.size = OBCircleColorPreviewSize.medium});

  @override
  Widget build(BuildContext context) {
    double circleSize = _getCircleSize(size);

    return Container(
      height: circleSize,
      width: circleSize,
      decoration: BoxDecoration(
          color: Pigment.fromString(circle.color!),
          border: Border.all(color: Color.fromARGB(10, 0, 0, 0), width: 3),
          borderRadius: BorderRadius.circular(50)),
    );
  }

  double _getCircleSize(OBCircleColorPreviewSize size) {
    double circleSize;

    switch (size) {
      case OBCircleColorPreviewSize.large:
        circleSize = circleSizeLarge;
        break;
      case OBCircleColorPreviewSize.medium:
        circleSize = circleSizeMedium;
        break;
      case OBCircleColorPreviewSize.small:
        circleSize = circleSizeSmall;
        break;
      case OBCircleColorPreviewSize.extraSmall:
        circleSize = circleSizeExtraSmall;
        break;
    }

    return circleSize;
  }
}

enum OBCircleColorPreviewSize { small, medium, large, extraSmall }
