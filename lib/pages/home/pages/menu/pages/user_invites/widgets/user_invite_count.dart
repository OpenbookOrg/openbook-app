import 'package:Okuna/models/theme.dart';
import 'package:Okuna/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OBUserInviteCount extends StatelessWidget {
  final int? count;
  final double? size;

  const OBUserInviteCount({Key? key, this.count, this.size=19}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var openbookProvider = OpenbookProvider.of(context);
    var toastService = openbookProvider.toastService;
    var themeService = openbookProvider.themeService;
    var themeValueParserService = openbookProvider.themeValueParserService;

    return StreamBuilder(
        stream: themeService.themeChange,
        initialData: themeService.getActiveTheme(),
        builder: (BuildContext context, AsyncSnapshot<OBTheme> snapshot) {
          var theme = snapshot.data!;
          var primaryAccentColor =
          themeValueParserService.parseGradient(theme.primaryAccentColor);
          return GestureDetector(
            onTap: () {
              if (count != 1) {
                toastService.info(message: 'You have $count invites left', context: context);
              } else {
                toastService.info(message: 'You have $count invite left', context: context);
              }
            },
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                  gradient: primaryAccentColor,
                  borderRadius: BorderRadius.circular(50)),
              child: Center(
                  child: count != null ? Text(
                    count.toString(),
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: count! < 10 ? 12 : 10,
                        fontWeight: FontWeight.bold),
                  ) : const SizedBox()
              ),
            ),
          );
        });
  }
}
