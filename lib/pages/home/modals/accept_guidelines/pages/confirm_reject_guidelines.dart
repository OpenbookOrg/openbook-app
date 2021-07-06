import 'package:Okuna/provider.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/toast.dart';
import 'package:Okuna/services/user.dart';
import 'package:Okuna/widgets/buttons/button.dart';
import 'package:Okuna/widgets/icon.dart';
import 'package:Okuna/widgets/nav_bars/themed_nav_bar.dart';
import 'package:Okuna/widgets/theming/primary_color_container.dart';
import 'package:Okuna/widgets/theming/secondary_text.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OBConfirmRejectGuidelines<T> extends StatefulWidget {
  @override
  OBConfirmRejectGuidelinesState createState() {
    return OBConfirmRejectGuidelinesState();
  }
}

class OBConfirmRejectGuidelinesState extends State<OBConfirmRejectGuidelines> {
  late bool _confirmationInProgress;
  late UserService _userService;
  late ToastService _toastService;
  late bool _needsBootstrap;

  @override
  void initState() {
    super.initState();
    _needsBootstrap = true;
    _confirmationInProgress = false;
  }

  @override
  Widget build(BuildContext context) {
    if (_needsBootstrap) {
      OpenbookProviderState openbookProvider = OpenbookProvider.of(context);
      _userService = openbookProvider.userService;
      _toastService = openbookProvider.toastService;
      _needsBootstrap = false;
    }

    OpenbookProviderState openbookProvider = OpenbookProvider.of(context);
    LocalizationService localizationService = openbookProvider.localizationService;

    return CupertinoPageScaffold(
        navigationBar: OBThemedNavigationBar(title:localizationService.user__confirm_guidelines_reject_title),
        child: OBPrimaryColorContainer(
            child: Column(
          children: <Widget>[
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
                child: Column(
                  //crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      '😬',
                      style: TextStyle(fontSize: 45.0),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    OBText(
                     localizationService.user__confirm_guidelines_reject_info,
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    ListTile(
                      leading: const OBIcon(OBIcons.chat),
                      title: OBText(localizationService.user__confirm_guidelines_reject_chat_with_team),
                      subtitle: OBSecondaryText(
                          localizationService.user__confirm_guidelines_reject_chat_immediately),
                      onTap: () async {
                        openbookProvider.intercomService.displayMessenger();
                      },
                    ),
                    ListTile(
                      leading: const OBIcon(OBIcons.slackChannel),
                      title: OBText(localizationService.user__confirm_guidelines_reject_chat_community),
                      subtitle: OBSecondaryText(
                          localizationService.user__confirm_guidelines_reject_join_slack),
                      onTap: () {
                        openbookProvider.urlLauncherService.launchUrl(
                            'https://okuna.io/slack');
                      },
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: OBButton(
                      size: OBButtonSize.large,
                      type: OBButtonType.highlight,
                      child: Text(localizationService.user__confirm_guidelines_reject_go_back),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: OBButton(
                      size: OBButtonSize.large,
                      type: OBButtonType.danger,
                      child: Text(localizationService.user__confirm_guidelines_reject_delete_account),
                      onPressed: () {
                        OpenbookProviderState openbookProvider =
                            OpenbookProvider.of(context);
                        openbookProvider.navigationService
                            .navigateToDeleteAccount(context: context);
                      },
                    ),
                  ),
                ],
              ),
            )
          ],
        )));
  }
}
