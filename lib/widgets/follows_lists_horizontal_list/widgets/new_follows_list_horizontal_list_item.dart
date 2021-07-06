import 'package:Okuna/widgets/icon.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:flutter/material.dart';

class OBNewFollowsListHorizontalListItem extends StatelessWidget {
  final VoidCallback onPressed;

  OBNewFollowsListHorizontalListItem({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    Widget item = GestureDetector(
      onTap: onPressed,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 90, minWidth: 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Stack(
              overflow: Overflow.visible,
              children: <Widget>[
                const OBIcon(
                  OBIcons.lists,
                  customSize: 40,
                  themeColor: OBIconThemeColor.primaryAccent,
                ),
                Positioned(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(50)),
                    child: const OBIcon(
                      OBIcons.add,
                      themeColor: OBIconThemeColor.primaryAccent,
                    ),
                  ),
                  bottom: -5,
                  right: -5,
                )
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            const OBText(
              'Create new',
              style: TextStyle(fontSize: 14),
            ),
            const OBText(
              'list',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );

    return item;
  }
}
