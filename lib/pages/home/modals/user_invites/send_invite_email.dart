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

class OBSendUserInviteEmailModal extends StatefulWidget {
  final UserInvite? userInvite;
  final bool autofocusEmailTextField;

  OBSendUserInviteEmailModal(
      {this.userInvite, this.autofocusEmailTextField = false});

  @override
  OBSendUserInviteEmailModalState createState() {
    return OBSendUserInviteEmailModalState();
  }
}

class OBSendUserInviteEmailModalState
    extends State<OBSendUserInviteEmailModal> {

  late UserService _userService;
  late ToastService _toastService;
  late ValidationService _validationService;
  late LocalizationService _localizationService;

  CancelableOperation? _emailOperation;

  late bool _requestInProgress;
  late bool _formWasSubmitted;
  late bool _formValid;

  late GlobalKey<FormState> _formKey;

  late TextEditingController _emailController;

  @override
  void dispose() {
    super.dispose();
    if (_emailOperation != null) _emailOperation!.cancel();
  }

  @override
  void initState() {
    super.initState();
    _formValid = true;
    _requestInProgress = false;
    _formWasSubmitted = false;
    _emailController = TextEditingController();
    _formKey = GlobalKey<FormState>();
    if (widget.userInvite?.email != null) {
      _emailController.text = widget.userInvite!.email!;
    }

    _emailController.addListener(_updateFormValid);
  }

  @override
  Widget build(BuildContext context) {
    var openbookProvider = OpenbookProvider.of(context);
    _userService = openbookProvider.userService;
    _toastService = openbookProvider.toastService;
    _localizationService = openbookProvider.localizationService;
    _validationService = openbookProvider.validationService;

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
                                autofocus: widget.autofocusEmailTextField,
                                controller: _emailController,
                                decoration: InputDecoration(
                                    labelText: _localizationService.user__invites_email_text,
                                    hintText: _localizationService.user__invites_email_hint),
                                validator: (String? email) {
                                  if (!_formWasSubmitted) return null;
                                  return _validationService.validateUserEmail(email);
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
        title: _localizationService.user__invites_email_invite_text,
        trailing: OBButton(
          isDisabled: !_formValid,
          isLoading: _requestInProgress,
          size: OBButtonSize.small,
          onPressed: _submitForm,
          child: Text(_localizationService.user__invites_email_send_text),
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
      _emailOperation = CancelableOperation.fromFuture(
          _userService.sendUserInviteEmail(
              widget.userInvite!, _emailController.text)
      );
      await _emailOperation?.value;
      _showUserInviteSent();
      Navigator.of(context).pop(widget.userInvite);
    } catch (error) {
      _onError(error);
    } finally {
      _setRequestInProgress(false);
      _emailOperation = null;
    }
  }

  void _showUserInviteSent() {
    _toastService.success(message: _localizationService.user__invites_email_sent_text, context: context);
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
