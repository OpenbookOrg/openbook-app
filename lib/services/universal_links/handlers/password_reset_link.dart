import 'dart:async';
import 'package:Okuna/pages/auth/create_account/blocs/create_account.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/universal_links/universal_links.dart';
import 'package:flutter/material.dart';

class PasswordResetLinkHandler extends UniversalLinkHandler {
  static const String passwordResetVerifyLink = '/api/auth/password/verify';

  @override
  Future handle({required BuildContext context, required String link}) async{
    if (link.indexOf(passwordResetVerifyLink) != -1) {
      final token = getPasswordResetVerificationTokenFromLink(link);
      OpenbookProviderState openbookProvider = OpenbookProvider.of(context);
      CreateAccountBloc createAccountBloc = openbookProvider.createAccountBloc;
      createAccountBloc.setPasswordResetToken(token);
      Navigator.pushReplacementNamed(context, '/auth/set_new_password_step');
    }
  }

  String getPasswordResetVerificationTokenFromLink(String link) {
    final params = Uri.parse(link).queryParametersAll;
    var token = '';
    if (params.containsKey('token')) {
      token = params['token']![0];
    }
    return token;
  }
}
