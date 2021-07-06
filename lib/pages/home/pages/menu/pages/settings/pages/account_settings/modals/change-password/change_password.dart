import 'package:Okuna/provider.dart';
import 'package:Okuna/services/httpie.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/toast.dart';
import 'package:Okuna/services/user.dart';
import 'package:Okuna/services/validation.dart';
import 'package:Okuna/widgets/buttons/button.dart';
import 'package:Okuna/widgets/fields/text_form_field.dart';
import 'package:Okuna/widgets/icon.dart';
import 'package:Okuna/widgets/nav_bars/themed_nav_bar.dart';
import 'package:Okuna/widgets/page_scaffold.dart';
import 'package:Okuna/widgets/theming/primary_color_container.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OBChangePasswordModal extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return OBChangePasswordModalState();
  }
}

class OBChangePasswordModalState extends State<OBChangePasswordModal> {
  late ValidationService _validationService;
  late ToastService _toastService;
  late UserService _userService;
  late LocalizationService _localizationService;
  static const double INPUT_ICONS_SIZE = 16;
  static const EdgeInsetsGeometry INPUT_CONTENT_PADDING =
      EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0);
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _requestInProgress = false;
  bool _formWasSubmitted = false;
  bool? _isPasswordValid = true;
  bool _formValid = true;
  late TextEditingController _currentPasswordController = TextEditingController();
  late TextEditingController _newPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _requestInProgress = false;
    _formWasSubmitted = false;
    _isPasswordValid = true;
    _formValid = true;
    _currentPasswordController.addListener(_updateFormValid);
    _newPasswordController.addListener(_updateFormValid);
  }

  @override
  Widget build(BuildContext context) {
    var openbookProvider = OpenbookProvider.of(context);
    _validationService = openbookProvider.validationService;
    _toastService = openbookProvider.toastService;
    _userService = openbookProvider.userService;
    _localizationService = openbookProvider.localizationService;

    return OBCupertinoPageScaffold(
        navigationBar: _buildNavigationBar(),
        child: OBPrimaryColorContainer(
          child: Padding(
            padding: EdgeInsets.only(left: 20, right: 20, top: 20),
            child: Form(
              key: _formKey,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    OBTextFormField(
                      size: OBTextFormFieldSize.large,
                      autofocus: true,
                      obscureText: true,
                      controller: _currentPasswordController,
                      decoration: InputDecoration(
                        labelText: _localizationService
                            .auth__change_password_current_pwd,
                        hintText: _localizationService
                            .auth__change_password_current_pwd_hint,
                      ),
                      validator: (String? password) {
                        if (!_formWasSubmitted) return null;
                        if (_isPasswordValid != null && !_isPasswordValid!) {
                          _setIsPasswordValid(true);
                          return _localizationService
                              .auth__change_password_current_pwd_incorrect;
                        }
                        String? validatePassword =
                            _validationService.validateUserPassword(password);
                        if (validatePassword != null) return validatePassword;

                        return null;
                      },
                    ),
                    OBTextFormField(
                      autofocus: false,
                      obscureText: true,
                      controller: _newPasswordController,
                      size: OBTextFormFieldSize.large,
                      decoration: InputDecoration(
                          labelText: _localizationService
                              .auth__change_password_new_pwd,
                          hintText: _localizationService
                              .auth__change_password_new_pwd_hint),
                      validator: (String? newPassword) {
                        if (!_formWasSubmitted) return null;
                        if (!_validationService
                            .isPasswordAllowedLength(newPassword ?? '')) {
                          return _localizationService
                              .auth__change_password_new_pwd_error;
                        }
                      },
                    ),
                  ]),
            ),
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
      title: _localizationService.auth__change_password_title,
      trailing: OBButton(
        isDisabled: !_formValid,
        isLoading: _requestInProgress,
        size: OBButtonSize.small,
        onPressed: _submitForm,
        child: Text(_localizationService.auth__change_password_save_text),
      ),
    );
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
      var currentPassword = _currentPasswordController.text;
      var newPassword = _newPasswordController.text;
      await _userService.updateUserPassword(currentPassword, newPassword);
      _toastService.success(
          message: _localizationService.auth__change_password_save_success,
          context: context);
      Navigator.of(context).pop();
    } catch (error) {
      _onError(error);
    } finally {
      _setRequestInProgress(false);
    }
  }

  void _onError(error) async {
    if (error is HttpieConnectionRefusedError) {
      _toastService.error(
          message: error.toHumanReadableMessage(), context: context);
    } else if (error is HttpieRequestError) {
      HttpieBaseResponse response = error.response;
      if (response.isUnauthorized()) {
        // Meaning password didnt match
        _setIsPasswordValid(false);
        _validateForm();
      }
      String? errorMessage = await error.toHumanReadableMessage();
      _toastService.error(message: errorMessage ?? _localizationService.error__unknown_error, context: context);
    } else {
      _toastService.error(
          message: _localizationService.error__unknown_error, context: context);
      throw error;
    }
  }

  void _setRequestInProgress(bool requestInProgress) {
    setState(() {
      _requestInProgress = requestInProgress;
    });
  }

  void _setIsPasswordValid(bool isPasswordValid) {
    setState(() {
      _isPasswordValid = isPasswordValid;
    });
  }

  void _setFormValid(bool formValid) {
    setState(() {
      _formValid = formValid;
    });
  }
}
