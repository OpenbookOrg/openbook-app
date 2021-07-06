import 'package:Okuna/models/user.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/widgets/icon.dart';
import 'package:flutter/material.dart';
import 'package:Okuna/services/bottom_sheet.dart';

class OBProfileInlineActionsMoreButton extends StatelessWidget {
  final User user;

  const OBProfileInlineActionsMoreButton(this.user);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: user.updateSubject,
      initialData: user,
      builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
        var user = snapshot.data!;

        return IconButton(
          icon: const OBIcon(
            OBIcons.moreVertical,
            customSize: 30,
          ),
          onPressed: () {
            OpenbookProviderState openbookProvider =
                OpenbookProvider.of(context);
            BottomSheetService bottomSheetService =
                openbookProvider.bottomSheetService;

            bottomSheetService.showUserActions(
              context: context,
              user: user,
            );
          },
        );
      },
    );
  }
}
