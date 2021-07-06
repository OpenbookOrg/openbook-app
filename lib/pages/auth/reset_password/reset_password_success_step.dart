import 'package:Okuna/pages/auth/create_account/blocs/create_account.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/widgets/buttons/button.dart';
import 'package:Okuna/widgets/buttons/success_button.dart';
import 'package:flutter/material.dart';

class OBAuthPasswordResetSuccessPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return OBAuthPasswordResetSuccessPageState();
  }
}

class OBAuthPasswordResetSuccessPageState extends State<OBAuthPasswordResetSuccessPage> {
  late LocalizationService localizationService;
  late CreateAccountBloc createAccountBloc;

  @override
  Widget build(BuildContext context) {
    var openbookProvider = OpenbookProvider.of(context);
    localizationService = openbookProvider.localizationService;
    createAccountBloc = openbookProvider.createAccountBloc;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        child: Center(child: SingleChildScrollView(child: _buildAllSet(localizationService))),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBottomBar() {
    return BottomAppBar(
      color: Colors.transparent,
      elevation: 0.0,
      child: Container(
        padding: EdgeInsets.only(bottom: 20.0 + MediaQuery.of(context).viewInsets.bottom, top: 20.0, left: 20.0, right: 20.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: _buildNextButton(context: context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllSet(LocalizationService localizationService) {
    return Column(
      children: <Widget>[
        Text(
          '👍‍',
          style: TextStyle(fontSize: 45.0, color: Colors.white),
        ),
        const SizedBox(
          height: 20.0,
        ),
        Text(localizationService.auth__reset_password_success_title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              //color: Colors.white
            )),
        const SizedBox(
          height: 20.0,
        ),
        Text(localizationService.auth__reset_password_success_info,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20.0
          ),
        ),
        const SizedBox(
          height: 20.0,
        ),
      ]
    );
  }

  Widget _buildNextButton({required BuildContext context}) {
    String buttonText =
    localizationService.trans('auth__create_acc__done_continue');

    return OBSuccessButton(
      minWidth: double.infinity,
      size: OBButtonSize.large,
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
        Navigator.popUntil(context, (route){
          return route.isFirst;
        });
        Navigator.pushReplacementNamed(context, '/auth/login');
      },
    );
  }
}
