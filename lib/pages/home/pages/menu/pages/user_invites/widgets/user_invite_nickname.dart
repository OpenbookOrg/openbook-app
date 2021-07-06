import 'package:Okuna/models/user_invite.dart';
import 'package:Okuna/widgets/theming/primary_accent_text.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:Okuna/widgets/theming/secondary_text.dart';
import 'package:flutter/material.dart';

class OBUserInviteNickname extends StatelessWidget {
  final UserInvite userInvite;

  OBUserInviteNickname(this.userInvite);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: userInvite.updateSubject,
        initialData: userInvite,
        builder: (BuildContext context, AsyncSnapshot<UserInvite> snapshot) {
          var userInvite = snapshot.data!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              OBSecondaryText(
                'Nickname',
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Flexible(
                    child: OBPrimaryAccentText(
                      userInvite.nickname!,
                      size: OBTextSize.extraLarge,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              )
            ],
          );
        });
  }
}
