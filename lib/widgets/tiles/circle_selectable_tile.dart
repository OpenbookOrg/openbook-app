import 'package:Okuna/libs/pretty_count.dart';
import 'package:Okuna/models/circle.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/widgets/circle_color_preview.dart';
import 'package:Okuna/widgets/fields/checkbox_field.dart';
import 'package:flutter/material.dart';

import '../../provider.dart';

class OBCircleSelectableTile extends StatelessWidget {
  final Circle circle;
  final OnCirclePressed? onCirclePressed;
  final bool? isSelected;
  final bool isDisabled;

  const OBCircleSelectableTile(this.circle,
      {Key? key, this.onCirclePressed, this.isSelected, this.isDisabled = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    int? usersCount = circle.usersCount;
    LocalizationService localizationService = OpenbookProvider.of(context).localizationService;
    String? prettyCount = usersCount != null
      ? getPrettyCount(usersCount, localizationService)
      : null;

    return OBCheckboxField(
      isDisabled: isDisabled,
      value: isSelected ?? false,
      title: circle.name!,
      subtitle:
          usersCount != null ? localizationService.user__circle_peoples_count(prettyCount!) : null,
      onTap: () {
        if (onCirclePressed != null) {
          onCirclePressed!(circle);
        }
      },
      leading: SizedBox(
        height: 40,
        width: 40,
        child: Center(
          child: OBCircleColorPreview(
            circle,
            size: OBCircleColorPreviewSize.small,
          ),
        ),
      ),
    );
  }
}

typedef void OnCirclePressed(Circle pressedCircle);
