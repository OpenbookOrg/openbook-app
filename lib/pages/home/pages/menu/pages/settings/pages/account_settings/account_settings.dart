import 'package:Okuna/pages/home/pages/menu/pages/settings/pages/account_settings/modals/change-password/change_password.dart';
import 'package:Okuna/pages/home/pages/menu/pages/settings/pages/account_settings/modals/change_email/change_email.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/widgets/icon.dart';
import 'package:Okuna/widgets/nav_bars/themed_nav_bar.dart';
import 'package:Okuna/widgets/theming/primary_color_container.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OBAccountSettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var openbookProvider = OpenbookProvider.of(context);
    var localizationService = openbookProvider.localizationService;
    var navigationService = openbookProvider.navigationService;
    var userService = openbookProvider.userService;
    String? currentUserLanguage = userService.getUserLanguage() != null ? userService.getUserLanguage()!.name : null;

    return CupertinoPageScaffold(
      backgroundColor: Color.fromARGB(0, 0, 0, 0),
      navigationBar: OBThemedNavigationBar(title: localizationService.drawer__settings),
      child: OBPrimaryColorContainer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            ListTile(
              leading: const OBIcon(OBIcons.email),
              title: OBText(localizationService.drawer__account_settings_change_email),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute<bool>(
                    fullscreenDialog: true,
                    builder: (BuildContext context) => Material(
                          child: OBChangeEmailModal(),
                        )));
              },
            ),
            ListTile(
              leading: const OBIcon(OBIcons.lock),
              title:
                  OBText(localizationService.drawer__account_settings_change_password),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute<bool>(
                    fullscreenDialog: true,
                    builder: (BuildContext context) => Material(
                          child: OBChangePasswordModal(),
                        )));
              },
            ),
            ListTile(
              leading: const OBIcon(OBIcons.notifications),
              title: OBText(localizationService.drawer__account_settings_notifications),
              onTap: () {
                navigationService.navigateToNotificationsSettings(
                    context: context);
              },
            ),
            ListTile(
              leading: const OBIcon(OBIcons.language),
              title: OBText(currentUserLanguage != null ? localizationService.drawer__account_settings_language(currentUserLanguage):
              localizationService.drawer__account_settings_language_text),
              onTap: () {
                navigationService.navigateToUserLanguageSettings(
                    context: context);
              },
            ),
            ListTile(
              leading: const OBIcon(OBIcons.block),
              title: OBText(localizationService.drawer__account_settings_blocked_users),
              onTap: () {
                navigationService.navigateToBlockedUsers(
                    context: context);
              },
            ),
            ListTile(
              leading: const OBIcon(OBIcons.deleteCommunity),
              title: OBText(localizationService.drawer__account_settings_delete_account),
              onTap: () {
                navigationService.navigateToDeleteAccount(context: context);
              },
            )
          ],
        ),
      ),
    );
  }
}
