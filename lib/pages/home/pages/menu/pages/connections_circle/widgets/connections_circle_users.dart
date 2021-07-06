import 'package:Okuna/models/circle.dart';
import 'package:Okuna/models/user.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:Okuna/widgets/tiles/user_tile.dart';
import 'package:flutter/material.dart';

class OBConnectionsCircleUsers extends StatelessWidget {
  final Circle connectionsCircle;

  OBConnectionsCircleUsers(this.connectionsCircle);

  @override
  Widget build(BuildContext context) {
    var provider = OpenbookProvider.of(context);
    var navigationService = provider.navigationService;
    LocalizationService localizationService = provider.localizationService;

    return StreamBuilder(
        stream: connectionsCircle.updateSubject,
        initialData: connectionsCircle,
        builder: (BuildContext context, AsyncSnapshot<Circle> snapshot) {
          var connectionsCircle = snapshot.data;
          List<User> users = connectionsCircle?.users?.users ?? [];

          var onUserTilePressed = (User user) {
            navigationService.navigateToUserProfile(
                user: user, context: context);
          };

          return ListView.builder(
              padding: EdgeInsets.all(0),
              itemCount: users.length,
              itemBuilder: (context, index) {
                var user = users[index];

                Widget? trailing;
                bool isFullyConnected = user.isFullyConnected ?? true;

                if (!isFullyConnected) {
                  trailing = Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[OBText(localizationService.trans('user__connection_pending'))],
                  );
                }

                return OBUserTile(
                  user,
                  showFollowing: false,
                  onUserTilePressed: onUserTilePressed,
                  trailing: trailing,
                );
              });
        });
  }
}
