import 'package:Okuna/provider.dart';
import 'package:Okuna/widgets/buttons/button.dart';
import 'package:Okuna/widgets/icon.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:flutter/material.dart';

class OBStreamLoadMoreButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String? text;

  const OBStreamLoadMoreButton({Key? key, this.onPressed, this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    OpenbookProviderState openbookProvider = OpenbookProvider.of(context);

    String buttonText =
        text ?? openbookProvider.localizationService.post__load_more;


    return OBButton(
        type: OBButtonType.highlight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const OBIcon(
              OBIcons.loadMore,
              customSize: 20.0,
            ),
            const SizedBox(
              width: 10.0,
            ),
            OBText(buttonText),
          ],
        ),
        onPressed: onPressed);
  }
}
