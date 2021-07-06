import 'package:Okuna/provider.dart';
import 'package:Okuna/services/httpie.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/user.dart';
import 'package:Okuna/services/validation.dart';
import 'package:Okuna/widgets/buttons/button.dart';
import 'package:Okuna/widgets/buttons/success_button.dart';
import 'package:Okuna/widgets/buttons/secondary_button.dart';
import 'package:flutter/material.dart';

class OBAuthForgotPasswordPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return OBAuthForgotPasswordPageState();
  }
}

class OBAuthForgotPasswordPageState extends State<OBAuthForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();

  late bool _isSubmitted;
  String? _errorFeedback;
  late bool _requestInProgress;

  late TextEditingController _usernameController = TextEditingController();
  late TextEditingController _emailController = TextEditingController();

  late LocalizationService _localizationService;
  late ValidationService _validationService;
  late UserService _userService;

  @override
  void initState() {
    super.initState();

    _requestInProgress = false;
    _isSubmitted = false;

    _usernameController.addListener(_validateForm);
    _emailController.addListener(_validateForm);
  }

  @override
  void dispose() {
    super.dispose();
    _usernameController.removeListener(_validateForm);
    _emailController.removeListener(_validateForm);
  }

  @override
  Widget build(BuildContext context) {
    var openbookProvider = OpenbookProvider.of(context);
    _localizationService = openbookProvider.localizationService;
    _validationService = openbookProvider.validationService;
    _userService = openbookProvider.userService;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.0),
                child: Column(
                  children: <Widget>[
                    _buildHeading(context: context),
                    const SizedBox(
                      height: 30.0,
                    ),
                    _buildRequestResetPasswordForm(),
                    const SizedBox(
                      height: 20.0,
                    ),
                    _buildErrorFeedback()
                  ],
                ))),
      ),
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
              Expanded(child: _buildContinueButton(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorFeedback() {
    if (_errorFeedback == null) return const SizedBox();

    return SizedBox(
      child: Text(
        _errorFeedback!,
        style: TextStyle(fontSize: 16.0, color: Colors.deepOrange),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    String buttonText = _localizationService.trans('auth__login__login');

    return OBSuccessButton(
      isLoading: _requestInProgress,
      minWidth: double.infinity,
      size: OBButtonSize.large,
      child: Text(buttonText, style: TextStyle(fontSize: 18.0)),
      onPressed: _submitForm,
    );
  }

  Future<void> _submitForm() async {
    _isSubmitted = true;
    if (_validateForm() == true) {
      await _requestPasswordReset(context);
    }
  }

  Future<void> _requestPasswordReset(BuildContext context) async {
    _setRequestInProgress(true);
    String email;
    email = _validateEmail(_emailController.text.trim()) == null ?  _emailController.text.trim() : '';

    try {
      await _userService.requestPasswordReset(email: email);
      Navigator.pushNamed(context, '/auth/verify_reset_password_link_step');
    } catch (error) {
      if (error is HttpieRequestError) {
        String? errorMessage = await error.toHumanReadableMessage();
        _setErrorFeedback(errorMessage);
      }
      if (error is HttpieConnectionRefusedError) {
        _setErrorFeedback(
            _localizationService.trans('auth__login__connection_error'));
      }
    } finally {
      _setRequestInProgress(false);
    }
  }

  Widget _buildPreviousButton({required BuildContext context}) {
    String buttonText = _localizationService.trans('auth__login__previous');

    return OBSecondaryButton(
      isFullWidth: true,
      isLarge: true,
      child: Row(
        children: <Widget>[
          Icon(Icons.arrow_back_ios),
          const SizedBox(
            width: 10.0,
          ),
          Text(
            buttonText,
            style: TextStyle(fontSize: 18.0),
          )
        ],
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }

  Widget _buildHeading({required BuildContext context}) {
    String titleText = _localizationService.auth__login__forgot_password;
    String subtitleText = _localizationService.auth__login__forgot_password_subtitle;

    return Column(
      children: <Widget>[
        Text(
          '😬',
          style: TextStyle(fontSize: 45.0, color: Colors.black),
        ),
        const SizedBox(
          height: 20.0,
        ),
        Text(titleText,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold)),
        const SizedBox(
          height: 10.0,
        ),
        Text(subtitleText,
            textAlign: TextAlign.center, style: TextStyle(fontSize: 16.0)),
      ],
    );
  }

  Widget _buildRequestResetPasswordForm() {
    // If we use StreamBuilder to build the TexField it has a weird
    // bug which places the cursor at the beginning of the label everytime
    // the stream changes. Therefore a flag is used to bootstrap initial value

    String emailInputLabel =
    _localizationService.trans('auth__login__email_label');

    EdgeInsetsGeometry inputContentPadding =
    EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0);

    return Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            SizedBox(
              child: Row(children: <Widget>[
                new Expanded(
                  child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                      ),
                      child: Column(
                        children: <Widget>[
                          TextFormField(
                            controller: _emailController,
                            validator: _validateEmail,
                            decoration: InputDecoration(
                              contentPadding: inputContentPadding,
                              labelText: emailInputLabel,
                              border: OutlineInputBorder(),
                              errorMaxLines: 3
                            ),
                            autocorrect: false,
                            onFieldSubmitted: (v) => _submitForm(),
                          ),
                        ],
                      )),
                ),
              ]),
            ),
          ],
        ));
  }

  String? _validateEmail(String? value) {
    if (!_isSubmitted) return null;
    if (_usernameController.text.trim().length > 0) {
      return null;
    }
    return _validationService.validateUserEmail(value);
  }

  bool? _validateForm() {
    if (_errorFeedback != null) {
      _setErrorFeedback(null);
    }
    return _formKey.currentState?.validate();
  }

  void _setErrorFeedback(String? feedback) {
    setState(() {
      _errorFeedback = feedback;
    });
  }

  void _setRequestInProgress(bool requestInProgress) {
    setState(() {
      _requestInProgress = requestInProgress;
    });
  }
}
