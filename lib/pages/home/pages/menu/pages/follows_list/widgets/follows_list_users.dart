import 'package:Okuna/models/follows_list.dart';
import 'package:Okuna/models/user.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/widgets/tiles/user_tile.dart';
import 'package:flutter/material.dart';

class OBFollowsListUsers extends StatelessWidget {
  final FollowsList followsList;

  OBFollowsListUsers(this.followsList);

  @override
  Widget build(BuildContext context) {
    var navigationService = OpenbookProvider.of(context).navigationService;
    return StreamBuilder(
        stream: followsList.updateSubject,
        initialData: followsList,
        builder: (BuildContext context, AsyncSnapshot<FollowsList> snapshot) {
          var followsList = snapshot.data;
          List<User> users = followsList?.users?.users ?? [];

          return ListView.builder(
              padding: EdgeInsets.all(0),
              itemCount: users.length,
              itemBuilder: (context, index) {
                var user = users[index];
                return OBUserTile(
                  user,
                  showFollowing: false,
                  onUserTilePressed: (User user) {
                    navigationService.navigateToUserProfile(
                        user: user, context: context);
                  },
                );
              });
        });
  }
}
