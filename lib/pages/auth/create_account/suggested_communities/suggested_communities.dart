import 'package:Okuna/pages/auth/create_account/blocs/create_account.dart';
import 'package:Okuna/pages/auth/create_account/suggested_communities/widgets/suggested_communities/suggested_communities.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/widgets/buttons/button.dart';
import 'package:Okuna/widgets/buttons/success_button.dart';
import 'package:flutter/material.dart';

class OBSuggestedCommunitiesPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return OBSuggestedCommunitiesPageState();
  }
}

class OBSuggestedCommunitiesPageState
    extends State<OBSuggestedCommunitiesPage> {
  late LocalizationService localizationService;
  late CreateAccountBloc createAccountBloc;
  bool _isCommunitySelectionInProgress = false;

  @override
  Widget build(BuildContext context) {
    var openbookProvider = OpenbookProvider.of(context);
    localizationService = openbookProvider.localizationService;
    createAccountBloc = openbookProvider.createAccountBloc;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                colorFilter: new ColorFilter.mode(
                    Colors.white.withOpacity(0.1), BlendMode.dstATop),
                image: new AssetImage('assets/images/confetti-background.gif'),
                fit: BoxFit.cover)),
        padding: EdgeInsets.symmetric(horizontal: 20.0),
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
          padding: EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: _buildContinueButton(context: context),
                  ),
                ],
              ),
            ],
          )),
    );
  }

  Widget _buildHooray() {
    String title = localizationService.auth__create_acc__suggested_communities;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22.0,
              //color: Colors.white
            )),
        const SizedBox(
          height: 30.0,
        ),
        OBSuggestedCommunities(onNoSuggestions: goToNextStep),
      ],
    );
  }

  void onCommunitySelectionInProgress(bool isCommunitySelectionInProgress) {
    setState(() {
      _isCommunitySelectionInProgress = isCommunitySelectionInProgress;
    });
  }

  Widget _buildContinueButton({required BuildContext context}) {
    String buttonText = localizationService.auth__login__login;

    return OBSuccessButton(
        minWidth: double.infinity,
        size: OBButtonSize.large,
        isDisabled: _isCommunitySelectionInProgress,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              buttonText,
              style: TextStyle(fontSize: 18.0),
            )
          ],
        ),
        onPressed: goToNextStep);
  }

  void goToNextStep() {
    Navigator.popUntil(context, ModalRoute.withName('/auth/get-started'));
    Navigator.pushReplacementNamed(context, '/');
  }
}
