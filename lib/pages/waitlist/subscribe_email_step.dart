import 'package:Okuna/pages/waitlist/subscribe_done_step.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/toast.dart';
import 'package:Okuna/services/user.dart';
import 'package:Okuna/services/validation.dart';
import 'package:Okuna/widgets/buttons/button.dart';
import 'package:Okuna/widgets/buttons/success_button.dart';
import 'package:Okuna/widgets/buttons/secondary_button.dart';
import 'package:Okuna/pages/auth/create_account/widgets/auth_text_field.dart';
import 'package:flutter/material.dart';

class OBWaitlistSubscribePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return OBWaitlistSubscribePageState();
  }
}

class OBWaitlistSubscribePageState extends State<OBWaitlistSubscribePage> {
  late bool _subscribeInProgress;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late bool _isSubmitted;
  late UserService _userService;
  late LocalizationService _localizationService;
  late ValidationService _validationService;
  late ToastService _toastService;

  TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _isSubmitted = false;
    _subscribeInProgress = false;
    _emailController.addListener(_validateForm);
  }

  @override
  Widget build(BuildContext context) {
    var openbookProvider = OpenbookProvider.of(context);
    _localizationService = openbookProvider.localizationService;
    _validationService = openbookProvider.validationService;
    _userService = openbookProvider.userService;
    _toastService = openbookProvider.toastService;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.0),
                child: Column(
                  children: <Widget>[
                    _buildSubscribeEmailText(context: context),
                    const SizedBox(
                      height: 20.0,
                    ),
                    _buildEmailForm()
                  ],
                ))),
      ),
      backgroundColor: Color(0xFFFFB649),
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

  bool? _validateForm() {
    if (!_isSubmitted) return null;
    return _formKey.currentState?.validate();
  }

  void onPressedNextStep(BuildContext context) async {
    if (_subscribeInProgress) return;
    _isSubmitted = true;
    bool? isEmailValid = _validateForm();

    if (isEmailValid == null || !isEmailValid) return;

    _setSubscribeInProgress(true);
    try {
      int count = await _userService.subscribeToBetaWaitlist(
          email: _emailController.text.trim());
      WaitlistSubscribeArguments args =
          new WaitlistSubscribeArguments(count: count);
      Navigator.pushNamed(context, '/waitlist/subscribe_done_step',
          arguments: args);
    } catch (error) {
      _onError(error);
    } finally {
      _setSubscribeInProgress(false);
    }
  }

  Widget _buildNextButton(BuildContext context) {
    String buttonText = _localizationService.trans('auth__create_acc__subscribe');

    return OBSuccessButton(
      minWidth: double.infinity,
      size: OBButtonSize.large,
      isLoading: _subscribeInProgress,
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

  Widget _buildSubscribeEmailText({required BuildContext context}) {
    String subscribeEmailText = _localizationService
        .trans('auth__create_acc__subscribe_to_waitlist_text');

    return Column(
      children: <Widget>[
        Text(
          '💌',
          style: TextStyle(fontSize: 45.0, color: Colors.white),
        ),
        const SizedBox(
          height: 20.0,
        ),
        Text(subscribeEmailText,
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
                  String? validateEMail =
                      _validationService.validateUserEmail(email?.trim());
                  if (validateEMail != null) return validateEMail;
                },
                controller: _emailController,
                onFieldSubmitted: (v) => onPressedNextStep(context),
              )),
        ),
      ]),
    );
  }

  void _onError(error) async {
    if (error is HttpieConnectionRefusedError) {
      _toastService.error(
          message: error.toHumanReadableMessage(), context: context);
    } else if (error is HttpieRequestError) {
      String? errorMessage = await error.toHumanReadableMessage();
      _toastService.error(message: errorMessage ?? 'Unknown error', context: context);
    } else {
      _toastService.error(message: 'Unknown error', context: context);
      throw error;
    }
  }

  void _setSubscribeInProgress(subscribeInProgress) {
    setState(() {
      _subscribeInProgress = subscribeInProgress;
    });
  }
}
