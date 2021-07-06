import 'package:Okuna/services/localization.dart';

String getPrettyCount(int value, LocalizationService localizationService) {
  late String postfix;
  late double finalValue;

  if (value < 0) {
    throw 'Invalid value';
  } else if (value < 1000) {
    return value.toString();
  } else if (value < 1000000) {
    postfix = localizationService.user__thousand_postfix;
    finalValue = value / 1000;
  } else if (value < 1000000000) {
    postfix = localizationService.user__million_postfix;
    finalValue = value / 1000000;
  } else if (value < 1000000000000) {
    postfix = localizationService.user__billion_postfix;
    finalValue = value / 1000000000;
  }

  var finalValueInt = finalValue.round();

  if (finalValue != finalValueInt) {
    // shows 3.8k etc.
    return finalValue.toStringAsFixed(1) + postfix;
  }

  return finalValue.round().toString() + postfix;
}
