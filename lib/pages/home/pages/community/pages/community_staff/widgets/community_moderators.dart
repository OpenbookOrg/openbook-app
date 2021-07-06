import 'package:Okuna/models/community.dart';
import 'package:Okuna/models/user.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/navigation_service.dart';
import 'package:Okuna/widgets/icon.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:Okuna/widgets/tiles/user_tile.dart';
import 'package:flutter/material.dart';

class OBCommunityModerators extends StatelessWidget {
  final Community community;

  OBCommunityModerators(this.community);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: community.updateSubject,
      initialData: community,
      builder: (BuildContext context, AsyncSnapshot<Community> snapshot) {
        var community = snapshot.data;

        List<User>? communityModerators = community?.moderators?.users;

        if (communityModerators == null || communityModerators.isEmpty)
          return const SizedBox();

        return Row(
          children: <Widget>[
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                    child: Row(children: [
                      OBIcon(
                        OBIcons.communityModerators,
                        size: OBIconSize.medium,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      OBText(
                        'Moderators',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 24),
                      )
                    ]),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ListView(
                    padding: EdgeInsets.all(0),
                    shrinkWrap: true,
                    children:
                        communityModerators.map((User communityModerator) {
                      return OBUserTile(
                        communityModerator,
                        onUserTilePressed: (User user) {
                          NavigationService navigationService =
                              OpenbookProvider.of(context).navigationService;
                          navigationService.navigateToUserProfile(
                              user: communityModerator, context: context);
                        },
                      );
                    }).toList(),
                  )
                ],
              ),
            )
          ],
        );
      },
    );
  }
}
