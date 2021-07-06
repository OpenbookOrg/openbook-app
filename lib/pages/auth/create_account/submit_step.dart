import 'package:Okuna/pages/auth/create_account/blocs/create_account.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/widgets/buttons/secondary_button.dart';
import 'package:flutter/material.dart';

class OBAuthSubmitPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return OBAuthSubmitPageState();
  }
}

class OBAuthSubmitPageState extends State<OBAuthSubmitPage> {
  late LocalizationService localizationService;
  late CreateAccountBloc createAccountBloc;

  late bool mustRequestCreateAccount;

  @override
  void initState() {
    mustRequestCreateAccount = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var openbookProvider = OpenbookProvider.of(context);
    localizationService = openbookProvider.localizationService;
    createAccountBloc = openbookProvider.createAccountBloc;

    if (mustRequestCreateAccount) {
      _requestCreateAccount();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.0),
        child: Center(child: SingleChildScrollView(child: _buildStatus())),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBottomBar() {
    return BottomAppBar(
      color: Colors.transparent,
      elevation: 0.0,
      child: StreamBuilder(
          stream: createAccountBloc.createAccountErrorFeedback,
          initialData: null,
          builder: (BuildContext builder, snapshot) {
            var createAccountErrorFeedback = snapshot.data;

            if (createAccountErrorFeedback == null) {
              return SizedBox(
                  child: Column(
                mainAxisSize: MainAxisSize.min,
              ));
            }

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: _buildPreviousButton(context: context),
                  ),
                ],
              ),
            );
          }),
    );
  }

  Widget _buildStatus() {
    return StreamBuilder(
      stream: createAccountBloc.createAccountErrorFeedback,
      initialData: null,
      builder: (context, snapshot) {
        var createAccountErrorFeedback = snapshot.data as String?;

        if (createAccountErrorFeedback != null) {
          return _buildStatusError(context, createAccountErrorFeedback);
        }

        return _buildStatusLoading(context);
      },
    );
  }

  Widget _buildStatusError(BuildContext context, String errorFeedback) {
    var errorTitle =
        localizationService.trans('auth__create_acc__submit_error_title');

    var errorDescription = errorFeedback;

    return Column(
      children: <Widget>[
        Text(
          '😥‍',
          style: TextStyle(fontSize: 45.0, color: Colors.white),
        ),
        const SizedBox(
          height: 20.0,
        ),
        Text(errorTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              //color: Colors.white
            )),
        const SizedBox(
          height: 20.0,
        ),
        Text(errorDescription,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18.0,
              //color: Colors.white
            ))
      ],
    );
  }

  Widget _buildStatusLoading(BuildContext context) {
    var loadingTitle =
        localizationService.trans('auth__create_acc__submit_loading_title');

    var loadingDescription =
        localizationService.trans('auth__create_acc__submit_loading_desc');

    return Column(
      children: <Widget>[
        Text(
          '🥚‍',
          style: TextStyle(fontSize: 45.0, color: Colors.white),
        ),
        const SizedBox(
          height: 20.0,
        ),
        Text(loadingTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              //color: Colors.white
            )),
        const SizedBox(
          height: 20.0,
        ),
        Text(loadingDescription,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18.0,
              //color: Colors.white
            ))
      ],
    );
  }

  Widget _buildPreviousButton({required BuildContext context}) {
    String buttonText = localizationService.trans('auth__create_acc__previous');

    return OBSecondaryButton(
      isFullWidth: true,
      isLarge: true,
      child: Row(
        children: <Widget>[
          Icon(
            Icons.arrow_back_ios,
          ),
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

  void _requestCreateAccount() async {
    bool createdAccount = await createAccountBloc.createAccount();
    if (createdAccount) {
      createAccountBloc.clearAll();
      Navigator.pushNamed(context, '/auth/done_step');
    }
    mustRequestCreateAccount = false;
  }
}
