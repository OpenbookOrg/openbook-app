import 'package:Okuna/provider.dart';
import 'package:Okuna/services/httpie.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/user.dart';
import 'package:Okuna/services/validation.dart';
import 'package:Okuna/widgets/buttons/button.dart';
import 'package:Okuna/widgets/buttons/success_button.dart';
import 'package:Okuna/widgets/buttons/secondary_button.dart';
import 'package:flutter/material.dart';

class OBAuthLoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return OBAuthLoginPageState();
  }
}

class OBAuthLoginPageState extends State<OBAuthLoginPage> {
  final _formKey = GlobalKey<FormState>();
  late FocusNode _passwordFocusNode;

  late bool _isSubmitted;
  late bool _passwordIsVisible;
  String? _loginFeedback;
  late bool _loginInProgress;

  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  late LocalizationService _localizationService;
  late ValidationService _validationService;
  late UserService _userService;

  @override
  void initState() {
    super.initState();

    _passwordFocusNode = FocusNode();

    _loginInProgress = false;
    _isSubmitted = false;
    _passwordIsVisible = false;

    _usernameController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
  }

  @override
  void dispose() {
    super.dispose();
    _usernameController.removeListener(_validateForm);
    _passwordController.removeListener(_validateForm);
    _passwordFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var openbookProvider = OpenbookProvider.of(context);
    _localizationService = openbookProvider.localizationService;
    _validationService = openbookProvider.validationService;
    _userService = openbookProvider.userService;

    return Container(
      color: Colors.white,
      child: Scaffold(
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
                      _buildLoginForm(),
                      const SizedBox(
                        height: 20.0,
                      ),
                      _buildLoginFeedback()
                    ],
                  ))),
        ),
        resizeToAvoidBottomInset: true,
        bottomNavigationBar: BottomAppBar(
          color: Colors.transparent,
          elevation: 0.0,
          child: Padding(
            padding: EdgeInsets.only(bottom: 20.0 + MediaQuery
                .of(context)
                .viewInsets
                .bottom, top: 20.0, left: 20.0, right: 20.0),
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
      ),
    );
  }

  Widget _buildLoginFeedback() {
    if (_loginFeedback == null) return const SizedBox();

    return SizedBox(
      child: Text(
        _loginFeedback!,
        style: TextStyle(fontSize: 16.0, color: Colors.deepOrange),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    String buttonText = _localizationService.trans('auth__login__login');

    return OBSuccessButton(
      isLoading: _loginInProgress,
      minWidth: double.infinity,
      size: OBButtonSize.large,
      child: Text(buttonText, style: TextStyle(fontSize: 18.0)),
      onPressed: _submitForm,
    );
  }

  Future<void> _submitForm() async {
    _isSubmitted = true;
    if (_validateForm() == true) {
      await _login(context);
    }
  }

  Future<void> _login(BuildContext context) async {
    _setLoginInProgress(true);
    String username = _usernameController.text.trim();
    String password = _passwordController.text;
    try {
      await _userService.loginWithCredentials(
          username: username, password: password);
      Navigator.pop(context); //pop the login form screen
      Navigator.pushReplacementNamed(
          context, '/'); //replace the underlying login splash screen too
    } on CredentialsMismatchError {
      _setLoginFeedback(
          _localizationService.trans(
              'auth__login__credentials_mismatch_error'));
    } on HttpieRequestError {
      _setLoginFeedback(
          _localizationService.trans('auth__login__server_error'));
    } on HttpieConnectionRefusedError {
      _setLoginFeedback(
          _localizationService.trans('auth__login__connection_error'));
    }
    _setLoginInProgress(false);
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

  Widget _buildForgotPasswordButton({required BuildContext context}) {
    String buttonText = _localizationService.trans(
        'auth__login__forgot_password');

    return OBSecondaryButton(
      isFullWidth: true,
      isLarge: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            buttonText,
            style: TextStyle(fontSize: 18.0),
          )
        ],
      ),
      onPressed: () {
        Navigator.pushNamed(context, '/auth/forgot_password_step');
      },
    );
  }

  Widget _buildHeading({required BuildContext context}) {
    String titleText = _localizationService.trans('auth__login__title');
    String subtitleText = _localizationService.trans('auth__login__subtitle');

    return Column(
      children: <Widget>[
        Text(
          '👋',
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

  Widget _buildLoginForm() {
    // If we use StreamBuilder to build the TexField it has a weird
    // bug which places the cursor at the beginning of the label everytime
    // the stream changes. Therefore a flag is used to bootstrap initial value

    String usernameInputLabel =
    _localizationService.trans('auth__login__username_label');

    String passwordInputLabel =
    _localizationService.trans('auth__login__password_label');

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
                            controller: _usernameController,
                            validator: _validateUsername,
                            decoration: InputDecoration(
                                contentPadding: inputContentPadding,
                                labelText: usernameInputLabel,
                                border: OutlineInputBorder(),
                                errorMaxLines: 3
                            ),
                            autocorrect: false,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (v) => FocusScope.of(context)
                                .requestFocus(_passwordFocusNode),
                          ),
                          const SizedBox(
                            height: 20.0,
                          ),
                          TextFormField(
                            controller: _passwordController,
                            focusNode: _passwordFocusNode,
                            obscureText: !_passwordIsVisible,
                            validator: _validatePassword,
                            decoration: InputDecoration(
                              suffixIcon: GestureDetector(
                                child: Icon(_passwordIsVisible
                                    ? Icons.visibility_off
                                    : Icons.visibility),
                                onTap: () {
                                  _togglePasswordVisibility();
                                },
                              ),
                              contentPadding: inputContentPadding,
                              labelText: passwordInputLabel,
                              border: OutlineInputBorder(),
                            ),
                            autocorrect: false,
                            onFieldSubmitted: (v) => _submitForm(),
                          ),
                          const SizedBox(
                            height: 20.0,
                          ),
                          Center(
                              child: _buildForgotPasswordButton(
                                  context: context)
                          )
                        ],
                      )),
                ),
              ]),
            ),
          ],
        ));
  }

  String? _validateUsername(String? value) {
    if (!_isSubmitted) return null;
    return _validationService.validateUserUsername(value?.trim());
  }

  String? _validatePassword(String? value) {
    if (!_isSubmitted) return null;

    return _validationService.validateUserPassword(value);
  }

  bool? _validateForm() {
    if (_loginFeedback != null) {
      _setLoginFeedback(null);
    }
    return _formKey.currentState?.validate();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _passwordIsVisible = !_passwordIsVisible;
    });
  }

  void _setLoginFeedback(String? feedback) {
    setState(() {
      _loginFeedback = feedback;
    });
  }

  void _setLoginInProgress(bool loginInProgress) {
    setState(() {
      _loginInProgress = loginInProgress;
    });
  }
}
