import 'package:Okuna/widgets/icon.dart';
import 'package:Okuna/widgets/progress_indicator.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:flutter/material.dart';

class OBRetryTile extends StatelessWidget {
  final String text;
  final VoidCallback onWantsToRetry;
  final bool isLoading;

  const OBRetryTile(
      {Key? key,
      this.text = 'Tap to retry.',
      required this.onWantsToRetry,
      this.isLoading = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget tile = ListTile(
      title: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: isLoading
            ? [OBProgressIndicator()]
            : [
                const OBIcon(OBIcons.refresh),
                const SizedBox(
                  width: 10.0,
                ),
                OBText(text)
              ],
      ),
    );

    if (!isLoading) {
      tile = GestureDetector(onTap: onWantsToRetry, child: tile);
    }
    return tile;
  }
}
