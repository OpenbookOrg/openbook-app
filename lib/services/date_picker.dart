import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

class DatePickerService {
  static const double DATE_PICKER_HEIGHT = 250;

  Future<void> pickDate(
      {required BuildContext context,
      required DateTime initialDate,
      DateTime? minimumDate,
      DateTime? maximumDate,
      required ValueChanged<DateTime> onDateChanged}) {

    // This should also take into account months and days, not only years
    // See https://github.com/flutter/flutter/issues/24820
    return showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return ConstrainedBox(
            constraints: BoxConstraints(maxHeight: DATE_PICKER_HEIGHT),
            child: CupertinoDatePicker(
                minimumYear: minimumDate?.year ?? 1,
                maximumYear: maximumDate?.year,
                mode: CupertinoDatePickerMode.date,
                initialDateTime: initialDate,
                onDateTimeChanged: onDateChanged),
          );
        });
  }
}
