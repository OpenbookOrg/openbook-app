import 'package:Okuna/libs/pretty_count.dart';
import 'package:Okuna/models/circle.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/widgets/tiles/circle_selectable_tile.dart';
import 'package:Okuna/widgets/checkbox.dart';
import 'package:Okuna/widgets/circle_color_preview.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:flutter/material.dart';

import '../../../provider.dart';

class OBCircleHorizontalListItem extends StatelessWidget {
  final bool isSelected;
  final bool isDisabled;
  final Circle circle;
  final OnCirclePressed? onCirclePressed;
  final bool wasPreviouslySelected;

  OBCircleHorizontalListItem(this.circle,
      {required this.onCirclePressed,
      this.isSelected = false,
      this.isDisabled = false,
      this.wasPreviouslySelected = false});

  @override
  Widget build(BuildContext context) {
    int usersCount = circle.usersCount!;
    LocalizationService localizationService = OpenbookProvider.of(context).localizationService;

    if (wasPreviouslySelected) {
      if (!isSelected) {
        usersCount = usersCount - 1;
      }
    } else if (isSelected) {
      usersCount = usersCount + 1;
    }
    String prettyUsersCount = getPrettyCount(usersCount, localizationService);

    Widget item = GestureDetector(
      onTap: () {
        if (this.onCirclePressed != null && !isDisabled) {
          this.onCirclePressed!(circle);
        }
      },
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 90, minWidth: 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Stack(
              overflow: Overflow.visible,
              children: <Widget>[
                OBCircleColorPreview(
                  circle,
                  size: OBCircleColorPreviewSize.large,
                ),
                Positioned(
                  child: OBCheckbox(
                    value: isSelected,
                  ),
                  bottom: -5,
                  right: -5,
                )
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            OBText(
              circle.name!,
              maxLines: 1,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
            ),
            OBText(
              '$prettyUsersCount People',
              maxLines: 1,
              size: OBTextSize.extraSmall,
              style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
            ),
          ],
        ),
      ),
    );

    if (isDisabled) {
      item = Opacity(
        opacity: 0.5,
        child: item,
      );
    }

    return item;
  }
}
