import 'package:Okuna/models/theme.dart';
import 'package:Okuna/models/user.dart';
import 'package:Okuna/provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class OBNotificationTileTitle extends StatelessWidget {
  final User? user;
  final VoidCallback? onUsernamePressed;
  final TextSpan text;

  static int postCommentMaxVisibleLength = 500;

  OBNotificationTileTitle(
      {Key? key,
      this.onUsernamePressed,
      this.user,
      required this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var openbookProvider = OpenbookProvider.of(context);
    var themeService = openbookProvider.themeService;
    var themeValueParserService = openbookProvider.themeValueParserService;

    return StreamBuilder(
        stream: themeService.themeChange,
        initialData: themeService.getActiveTheme(),
        builder: (BuildContext context, AsyncSnapshot<OBTheme> snapshot) {
          OBTheme theme = snapshot.data!;

          Color primaryTextColor =
              themeValueParserService.parseColor(theme.primaryTextColor);
          Color secondaryTextColor =
              themeValueParserService.parseColor(theme.secondaryTextColor);

          String? commenterUsername = user?.username;
          String? commenterName = user?.getProfileName();

          GestureRecognizer usernameTapGestureRecognizer =
              TapGestureRecognizer()..onTap = onUsernamePressed;

          List<String> plainTextItems = text.text!.split(' ');
          List<TextSpan> textItems = [];

          plainTextItems.asMap().forEach((index, item) {
            if (item == '[name]') {
              textItems.add(
                  TextSpan(
                  text: '$commenterName',
                  recognizer: usernameTapGestureRecognizer,
                  style: TextStyle(fontWeight: FontWeight.bold)));
            } else if (item == '[username]') {
              textItems.add(TextSpan(
                  text: ' @$commenterUsername',
                  recognizer: usernameTapGestureRecognizer,
                  style: TextStyle(color: secondaryTextColor)));
            } else if (index <= plainTextItems.length - 1) {
              textItems.add(TextSpan(
                text: item
              ));
            }

            if (index < plainTextItems.length - 1) {
              //add space after word
              textItems.add(TextSpan(
                text: ' ',
              ));
            }
          });

          return Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Flexible(
                child: RichText(
                  text: TextSpan(
                      style: TextStyle(color: primaryTextColor, fontSize: 16),
                      children: textItems),
                ),
              ),
            ],
          );
        });
  }
}
