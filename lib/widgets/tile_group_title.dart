import 'package:Okuna/widgets/theming/text.dart';
import 'package:flutter/material.dart';

class OBTileGroupTitle extends StatelessWidget {
  final String? title;
  final TextStyle? style;

  const OBTileGroupTitle({Key? key, this.title, this.style}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var finalStyle = TextStyle(fontWeight: FontWeight.bold);
    if (style != null) finalStyle = finalStyle.merge(style);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: OBText(
        title ?? '',
        size: OBTextSize.large,
        style: finalStyle,
      ),
    );
  }
}
