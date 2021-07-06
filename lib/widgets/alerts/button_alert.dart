import 'package:Okuna/widgets/alerts/alert.dart';
import 'package:Okuna/widgets/buttons/button.dart';
import 'package:Okuna/widgets/icon.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:flutter/material.dart';

class OBButtonAlert extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;
  final String text;
  final OBIconData? buttonIcon;
  final String buttonText;
  final String? assetImage;

  const OBButtonAlert(
      {required this.onPressed,
      this.isLoading = false,
      required this.text,
      this.buttonIcon,
      required this.buttonText,
      this.assetImage});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(15),
      child: OBAlert(
          child: Row(children: [
        assetImage != null
            ? Padding(
                padding:
                    EdgeInsets.only(right: 30, left: 10, top: 10, bottom: 10),
                child: Image.asset(
                  assetImage!,
                  height: 80,
                ),
              )
            : SizedBox(),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Expanded(
                    child: OBText(
                      text,
                      textAlign: TextAlign.center,
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              OBButton(
                icon: buttonIcon != null
                    ? OBIcon(
                        buttonIcon!,
                        size: OBIconSize.small,
                      )
                    : null,
                isLoading: isLoading,
                type: OBButtonType.highlight,
                child: Text(buttonText),
                onPressed: onPressed,
              )
            ],
          ),
        )
      ])),
    );
  }
}
