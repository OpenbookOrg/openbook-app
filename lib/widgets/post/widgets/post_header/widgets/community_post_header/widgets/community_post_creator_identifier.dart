import 'package:Okuna/models/post.dart';
import 'package:Okuna/models/theme.dart';
import 'package:Okuna/models/user.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/widgets/theming/secondary_text.dart';
import 'package:Okuna/widgets/user_badge.dart';
import 'package:flutter/material.dart';

class OBCommunityPostCreatorIdentifier extends StatelessWidget {
  final Post post;
  final VoidCallback onUsernamePressed;

  static int postCommentMaxVisibleLength = 500;

  OBCommunityPostCreatorIdentifier({
    Key? key,
    required this.onUsernamePressed,
    required this.post,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var openbookProvider = OpenbookProvider.of(context);
    var themeService = openbookProvider.themeService;
    var themeValueParserService = openbookProvider.themeValueParserService;
    var utilsService = openbookProvider.utilsService;
    var localizationService = openbookProvider.localizationService;

    return StreamBuilder(
        stream: themeService.themeChange,
        initialData: themeService.getActiveTheme(),
        builder: (BuildContext context, AsyncSnapshot<OBTheme> snapshot) {
          OBTheme theme = snapshot.data!;

          Color secondaryTextColor =
              themeValueParserService.parseColor(theme.secondaryTextColor);

          String commenterUsername = post.creator!.username!;
          String commenterName = post.creator!.getProfileName()!;
          String created = utilsService.timeAgo(post.created!, localizationService);

          return GestureDetector(
            onTap: onUsernamePressed,
            child: Row(
              children: <Widget>[
                Flexible(
                  child: RichText(
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                        style: TextStyle(
                            color: secondaryTextColor, fontSize: 12),
                        children: [
                          TextSpan(
                              text: '$commenterName',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(
                              text: ' @$commenterUsername',
                              style: TextStyle(
                                  fontSize: 12)),
                        ]),
                  )
                ),
                OBSecondaryText(
                  ' · $created',
                  style: TextStyle(fontSize: 12),
                )
              ],
            ),
          );
        });
  }
}
