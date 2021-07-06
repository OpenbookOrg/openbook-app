import 'package:Okuna/models/user.dart';
import 'package:Okuna/pages/home/bottom_sheets/rounded_bottom_sheet.dart';
import 'package:Okuna/pages/home/bottom_sheets/user_actions/widgets/add_account_to_list_tile.dart';
import 'package:Okuna/pages/home/bottom_sheets/user_actions/widgets/confirm_connection_with_user_tile.dart';
import 'package:Okuna/pages/home/bottom_sheets/user_actions/widgets/connect_to_user_tile.dart';
import 'package:Okuna/pages/home/bottom_sheets/user_actions/widgets/disconnect_from_user_tile.dart';
import 'package:Okuna/pages/home/bottom_sheets/user_actions/widgets/remove_account_from_lists_tile.dart';
import 'package:Okuna/pages/home/bottom_sheets/user_actions/widgets/new_post_notifications_for_user_tile.dart';
import 'package:Okuna/pages/home/bottom_sheets/user_actions/widgets/update_connection_with_user_tile.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/bottom_sheet.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/widgets/tiles/actions/block_user_tile.dart';
import 'package:Okuna/widgets/tiles/actions/report_user_tile.dart';
import 'package:flutter/material.dart';

class OBUserActionsBottomSheet extends StatelessWidget {
  final User user;

  const OBUserActionsBottomSheet(this.user);

  @override
  Widget build(BuildContext context) {
    OpenbookProviderState openbookProvider = OpenbookProvider.of(context);
    LocalizationService localizationService =
        openbookProvider.localizationService;
    BottomSheetService bottomSheetService = openbookProvider.bottomSheetService;

    final dismissBottomSheet = () {
      bottomSheetService.dismissActiveBottomSheet(context: context);
    };

    return StreamBuilder(
      stream: user.updateSubject,
      initialData: user,
      builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
        var user = snapshot.data!;

        List<Widget> moreTiles = [];

        var _dismissModalBottomSheet = () {
          OpenbookProviderState openbookProvider = OpenbookProvider.of(context);
          openbookProvider.bottomSheetService
              .dismissActiveBottomSheet(context: context);
        };

        // TODO Messy, refactor.

        moreTiles.add(OBAddAccountToList(
          user,
        ));

        if (user.hasFollowLists()) {
          moreTiles.add(OBRemoveAccountFromLists(
            user,
            onRemovedAccountFromLists: _dismissModalBottomSheet,
          ));
        }

        moreTiles.add(OBNewPostNotificationsForUserTile(
          user: user,
          onSubscribed: () {
            dismissBottomSheet();
            // Bottom sheet
            openbookProvider.toastService.success(
                message: localizationService
                    .user__profile_action_user_post_notifications_enabled,
                context: context);
          },
          onUnsubscribed: () {
            // Bottom sheet
            dismissBottomSheet();
            openbookProvider.toastService.success(
                message: localizationService
                    .user__profile_action_user_post_notifications_disabled,
                context: context);
          },
        ));

        if (user.isConnected! &&
            !user.isFullyConnected! &&
            !user.isPendingConnectionConfirmation!) {
          moreTiles.add(OBDisconnectFromUserTile(user,
              onDisconnectedFromUser: _dismissModalBottomSheet,
              title:
                  localizationService.user__profile_action_cancel_connection));
          moreTiles.add(OBUpdateConnectionWithUserTile(user));
        } else if (user.isPendingConnectionConfirmation!) {
          moreTiles.add(OBConfirmConnectionWithUserTile(
            user,
            onWillShowModalBottomSheet: _dismissModalBottomSheet,
          ));
          moreTiles.add(OBDisconnectFromUserTile(user,
              onDisconnectedFromUser: _dismissModalBottomSheet,
              title: localizationService.user__profile_action_deny_connection));
        } else if (user.isFullyConnected!) {
          moreTiles.add(OBUpdateConnectionWithUserTile(user));
          moreTiles.add(OBDisconnectFromUserTile(user,
              onDisconnectedFromUser: _dismissModalBottomSheet));
        } else {
          moreTiles.add(OBConnectToUserTile(
            user,
            context,
          ));
        }

        User loggedInUser = openbookProvider.userService.getLoggedInUser()!;

        if (loggedInUser.canBlockOrUnblockUser(user)) {
          moreTiles.add(OBBlockUserTile(
            user: user,
            onBlockedUser: () {
              // Bottom sheet
              dismissBottomSheet();
            },
            onUnblockedUser: () {
              // Bottom sheet
              dismissBottomSheet();
            },
          ));
        }

        moreTiles.add(OBReportUserTile(
          user: user,
          onWantsToReportUser: () {
            dismissBottomSheet();
          },
        ));

        return OBRoundedBottomSheet(
          child: Column(mainAxisSize: MainAxisSize.min, children: moreTiles),
        );
      },
    );
  }
}
