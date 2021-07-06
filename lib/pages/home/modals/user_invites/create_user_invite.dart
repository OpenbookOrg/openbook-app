import 'package:Okuna/models/user_invite.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/navigation_service.dart';
import 'package:Okuna/widgets/icon.dart';
import 'package:Okuna/widgets/nav_bars/themed_nav_bar.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/httpie.dart';
import 'package:Okuna/services/toast.dart';
import 'package:Okuna/services/user.dart';
import 'package:Okuna/services/validation.dart';
import 'package:Okuna/widgets/buttons/button.dart';
import 'package:Okuna/widgets/fields/text_form_field.dart';
import 'package:Okuna/widgets/page_scaffold.dart';
import 'package:Okuna/widgets/theming/primary_color_container.dart';
import 'package:async/async.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OBCreateUserInviteModal extends StatefulWidget {
  final UserInvite? userInvite;
  final bool autofocusNameTextField;

  OBCreateUserInviteModal(
      {this.userInvite, this.autofocusNameTextField = false});

  @override
  OBCreateUserInviteModalState createState() {
    return OBCreateUserInviteModalState();
  }
}

class OBCreateUserInviteModalState extends State<OBCreateUserInviteModal> {
  late UserService _userService;
  late ToastService _toastService;
  late NavigationService _navigationService;
  late ValidationService _validationService;
  late LocalizationService _localizationService;

  late bool _requestInProgress;
  late bool _formWasSubmitted;
  late bool _formValid;
  late bool _hasExistingUserInvite;

  late GlobalKey<FormState> _formKey;

  late TextEditingController _nicknameController;

  CancelableOperation? _createUpdateOperation;

  @override
  void initState() {
    super.initState();
    _formValid = true;
    _requestInProgress = false;
    _formWasSubmitted = false;
    _nicknameController = TextEditingController();
    _formKey = GlobalKey<FormState>();
    _hasExistingUserInvite = widget.userInvite != null;
    if (_hasExistingUserInvite) {
      _nicknameController.text = widget.userInvite!.nickname ?? '';
    }

    _nicknameController.addListener(_updateFormValid);
  }

  @override
  void dispose() {
    super.dispose();
    if (_createUpdateOperation != null) _createUpdateOperation?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    var openbookProvider = OpenbookProvider.of(context);
    _userService = openbookProvider.userService;
    _toastService = openbookProvider.toastService;
    _localizationService = openbookProvider.localizationService;
    _validationService = openbookProvider.validationService;
    _navigationService = openbookProvider.navigationService;

    return OBCupertinoPageScaffold(
        navigationBar: _buildNavigationBar(),
        child: OBPrimaryColorContainer(
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        child: Column(
                          children: <Widget>[
                            OBTextFormField(
                                textCapitalization:
                                    TextCapitalization.sentences,
                                size: OBTextFormFieldSize.large,
                                autofocus: widget.autofocusNameTextField,
                                controller: _nicknameController,
                                decoration: InputDecoration(
                                    labelText: _localizationService.user__invites_create_name_title,
                                    hintText: _localizationService.user__invites_create_name_hint),
                                validator: (String? userInviteNickname) {
                                  if (!_formWasSubmitted) return null;
                                  return _validationService
                                      .validateUserProfileName(
                                          userInviteNickname);
                                }),
                          ],
                        )),
                  ],
                )),
          ),
        ));
  }

  ObstructingPreferredSizeWidget _buildNavigationBar() {
    return OBThemedNavigationBar(
        leading: GestureDetector(
          child: const OBIcon(OBIcons.close),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        title: _hasExistingUserInvite ? _localizationService.user__invites_create_edit_title :
        _localizationService.user__invites_create_create_title,
        trailing: OBButton(
          isDisabled: !_formValid,
          isLoading: _requestInProgress,
          size: OBButtonSize.small,
          onPressed: _submitForm,
          child: _hasExistingUserInvite ? Text(_localizationService.user__invites_create_save):
          Text(_localizationService.user__invites_create_create),
        ));
  }

  bool _validateForm() {
    return _formKey.currentState?.validate() ?? false;
  }

  bool _updateFormValid() {
    var formValid = _validateForm();
    _setFormValid(formValid);
    return formValid;
  }

  void _submitForm() async {
    _formWasSubmitted = true;

    var formIsValid = _updateFormValid();
    if (!formIsValid) return;
    _setRequestInProgress(true);
    try {
      _createUpdateOperation = CancelableOperation.fromFuture(
          _hasExistingUserInvite
              ? _userService.updateUserInvite(
                  userInvite: widget.userInvite!,
                  nickname:
                      _nicknameController.text != widget.userInvite!.nickname
                          ? _nicknameController.text
                          : null)
              : _userService.createUserInvite(
                  nickname: _nicknameController.text));

      UserInvite userInvite = await _createUpdateOperation?.value;
      if (!_hasExistingUserInvite) {
        _navigateToShareInvite(userInvite);
      } else {
        Navigator.of(context).pop(userInvite);
      }
    } catch (error) {
      _onError(error);
    } finally {
      _setRequestInProgress(false);
      _createUpdateOperation = null;
    }
  }

  void _navigateToShareInvite(UserInvite userInvite) async {
    Navigator.pop(context, userInvite);
    await _navigationService.navigateToShareInvite(
        context: context, userInvite: userInvite);
  }

  void _onError(error) async {
    if (error is HttpieConnectionRefusedError) {
      _toastService.error(
          message: error.toHumanReadableMessage(), context: context);
    } else if (error is HttpieRequestError) {
      String? errorMessage = await error.toHumanReadableMessage();
      _toastService.error(message: errorMessage ?? _localizationService.error__unknown_error, context: context);
    } else {
      _toastService.error(message: _localizationService.error__unknown_error, context: context);
      throw error;
    }
  }

  void _setRequestInProgress(bool requestInProgress) {
    setState(() {
      _requestInProgress = requestInProgress;
    });
  }

  void _setFormValid(bool formValid) {
    setState(() {
      _formValid = formValid;
    });
  }
}
