import 'package:Okuna/provider.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/toast.dart';
import 'package:Okuna/services/user.dart';
import 'package:Okuna/widgets/buttons/button.dart';
import 'package:Okuna/widgets/icon.dart';
import 'package:Okuna/widgets/nav_bars/themed_nav_bar.dart';
import 'package:Okuna/widgets/theming/primary_color_container.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:flutter/cupertino.dart';

class OBConfirmDeleteAccount<T> extends StatefulWidget {
  final String userPassword;

  const OBConfirmDeleteAccount({Key? key, required this.userPassword})
      : super(key: key);

  @override
  OBConfirmDeleteAccountState createState() {
    return OBConfirmDeleteAccountState();
  }
}

class OBConfirmDeleteAccountState extends State<OBConfirmDeleteAccount> {
  late bool _confirmationInProgress;
  late UserService _userService;
  late ToastService _toastService;
  late LocalizationService _localizationService;
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
      _localizationService = openbookProvider.localizationService;
      _needsBootstrap = false;
    }

    return CupertinoPageScaffold(
        navigationBar: OBThemedNavigationBar(title: _localizationService.user__delete_account_confirmation_title),
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
                    OBIcon(
                      OBIcons.deleteAccount,
                      themeColor: OBIconThemeColor.primaryAccent,
                      size: OBIconSize.extraLarge,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    OBText(
                      _localizationService.user__delete_account_confirmation_desc,
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    OBText(
                        _localizationService.user__delete_account_confirmation_desc_info)
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
                      child: Text(_localizationService.user__delete_account_confirmation_no),
                      onPressed: _onCancel,
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: OBButton(
                      size: OBButtonSize.large,
                      child: Text(_localizationService.user__delete_account_confirmation_yes),
                      onPressed: _onConfirm,
                      isLoading: _confirmationInProgress,
                    ),
                  )
                ],
              ),
            )
          ],
        )));
  }

  void _onConfirm() async {
    _setConfirmationInProgress(true);
    try {
      await _userService.deleteAccountWithPassword(widget.userPassword);
      _toastService.info(message: _localizationService.user__delete_account_confirmation_goodbye, context: context);
      Future.delayed(Duration(seconds: 3), () {
        return _userService.logout();
      });
    } catch (error) {
      _onError(error);
    } finally {
      _setConfirmationInProgress(false);
    }
  }

  void _onError(error) async {
    if (error is HttpieConnectionRefusedError) {
      _toastService.error(
          message: error.toHumanReadableMessage(), context: context);
    } else if (error is HttpieRequestError) {
      String? errorMessage = await error.toHumanReadableMessage();
      _toastService.error(message: errorMessage ?? _localizationService.error__unknown_error, context: context);

      if (error.response.isUnauthorized()) {
        // Password was incorrect
        Navigator.pop(context, false);
      }
    } else {
      _toastService.error(message: _localizationService.error__unknown_error, context: context);
      throw error;
    }
  }

  void _onCancel() {
    Navigator.of(context).pop(false);
  }

  void _setConfirmationInProgress(confirmationInProgress) {
    setState(() {
      _confirmationInProgress = confirmationInProgress;
    });
  }
}
