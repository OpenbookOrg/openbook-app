import 'package:Okuna/pages/auth/create_account/blocs/create_account.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/widgets/buttons/button.dart';
import 'package:Okuna/widgets/buttons/success_button.dart';
import 'package:flutter/material.dart';

class OBAuthDonePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return OBAuthDonePageState();
  }
}

class OBAuthDonePageState extends State<OBAuthDonePage> {
  LocalizationService localizationService;
  CreateAccountBloc createAccountBloc;

  @override
  Widget build(BuildContext context) {
    var openbookProvider = OpenbookProvider.of(context);
    localizationService = openbookProvider.localizationService;
    createAccountBloc = openbookProvider.createAccountBloc;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                colorFilter: new ColorFilter.mode(
                    Colors.white.withOpacity(0.1), BlendMode.dstATop),
                image: new AssetImage('assets/images/confetti-background.gif'),
                fit: BoxFit.cover)),
        padding: EdgeInsets.symmetric(horizontal: 40.0),
        child: Center(child: SingleChildScrollView(child: _buildHooray())),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBottomBar() {
    return BottomAppBar(
      color: Colors.transparent,
      elevation: 0.0,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
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

  Widget _buildHooray() {
    String title = localizationService.trans('auth__create_acc__done_title');
    String usernameSubtext = localizationService.trans('auth__create_acc__done_subtext');
    String accCreated = localizationService.trans('auth__create_acc__done_created');

    String username = createAccountBloc.getUsername();

    return Column(
      children: <Widget>[
        Text(
          '🐣‍',
          style: TextStyle(fontSize: 45.0, color: Colors.white),
        ),
        const SizedBox(
          height: 20.0,
        ),
        Text(title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              //color: Colors.white
            )),
        const SizedBox(
          height: 20.0,
        ),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.black,
              ),
              children: [
                TextSpan(text: accCreated),
                TextSpan(
                    text: '@$username',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: '.')
              ]),
        ),
        const SizedBox(
          height: 20.0,
        ),
        Text(usernameSubtext,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16
                //color: Colors.white
                )),
      ],
    );
  }

  Widget _buildNextButton({@required BuildContext context}) {
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
        Navigator.popUntil(context, ModalRoute.withName('/auth/get-started'));
        Navigator.pushReplacementNamed(context, '/');
      },
    );
  }
}
