import 'package:Okuna/provider.dart';
import 'package:Okuna/pages/auth/create_account/blocs/create_account.dart';
import 'package:Okuna/services/httpie.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/toast.dart';
import 'package:Okuna/services/validation.dart';
import 'package:Okuna/widgets/buttons/button.dart';
import 'package:Okuna/widgets/buttons/success_button.dart';
import 'package:Okuna/widgets/buttons/secondary_button.dart';
import 'package:Okuna/pages/auth/create_account/widgets/auth_text_field.dart';
import 'package:flutter/material.dart';
import 'package:async/async.dart';

class OBAuthCreateAccountPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return OBAuthCreateAccountPageState();
  }
}

class OBAuthCreateAccountPageState extends State<OBAuthCreateAccountPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late CreateAccountBloc _createAccountBloc;
  late LocalizationService _localizationService;
  late ValidationService _validationService;
  late ToastService _toastService;

  TextEditingController _linkController = TextEditingController();

  late bool _tokenIsInvalid;
  late bool _tokenValidationInProgress;

  CancelableOperation? _tokenValidationOperation;

  @override
  void initState() {
    super.initState();
    _tokenIsInvalid = false;
    _tokenValidationInProgress = false;
    _linkController.addListener(_onLinkChanged);
  }

  @override
  void dispose() {
    super.dispose();
    _linkController.removeListener(_onLinkChanged);
    _tokenValidationOperation?.cancel();
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
                    _buildPasteRegisterLink(context: context),
                    const SizedBox(
                      height: 20.0,
                    ),
                    _buildLinkForm(),
                    const SizedBox(height: 20.0),
                    _buildRequestInvite(context: context)
                  ],
                ))),
      ),
      backgroundColor: Colors.indigoAccent,
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent,
        elevation: 0.0,
        child: Padding(
          padding: EdgeInsets.only(
              bottom: 20.0 + MediaQuery.of(context).viewInsets.bottom,
              top: 20.0,
              left: 20.0,
              right: 20.0),
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

  Future<bool> _validateForm() async {
    if (_formKey.currentState?.validate() == true) {
      bool tokenIsValid = await _validateToken();
      if (!tokenIsValid) _setTokenIsInvalid(true);
      return tokenIsValid;
    }
    return false;
  }

  void onPressedNextStep(BuildContext context) async {
    bool isFormValid = await _validateForm();

    if (isFormValid) {
      setState(() {
        var token = _getTokenFromLink(_linkController.text.trim());
        _createAccountBloc.setToken(token);
        Navigator.pushNamed(context, '/auth/get-started');
      });
    }
  }

  String _getTokenFromLink(String link) {
    final uri = Uri.decodeFull(link);
    final params = Uri.parse(uri).queryParametersAll;
    var token = '';
    if (params.containsKey('token')) {
      token = params['token']![0];
    } else {
      token = uri.split('?token=')[1];
    }
    return token;
  }

  Widget _buildNextButton(BuildContext context) {
    String buttonText = _localizationService.trans('auth__create_acc__next');

    return OBSuccessButton(
      minWidth: double.infinity,
      size: OBButtonSize.large,
      isLoading: _tokenValidationInProgress,
      child: Text(buttonText, style: TextStyle(fontSize: 18.0)),
      onPressed: () {
        onPressedNextStep(context);
      },
    );
  }

  Widget _buildPreviousButton({required BuildContext context}) {
    String buttonText =
        _localizationService.trans('auth__create_acc__previous');

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

  Widget _buildPasteRegisterLink({required BuildContext context}) {
    String pasteLinkText =
        _localizationService.trans('auth__create_acc__paste_link');

    return Column(
      children: <Widget>[
        Text(
          '🔗',
          style: TextStyle(fontSize: 45.0, color: Colors.white),
        ),
        const SizedBox(
          height: 20.0,
        ),
        Text(pasteLinkText,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
      ],
    );
  }

  Widget _buildLinkForm() {
    return Form(
      key: _formKey,
      child: Row(children: <Widget>[
        new Expanded(
          child: Container(
              color: Colors.transparent,
              child: OBAuthTextField(
                autocorrect: false,
                hintText: '',
                validator: (String? link) {
                  String? validateLink = _validationService
                      .validateUserRegistrationLink(link?.trim());
                  if (validateLink != null) {
                    return validateLink;
                  }

                  if (_tokenIsInvalid) {
                    return _localizationService.auth__create_acc__invalid_token;
                  }

                  return null;
                },
                controller: _linkController,
                onFieldSubmitted: (v) => onPressedNextStep(context),
              )),
        ),
      ]),
    );
  }

  Widget _buildRequestInvite({required BuildContext context}) {
    String requestInviteText =
        _localizationService.trans('auth__create_acc__request_invite');

    return OBSecondaryButton(
      isFullWidth: true,
      isLarge: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            requestInviteText,
            style: TextStyle(fontSize: 18.0, color: Colors.white),
          )
        ],
      ),
      onPressed: () {
        Navigator.pushNamed(context, '/waitlist/subscribe_email_step');
      },
    );
  }

  _validateToken() async {
    _setTokenValidationInProgress(true);
    String token = _getTokenFromLink(_linkController.text.trim());
    debugPrint('Validating token ${token}');

    try {
      final isTokenValid = await _validationService.isInviteTokenValid(token);
      debugPrint('Token was valid:  ${isTokenValid}');
      return isTokenValid;
    } catch (error) {
      _onError(error);
    } finally {
      _setTokenValidationInProgress(false);
    }
  }

  _onLinkChanged() {
    if (_tokenIsInvalid) _setTokenIsInvalid(false);
  }

  _setTokenIsInvalid(bool tokenIsInvalid) {
    setState(() {
      _tokenIsInvalid = tokenIsInvalid;
      _formKey.currentState?.validate();
    });
  }

  _setTokenValidationInProgress(bool tokenValidationInProgress) {
    setState(() {
      _tokenValidationInProgress = tokenValidationInProgress;
    });
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
}
