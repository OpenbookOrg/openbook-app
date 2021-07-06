import 'package:Okuna/provider.dart';
import 'package:Okuna/pages/auth/create_account/blocs/create_account.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/toast.dart';
import 'package:Okuna/services/validation.dart';
import 'package:Okuna/widgets/buttons/button.dart';
import 'package:Okuna/widgets/buttons/success_button.dart';
import 'package:Okuna/widgets/buttons/secondary_button.dart';
import 'package:Okuna/pages/auth/create_account/widgets/auth_text_field.dart';
import 'package:flutter/material.dart';

class OBAuthUsernameStepPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return OBAuthUsernameStepPageState();
  }
}

class OBAuthUsernameStepPageState extends State<OBAuthUsernameStepPage> {
  late bool _usernameCheckInProgress;
  bool? _usernameTaken;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late CreateAccountBloc _createAccountBloc;
  late LocalizationService _localizationService;
  late ValidationService _validationService;
  late ToastService _toastService;

  TextEditingController _usernameController = TextEditingController();

  @override
  void initState() {
    _usernameCheckInProgress = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var openbookProvider = OpenbookProvider.of(context);
    _localizationService = openbookProvider.localizationService;
    _validationService = openbookProvider.validationService;
    _createAccountBloc = openbookProvider.createAccountBloc;
    _toastService = openbookProvider.toastService;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.0),
                child: Column(
                  children: <Widget>[
                    _buildWhatsYourUsername(context: context),
                    const SizedBox(
                      height: 20.0,
                    ),
                    _buildUsernameForm()
                  ],
                ))),
      ),
      backgroundColor: Color(0xFF236677),
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent,
        elevation: 0.0,
        child: Padding(
          padding: EdgeInsets.only(bottom: 20.0 + MediaQuery.of(context).viewInsets.bottom, top: 20.0, left: 20.0, right: 20.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: _buildPreviousButton(context: context),
              ),
              Expanded(child: _buildNextButton(context)),
            ],
          ),
        ),
      ),
    );
  }


  bool _validateForm() {
    return _formKey.currentState?.validate() ?? false;
  }

  void _setUsernameTaken(bool isUsernameTaken) {
    setState(() {
      _usernameTaken = isUsernameTaken;
    });
  }

  Future<bool> _checkUsernameAvailable(String username, BuildContext context) async {
    _setUsernameCheckInProgress(true);
    bool isUsernameTaken = false;
    try {
     isUsernameTaken = await _validationService.isUsernameTaken(username);
     _setUsernameTaken(isUsernameTaken);
    } catch (error) {
      String errorFeedback = _localizationService.auth__create_acc__username_server_error;
      _toastService.error(message: errorFeedback, context: context);
    } finally {
      _setUsernameCheckInProgress(false);
    }
    return isUsernameTaken;
  }

  void onPressedNextStep(BuildContext context) async {
    await _checkUsernameAvailable(_usernameController.text.trim(), context);
    bool isUsernameValid = _validateForm();
    if (isUsernameValid && !(_usernameTaken ?? true)) {
      setState(() {
        _createAccountBloc.setUsername(_usernameController.text.trim());
        Navigator.pushNamed(context, '/auth/password_step');
      });
    }
  }

  Widget _buildNextButton(BuildContext context) {
    String buttonText = _localizationService.trans('auth__create_acc__next');

    return OBSuccessButton(
      minWidth: double.infinity,
      size: OBButtonSize.large,
      isLoading: _usernameCheckInProgress,
      child: Text(buttonText, style: TextStyle(fontSize: 18.0)),
      onPressed: () {
        onPressedNextStep(context);
      },
    );
  }

  Widget _buildPreviousButton({required BuildContext context}) {
    String buttonText = _localizationService.trans('auth__create_acc__previous');

    return OBSecondaryButton(
      isFullWidth: true,
      isLarge: true,
      child: Row(
        children: <Widget>[
          Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          const SizedBox(
            width: 10.0,
          ),
          Text(
            buttonText,
            style: TextStyle(fontSize: 18.0, color: Colors.white),
          )
        ],
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }

  Widget _buildWhatsYourUsername({required BuildContext context}) {
    String whatsUsernameText =
        _localizationService.auth__create_acc__what_username;

    return Column(
      children: <Widget>[
        Text(
          '😍',
          style: TextStyle(fontSize: 45.0, color: Colors.white),
        ),
        const SizedBox(
          height: 20.0,
        ),
        Text(whatsUsernameText,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
      ],
    );
  }

  Widget _buildUsernameForm() {

    String usernameInputPlaceholder = _localizationService.auth__create_acc__username_placeholder;
    String errorUsernameTaken = _localizationService.auth__create_acc__username_taken_error;

    return Form(
      key: _formKey,
      child: Row(children: <Widget>[
        new Expanded(
          child: Container(
              color: Colors.transparent,
              child: OBAuthTextField(
                autocorrect: false,
                hintText: usernameInputPlaceholder,
                validator: (String? username) {
                  String? validateUsernameResult = _validationService.validateUserUsername(username?.trim());
                  if (validateUsernameResult != null) return validateUsernameResult;
                  if (_usernameTaken != null && _usernameTaken!) {
                    return errorUsernameTaken.replaceFirst('%s', username ?? '<unknown>');
                  }
                },
                controller: _usernameController,
                onFieldSubmitted: (v) => onPressedNextStep(context),
              )
          ),
        ),
      ]),
    );
  }

  void _setUsernameCheckInProgress(bool newUsernameCheckInProgress) {
    setState(() {
      _usernameCheckInProgress = newUsernameCheckInProgress;
    });
  }
}
