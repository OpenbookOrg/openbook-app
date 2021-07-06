import 'package:Okuna/models/community.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/theme_value_parser.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OBCommunityNavBar extends StatelessWidget
    implements ObstructingPreferredSizeWidget {
  final Community community;

  const OBCommunityNavBar(this.community);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: community.updateSubject,
        initialData: community,
        builder: (BuildContext context, AsyncSnapshot<Community> snapshot) {
          var community = snapshot.data;

          if (community == null || community.color == null) return SizedBox();

          String communityColor = community.color!;
          ThemeValueParserService themeValueParserService =
              OpenbookProvider.of(context).themeValueParserService;
          Color color = themeValueParserService.parseColor(communityColor);
          bool isDarkColor = themeValueParserService.isDarkColor(color);
          Color actionsColor = isDarkColor ? Colors.white : Colors.black;

          CupertinoThemeData themeData = CupertinoTheme.of(context);

          return CupertinoTheme(
            data: themeData.copyWith(
                primaryColor: actionsColor,
                textTheme: CupertinoTextThemeData(
                  primaryColor:
                      actionsColor, //change color of the TOP navbar icon
                )),
            child: CupertinoNavigationBar(
              border: null,
              middle: OBText(
                'c/' + (community.name ?? ''),
                style:
                    TextStyle(color: actionsColor, fontWeight: FontWeight.bold),
              ),
              transitionBetweenRoutes: false,
              backgroundColor: color,
            ),
          );
        });
  }

  bool get fullObstruction {
    return true;
  }

  @override
  Size get preferredSize {
    return const Size.fromHeight(44);
  }

  @override
  bool shouldFullyObstruct(BuildContext context) {
    return true;
  }
}
