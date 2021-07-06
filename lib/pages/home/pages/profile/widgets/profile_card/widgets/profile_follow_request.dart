import 'package:Okuna/models/user.dart';
import 'package:Okuna/widgets/alerts/alert.dart';
import 'package:Okuna/widgets/buttons/actions/approve_follow_request_button.dart';
import 'package:Okuna/widgets/buttons/actions/reject_follow_request_button.dart';
import 'package:Okuna/widgets/icon.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:flutter/material.dart';

import '../../../../../../../provider.dart';

class OBProfileFollowRequest extends StatelessWidget {
  final User user;

  OBProfileFollowRequest(this.user);

  @override
  Widget build(BuildContext context) {

    OpenbookProviderState openbookProvider = OpenbookProvider.of(context);

    return StreamBuilder(
      stream: user.updateSubject,
      initialData: user,
      builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
        var user = snapshot.data;
        var isPendingFollowRequestApproval =
            user?.isPendingFollowRequestApproval;

        if (isPendingFollowRequestApproval == null ||
            !isPendingFollowRequestApproval) return const SizedBox();

        String userName = user!.username!;

        return Column(
          children: <Widget>[
            const SizedBox(
              height: 20,
            ),
            OBAlert(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: OBText(
                          openbookProvider.localizationService.user__profile_user_sent_follow_request(userName),
                          maxLines: 4,
                          size: OBTextSize.medium,
                          textAlign: TextAlign.left,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      OBRejectFollowRequestButton(user),
                      const SizedBox(
                        width: 20,
                      ),
                      OBApproveFollowRequestButton(user)
                    ],
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
