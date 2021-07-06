import 'package:Okuna/translation/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

class MaterialLocalizationEsES extends MaterialLocalizationEs {

  const MaterialLocalizationEsES({
    String localeName = 'es-ES',
    required intl.DateFormat fullYearFormat,
    required intl.DateFormat shortDateFormat,
    required intl.DateFormat mediumDateFormat,
    required intl.DateFormat longDateFormat,
    required intl.DateFormat compactDateFormat,
    required intl.DateFormat yearMonthFormat,
    required intl.DateFormat shortMonthDayFormat,
    required intl.NumberFormat decimalFormat,
    required intl.NumberFormat twoDigitZeroPaddedFormat,
  }) : super(
    localeName: localeName,
    fullYearFormat: fullYearFormat,
    shortDateFormat: shortDateFormat,
    mediumDateFormat: mediumDateFormat,
    longDateFormat: longDateFormat,
    compactDateFormat: compactDateFormat,
    yearMonthFormat: yearMonthFormat,
    shortMonthDayFormat: shortMonthDayFormat,
    decimalFormat: decimalFormat,
    twoDigitZeroPaddedFormat: twoDigitZeroPaddedFormat,
  );
}

class MaterialLocalizationEsESDelegate extends LocalizationsDelegate<MaterialLocalizations> {
  const MaterialLocalizationEsESDelegate();

  @override
  bool isSupported(Locale locale) {
    return supportedLocales.contains(locale);
  }

  @override
  Future<MaterialLocalizationEsES> load(Locale locale) {
    intl.DateFormat fullYearFormat;
    intl.DateFormat shortDateFormat;
    intl.DateFormat mediumDateFormat;
    intl.DateFormat longDateFormat;
    intl.DateFormat compactDateFormat;
    intl.DateFormat yearMonthFormat;
    intl.DateFormat shortMonthDayFormat;
    intl.NumberFormat decimalFormat;
    intl.NumberFormat twoDigitZeroPaddedFormat;
    decimalFormat = intl.NumberFormat.decimalPattern(locale.languageCode);
    twoDigitZeroPaddedFormat = intl.NumberFormat('00', locale.languageCode);
    fullYearFormat = intl.DateFormat.y(locale.languageCode);
    shortDateFormat = intl.DateFormat.MEd(locale.languageCode);
    mediumDateFormat = intl.DateFormat.MMMEd(locale.languageCode);
    longDateFormat = intl.DateFormat.yMMMMEEEEd(locale.languageCode);
    compactDateFormat = intl.DateFormat.MEd(locale.languageCode);
    yearMonthFormat = intl.DateFormat.yMMMM(locale.languageCode);
    shortMonthDayFormat = intl.DateFormat.Md(locale.languageCode);

    return SynchronousFuture(MaterialLocalizationEsES(
      fullYearFormat: fullYearFormat,
      shortDateFormat: shortDateFormat,
      mediumDateFormat: mediumDateFormat,
      longDateFormat: longDateFormat,
      compactDateFormat: compactDateFormat,
      yearMonthFormat: yearMonthFormat,
      shortMonthDayFormat: shortMonthDayFormat,
      decimalFormat: decimalFormat,
      twoDigitZeroPaddedFormat: twoDigitZeroPaddedFormat
    ));
  }
  @override
  bool shouldReload(MaterialLocalizationEsESDelegate old) => false;
}

class CupertinoLocalizationEsES extends CupertinoLocalizationEs {

  const CupertinoLocalizationEsES({
    String localeName = 'es-ES',
    required intl.DateFormat fullYearFormat,
    required intl.DateFormat dayFormat,
    required intl.DateFormat mediumDateFormat,
    required intl.DateFormat singleDigitHourFormat,
    required intl.DateFormat singleDigitMinuteFormat,
    required intl.DateFormat doubleDigitMinuteFormat,
    required intl.DateFormat singleDigitSecondFormat,
    required intl.NumberFormat decimalFormat,
  }) : super(
    localeName: localeName,
    fullYearFormat: fullYearFormat,
    dayFormat: dayFormat,
    mediumDateFormat: mediumDateFormat,
    singleDigitHourFormat: singleDigitHourFormat,
    singleDigitMinuteFormat: singleDigitMinuteFormat,
    doubleDigitMinuteFormat: doubleDigitMinuteFormat,
    singleDigitSecondFormat: singleDigitSecondFormat,
    decimalFormat: decimalFormat,
  );
}


class CupertinoLocalizationEsESDelegate extends LocalizationsDelegate<CupertinoLocalizations> {
  const CupertinoLocalizationEsESDelegate();

  @override
  bool isSupported(Locale locale) {
    return supportedLocales.contains(locale);
  }

  @override
  Future<CupertinoLocalizationEsES> load(Locale locale) {
    intl.DateFormat fullYearFormat;
    intl.DateFormat dayFormat;
    intl.DateFormat mediumDateFormat;
    intl.DateFormat singleDigitHourFormat;
    intl.DateFormat singleDigitMinuteFormat;
    intl.DateFormat doubleDigitMinuteFormat;
    intl.DateFormat singleDigitSecondFormat;
    intl.NumberFormat decimalFormat;

    fullYearFormat = intl.DateFormat.y(locale.languageCode);
    dayFormat = intl.DateFormat.d(locale.languageCode);
    mediumDateFormat = intl.DateFormat.MMMEd(locale.languageCode);
    singleDigitHourFormat = intl.DateFormat('HH', locale.languageCode);
    singleDigitMinuteFormat = intl.DateFormat.m(locale.languageCode);
    doubleDigitMinuteFormat = intl.DateFormat('mm', locale.languageCode);
    singleDigitSecondFormat = intl.DateFormat.s(locale.languageCode);
    decimalFormat = intl.NumberFormat.decimalPattern(locale.languageCode);

    return SynchronousFuture(CupertinoLocalizationEsES(
      fullYearFormat: fullYearFormat,
      dayFormat: dayFormat,
      mediumDateFormat: mediumDateFormat,
      singleDigitHourFormat: singleDigitHourFormat,
      singleDigitMinuteFormat: singleDigitMinuteFormat,
      doubleDigitMinuteFormat: doubleDigitMinuteFormat,
      singleDigitSecondFormat: singleDigitSecondFormat,
      decimalFormat: decimalFormat,
    ));
  }

  @override
  bool shouldReload(CupertinoLocalizationEsESDelegate old) => false;

}
