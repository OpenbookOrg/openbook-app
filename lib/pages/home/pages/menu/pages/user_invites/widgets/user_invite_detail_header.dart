import 'package:Okuna/models/user_invite.dart';
import 'package:Okuna/pages/home/pages/menu/pages/user_invites/widgets/user_invite_nickname.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/widgets/theming/actionable_smart_text.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:flutter/material.dart';

import '../../../../../../../provider.dart';

class OBUserInviteDetailHeader extends StatelessWidget {
  final UserInvite userInvite;

  OBUserInviteDetailHeader(this.userInvite);

  @override
  Widget build(BuildContext context) {
    LocalizationService localizationService = OpenbookProvider.of(context).localizationService;

    return StreamBuilder(
        stream: this.userInvite.updateSubject,
        initialData: this.userInvite,
        builder: (BuildContext context, AsyncSnapshot<UserInvite> snapshot) {
          var userInvite = snapshot.data!;

          List<Widget> columnItems = [_buildUserInviteNickname(userInvite)];

          columnItems.add(_buildUserDescription(userInvite, localizationService));

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: columnItems,
          );
        });
  }

  Widget _buildUserInviteNickname(UserInvite userInvite) {

    return Padding(
      padding: EdgeInsets.only(left: 20.0, right: 20, top: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(
            child: OBUserInviteNickname(userInvite),
          ),
        ],
      ),
    );
  }

  Widget _buildUserDescription(UserInvite userInvite, LocalizationService localizationService) {
    Widget _description;
    if (userInvite.createdUser != null) {
      _description = OBActionableSmartText(text:localizationService.user__invites_joined_with(userInvite.createdUser!.username!));
    } else if (userInvite.isInviteEmailSent == true) {
      _description = OBText(localizationService.user__invites_pending_email(userInvite.email!));
    } else {
      _description = OBText(localizationService.user__invites_pending);
    }

    return Padding(
      padding: EdgeInsets.only(left: 20.0, right: 20, top: 10.0, bottom: 20),
      child: Column(
        children: <Widget>[
          _description,
        ],
      ),
    );
  }
}
