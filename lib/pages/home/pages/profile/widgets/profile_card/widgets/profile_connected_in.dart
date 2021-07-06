import 'package:Okuna/models/user.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/widgets/cirles_wrap.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:flutter/material.dart';

import '../../../../../../../provider.dart';

class OBProfileConnectedIn extends StatelessWidget {
  final User user;

  OBProfileConnectedIn(this.user);

  @override
  Widget build(BuildContext context) {
    LocalizationService localizationService = OpenbookProvider.of(context).localizationService;

    return StreamBuilder(
      stream: user.updateSubject,
      initialData: user,
      builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
        var user = snapshot.data;
        var connectedCircles = user?.connectedCircles?.circles;
        bool isFullyConnected =
            user?.isFullyConnected != null && user!.isFullyConnected!;

        if (connectedCircles == null ||
            connectedCircles.length == 0 ||
            !isFullyConnected) return const SizedBox();

        return Padding(
            padding: EdgeInsets.only(top: 20),
            child: OBCirclesWrap(
              circles: connectedCircles,
              leading: OBText(
                localizationService.user__profile_in_circles,
              ),
            ));
      },
    );
  }
}
