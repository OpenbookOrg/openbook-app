import 'dart:ui';

import 'package:dcache/dcache.dart';
import 'package:flutter/cupertino.dart';
import 'package:pigment/pigment.dart';

class ThemeValueParserService {
  static AlignmentGeometry _beginAlignment = Alignment.topLeft;
  static AlignmentGeometry _endAlignment = Alignment.bottomRight;

  static SimpleCache<String, Color> colorCache =
      SimpleCache(storage: new InMemoryStorage(30));

  static SimpleCache<String, Gradient> gradientCache =
      SimpleCache<String, Gradient>(storage: new InMemoryStorage(10));

  Color parseColor(String value) {
    return colorCache.get(value) ?? _parseAndStoreColor(value);
  }

  bool isDarkColor(Color color){
    return color.computeLuminance() < 0.25;
  }

  Gradient parseGradient(String gradientValue) {
    return gradientCache.get(gradientValue) ??
        _parseAndStoreGradient(gradientValue);
  }

  Color _parseAndStoreColor(String colorValue) {
    Color color = Pigment.fromString(colorValue);
    colorCache.set(colorValue, color);
    return color;
  }

  Gradient _parseAndStoreGradient(String gradientValue) {
    List<String> gradients = gradientValue.split(',');

    if (gradients.length == 1) {
      gradients.add(gradients[0]);
    }

    List<Color> colors =
        gradients.map((colorValue) => parseColor(colorValue)).toList();

    Gradient gradient = makeGradientWithColors(colors);

    gradientCache.set(gradientValue, gradient);

    return gradient;
  }

  Gradient makeGradientWithColors(List<Color> colors){
    return  LinearGradient(
        begin: _beginAlignment,
        end: _endAlignment,
        colors: colors,
        tileMode: TileMode.mirror);
  }
}
