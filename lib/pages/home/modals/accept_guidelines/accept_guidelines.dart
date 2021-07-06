import 'package:Okuna/services/httpie.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/navigation_service.dart';
import 'package:Okuna/services/toast.dart';
import 'package:Okuna/services/user.dart';
import 'package:Okuna/widgets/alerts/alert.dart';
import 'package:Okuna/widgets/buttons/button.dart';
import 'package:Okuna/widgets/markdown.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/widgets/progress_indicator.dart';
import 'package:Okuna/widgets/theming/primary_color_container.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:async/async.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OBAcceptGuidelinesModal extends StatefulWidget {
  @override
  OBAcceptGuidelinesModalState createState() {
    return OBAcceptGuidelinesModalState();
  }
}

class OBAcceptGuidelinesModalState extends State {
  late NavigationService _navigationService;
  late ToastService _toastService;
  late LocalizationService _localizationService;
  late UserService _userService;
  late String _guidelinesText;
  late bool _needsBootstrap;
  late bool _acceptButtonEnabled;
  late bool _acceptGuidelinesInProgress;
  late bool _refreshGuidelinesInProgress;
  late ScrollController _guidelinesScrollController;

  CancelableOperation? _getGuidelinesOperation;

  @override
  void initState() {
    super.initState();
    _needsBootstrap = true;
    _acceptGuidelinesInProgress = false;
    _refreshGuidelinesInProgress = false;
    _guidelinesText = '';
    _acceptButtonEnabled = false;
    _guidelinesScrollController = ScrollController();
    _guidelinesScrollController.addListener(_onGuidelinesScroll);
  }

  @override
  void dispose() {
    super.dispose();
    if (_getGuidelinesOperation != null) _getGuidelinesOperation!.cancel();
  }

  void _bootstrap() async {
    return _refreshGuidelines();
  }

  @override
  Widget build(BuildContext context) {
    if (_needsBootstrap) {
      OpenbookProviderState openbookProvider = OpenbookProvider.of(context);
      _toastService = openbookProvider.toastService;
      _localizationService = openbookProvider.localizationService;
      _userService = openbookProvider.userService;
      _navigationService = openbookProvider.navigationService;
      _bootstrap();
      _needsBootstrap = false;
    }

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: CupertinoPageScaffold(
        child: OBPrimaryColorContainer(
          child: Column(
            children: <Widget>[
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(top: 20, left: 20, right: 20),
                  child: OBText(
                    _localizationService.user__guidelines_desc,
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 20, right: 20, top: 20),
                  child: OBAlert(
                    child: ListView(
                      controller: _guidelinesScrollController,
                      children: <Widget>[
                        _refreshGuidelinesInProgress
                            ? Row(
                                children: <Widget>[
                                  const Padding(
                                    padding: EdgeInsets.all(20),
                                    child: OBProgressIndicator(),
                                  )
                                ],
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                              )
                            : OBMarkdown(
                                onlyBody: true,
                                data: _guidelinesText,
                              )
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: _buildPreviousButton(context: context),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Expanded(child: _buildNextButton()),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    return OBButton(
      type: OBButtonType.success,
      minWidth: double.infinity,
      size: OBButtonSize.large,
      child: Text(_localizationService.user__guidelines_accept, style: TextStyle(fontSize: 18.0)),
      isDisabled: !_acceptButtonEnabled && _guidelinesText.isNotEmpty,
      isLoading: _acceptGuidelinesInProgress,
      onPressed: _acceptGuidelines,
    );
  }

  Widget _buildPreviousButton({required BuildContext context}) {
    return OBButton(
      type: OBButtonType.danger,
      minWidth: double.infinity,
      size: OBButtonSize.large,
      child: Row(
        children: <Widget>[
          Text(
           _localizationService.user__guidelines_reject,
            style: TextStyle(fontSize: 18.0, color: Colors.white),
          )
        ],
      ),
      onPressed: () {
        _navigationService.navigateToConfirmRejectGuidelinesPage(
            context: context);
      },
    );
  }

  void _refreshGuidelines() async {
    _setRefreshGuidelinesInProgress(true);
    try {
      OpenbookProviderState openbookProvider = OpenbookProvider.of(context);
      _getGuidelinesOperation = CancelableOperation.fromFuture(
          openbookProvider.documentsService.getCommunityGuidelines());

      String? guidelines = await _getGuidelinesOperation?.value;
      if (guidelines != null) {
        _setGuidelinesText(guidelines);
      }
    } catch (error) {
      _onError(error);
    } finally {
      _setRefreshGuidelinesInProgress(false);
    }
  }

  Future _acceptGuidelines() async {
    _setAcceptGuidelinesInProgress(true);
    try {
      await _userService.acceptGuidelines();
      await _userService.refreshUser();
      Navigator.pop(context);
    } catch (error) {
      _onError(error);
    } finally {
      _setAcceptGuidelinesInProgress(false);
    }
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

  void _setGuidelinesText(String guidelinesText) {
    setState(() {
      _guidelinesText = guidelinesText;
    });
  }

  void _onGuidelinesScroll() {
    if (!_acceptButtonEnabled
        && _guidelinesText.isNotEmpty &&
        _guidelinesScrollController.position.pixels >
            (_guidelinesScrollController.position.maxScrollExtent * 0.9)) {
      _setAcceptButtonEnabled(true);
    }
  }

  void _setAcceptButtonEnabled(bool acceptButtonEnabled) {
    setState(() {
      _acceptButtonEnabled = acceptButtonEnabled;
    });
  }

  void _setAcceptGuidelinesInProgress(bool acceptGuidelinesInProgress) {
    setState(() {
      _acceptGuidelinesInProgress = acceptGuidelinesInProgress;
    });
  }

  void _setRefreshGuidelinesInProgress(bool refreshGuidelinesInProgress) {
    setState(() {
      _refreshGuidelinesInProgress = refreshGuidelinesInProgress;
    });
  }
}
