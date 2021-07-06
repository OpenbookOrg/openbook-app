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

class OBAuthEmailStepPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return OBAuthEmailStepPageState();
  }
}

class OBAuthEmailStepPageState extends State<OBAuthEmailStepPage> {
  late bool _emailCheckInProgress;
  bool? _emailTaken;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late CreateAccountBloc _createAccountBloc;
  late LocalizationService _localizationService;
  late ValidationService _validationService;
  late ToastService _toastService;

  TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    _emailCheckInProgress = false;
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
                    _buildWhatYourEmail(context: context),
                    const SizedBox(
                      height: 20.0,
                    ),
                    _buildEmailForm()
                  ],
                ))),
      ),
      backgroundColor: Color(0xFFFF3939),
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

  void _setEmailTaken(bool isEmailTaken) {
    setState(() {
      _emailTaken = isEmailTaken;
    });
  }

  Future<bool> _checkEmailAvailable(String email, BuildContext context) async {
    _setEmailCheckInProgress(true);
    bool isEmailTaken = false;
    try {
     isEmailTaken = await _validationService.isEmailTaken(email);
     _setEmailTaken(isEmailTaken);
    } catch (error) {
      String errorFeedback = _localizationService.trans('auth__create_acc__email_server_error');
      _toastService.error(message: errorFeedback, context: context);
    } finally {
      _setEmailCheckInProgress(false);
    }
    return isEmailTaken;
  }

  void onPressedNextStep(BuildContext context) async {
    await _checkEmailAvailable(_emailController.text.trim(), context);
    bool isEmailValid = _validateForm();
    if (isEmailValid && !(_emailTaken ?? true)) {
      setState(() {
        _createAccountBloc.setEmail(_emailController.text.trim());
        Navigator.pushNamed(context, '/auth/username_step');
      });
    }
  }

  Widget _buildNextButton(BuildContext context) {
    String buttonText = _localizationService.trans('auth__create_acc__next');

    return OBSuccessButton(
      minWidth: double.infinity,
      size: OBButtonSize.large,
      isLoading: _emailCheckInProgress,
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

  Widget _buildWhatYourEmail({required BuildContext context}) {
    String whatEmailText =
        _localizationService.trans('auth__create_acc__what_email');

    return Column(
      children: <Widget>[
        Text(
          '💌',
          style: TextStyle(fontSize: 45.0, color: Colors.white),
        ),
        const SizedBox(
          height: 20.0,
        ),
        Text(whatEmailText,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
      ],
    );
  }

  Widget _buildEmailForm() {

    String emailInputPlaceholder =
        _localizationService.trans('auth__create_acc__email_placeholder');
    String errorEmailTaken =
    _localizationService.trans('auth__create_acc__email_taken_error');

    return Form(
      key: _formKey,
      child: Row(children: <Widget>[
        new Expanded(
          child: Container(
              color: Colors.transparent,
              child: OBAuthTextField(
                autocorrect: false,
                hintText: emailInputPlaceholder,
                validator: (String? email) {
                  String? validateEMail = _validationService.validateUserEmail(email?.trim());
                  if (validateEMail != null) return validateEMail;
                  if (_emailTaken != null && _emailTaken!) {
                    return errorEmailTaken;
                  }
                },
                controller: _emailController,
                onFieldSubmitted: (v) => onPressedNextStep(context),
              )
          ),
        ),
      ]),
    );
  }

  void _setEmailCheckInProgress(bool newEmailCheckInProgress) {
    setState(() {
      _emailCheckInProgress = newEmailCheckInProgress;
    });
  }
}
