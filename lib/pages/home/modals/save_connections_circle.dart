import 'package:Okuna/models/circle.dart';
import 'package:Okuna/models/user.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/widgets/fields/color_field.dart';
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
import 'package:Okuna/widgets/theming/text.dart';
import 'package:Okuna/widgets/tiles/user_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OBSaveConnectionsCircleModal extends StatefulWidget {
  final Circle? connectionsCircle;
  final bool autofocusNameTextField;

  OBSaveConnectionsCircleModal(
      {this.connectionsCircle, this.autofocusNameTextField = false});

  @override
  OBSaveConnectionsCircleModalState createState() {
    return OBSaveConnectionsCircleModalState();
  }
}

class OBSaveConnectionsCircleModalState
    extends State<OBSaveConnectionsCircleModal> {
  static const double INPUT_COLORS_SIZE = 16;

  late UserService _userService;
  late ToastService _toastService;
  late LocalizationService _localizationService;
  late ValidationService _validationService;

  late bool _requestInProgress;
  late bool _formWasSubmitted;
  late bool _formValid;
  late bool _hasExistingCircle;
  String? _takenConnectionsCircleName;
  late List<User> _users;

  late GlobalKey<FormState> _formKey;

  late TextEditingController _nameController;
  String? _color;

  @override
  void initState() {
    super.initState();
    _formValid = true;
    _requestInProgress = false;
    _formWasSubmitted = false;
    _nameController = TextEditingController();
    _formKey = GlobalKey<FormState>();
    _hasExistingCircle = widget.connectionsCircle != null;
    _users = _hasExistingCircle && widget.connectionsCircle!.hasUsers()
        ? widget.connectionsCircle!.users!.users!.toList()
        : [];

    if (_hasExistingCircle) {
      _nameController.text = widget.connectionsCircle!.name ?? '';
      _color = widget.connectionsCircle!.color;
    }

    _nameController.addListener(_updateFormValid);
  }

  @override
  Widget build(BuildContext context) {
    var openbookProvider = OpenbookProvider.of(context);
    _userService = openbookProvider.userService;
    _toastService = openbookProvider.toastService;
    _localizationService = openbookProvider.localizationService;
    _validationService = openbookProvider.validationService;
    var themeService = openbookProvider.themeService;

    _color = _color ?? themeService.generateRandomHexColor();

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
                                autofocus: widget.autofocusNameTextField,
                                controller: _nameController,
                                decoration: InputDecoration(
                                    labelText: _localizationService.trans('user__save_connection_circle_name'),
                                    hintText: _localizationService.trans('user__save_connection_circle_hint')),
                                validator: (String? connectionsCircleName) {
                                  if (!_formWasSubmitted) return null;

                                  if (_takenConnectionsCircleName != null &&
                                      _takenConnectionsCircleName ==
                                          connectionsCircleName) {
                                    return _localizationService.user__save_connection_circle_name_taken(_takenConnectionsCircleName!);
                                  }

                                  return _validationService
                                      .validateConnectionsCircleName(
                                          connectionsCircleName);
                                }),
                            OBColorField(
                              initialColor: _color,
                              onNewColor: _onNewColor,
                              labelText: _localizationService.trans('user__save_connection_circle_color_name'),
                              hintText: _localizationService.trans('user__save_connection_circle_color_hint'),
                            ),
                          ],
                        )),
                    _users.length > 0
                        ? Padding(
                            padding: EdgeInsets.only(
                                left: 20, top: 20, bottom: 20.0),
                            child: OBText(
                              _localizationService.trans('user__save_connection_circle_users'),
                              style: TextStyle(fontWeight: FontWeight.bold),
                              size: OBTextSize.large,
                            ),
                          )
                        : const SizedBox(),
                    Column(
                        children: _users.map((User user) {
                      return OBUserTile(
                        user,
                        showFollowing: false,
                        onUserTileDeleted: (User user) {
                          setState(() {
                            _users.remove(user);
                          });
                        },
                      );
                    }).toList())
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
        title: _hasExistingCircle ? _localizationService.trans('user__save_connection_circle_edit'):
        _localizationService.trans('user__save_connection_circle_create'),
        trailing: OBButton(
          isDisabled: !_formValid,
          isLoading: _requestInProgress,
          size: OBButtonSize.small,
          onPressed: _submitForm,
          child: Text(_localizationService.trans('user__save_connection_circle_save')),
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
      var connectionsCircleName = _nameController.text;
      bool connectionsCircleNameTaken =
          await _isConnectionsCircleNameTaken(connectionsCircleName);

      if (connectionsCircleNameTaken) {
        _setTakenConnectionsCircleName(connectionsCircleName);
        _validateForm();
        return;
      }

      Circle connectionsCircle = await (_hasExistingCircle
          ? _userService.updateConnectionsCircle(widget.connectionsCircle!,
              name: _nameController.text != widget.connectionsCircle!.name
                  ? _nameController.text
                  : null,
              users: _users,
              color: _color)
          : _userService.createConnectionsCircle(
              name: _nameController.text, color: _color));

      Navigator.of(context).pop(connectionsCircle);
    } catch (error) {
      _onError(error);
    } finally {
      _setRequestInProgress(false);
    }
  }

  void _onError(error) async {
    if (error is HttpieConnectionRefusedError) {
      _toastService.error(
          message: error.toHumanReadableMessage(), context: context);
    } else if (error is HttpieRequestError) {
      String? errorMessage = await error.toHumanReadableMessage();
      _toastService.error(message: errorMessage ?? _localizationService.trans('error__unknown_error'), context: context);
    } else {
      _toastService.error(message: _localizationService.trans('error__unknown_error'), context: context);
      throw error;
    }
  }

  Future<bool> _isConnectionsCircleNameTaken(
      String connectionsCircleName) async {
    if (_hasExistingCircle &&
        widget.connectionsCircle?.name == _nameController.text) {
      return false;
    }
    return _validationService
        .isConnectionsCircleNameTaken(connectionsCircleName);
  }

  void _onNewColor(String newColor) {
    _setColor(newColor);
  }

  void _setColor(String color) {
    setState(() {
      _color = color;
    });
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

  void _setTakenConnectionsCircleName(String takenConnectionsCircleName) {
    setState(() {
      _takenConnectionsCircleName = takenConnectionsCircleName;
    });
  }
}
