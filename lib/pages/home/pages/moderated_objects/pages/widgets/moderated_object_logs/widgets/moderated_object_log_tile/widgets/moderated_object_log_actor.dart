import 'package:Okuna/models/user.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/navigation_service.dart';
import 'package:Okuna/widgets/avatars/avatar.dart';
import 'package:Okuna/widgets/theming/secondary_text.dart';
import 'package:flutter/material.dart';

class OBModeratedObjectLogActor extends StatelessWidget {
  final User actor;

  const OBModeratedObjectLogActor({Key? key, required this.actor})
      : super(key: key);

  Widget build(BuildContext context) {
    OpenbookProviderState openbookProvider = OpenbookProvider.of(context);
    NavigationService navigationService = openbookProvider.navigationService;

    return GestureDetector(
      onTap: () {
        navigationService.navigateToUserProfile(user: actor, context: context);
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: <Widget>[
            OBAvatar(
              borderRadius: 4,
              customSize: 16,
              avatarUrl: actor.getProfileAvatar(),
            ),
            const SizedBox(
              width: 6,
            ),
            OBSecondaryText(
              '@' + actor.username!,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
