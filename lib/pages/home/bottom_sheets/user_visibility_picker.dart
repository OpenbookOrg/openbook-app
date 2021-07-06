import 'package:Okuna/models/user.dart';
import 'package:Okuna/pages/home/bottom_sheets/rounded_bottom_sheet.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/httpie.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/toast.dart';
import 'package:Okuna/services/user.dart';
import 'package:Okuna/widgets/buttons/button.dart';
import 'package:Okuna/widgets/fields/checkbox_field.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:Okuna/widgets/user_visibility_icon.dart';
import 'package:async/async.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OBUserVisibilityPickerBottomSheet extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return OBUserVisibilityPickerBottomSheetState();
  }
}

class OBUserVisibilityPickerBottomSheetState
    extends State<OBUserVisibilityPickerBottomSheet> {
  late ToastService _toastService;
  late LocalizationService _localizationService;
  late UserService _userService;
  late bool _needsBootstrap;

  late bool _isUserVisibilityPickerInProgress;
  CancelableOperation? _userVisibilityPickerOperation;

  late Map<UserVisibility, Map<String, String>> _userVisibilitiesLocalizationMap;

  late UserVisibility _selectedUserVisibility;
  late UserVisibility _currentUserVisibility;

  @override
  void initState() {
    super.initState();
    _needsBootstrap = true;
    _isUserVisibilityPickerInProgress = false;
  }

  @override
  void dispose() {
    super.dispose();
    _userVisibilityPickerOperation?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    if (_needsBootstrap) {
      var openbookProvider = OpenbookProvider.of(context);
      _userService = openbookProvider.userService;
      _currentUserVisibility =
          openbookProvider.userService.getLoggedInUser()!.visibility!;
      _selectedUserVisibility = _currentUserVisibility;
      _toastService = openbookProvider.toastService;
      _localizationService = openbookProvider.localizationService;
      _userVisibilitiesLocalizationMap =
          openbookProvider.userService.getUserVisibilityLocalizationMap();
      _needsBootstrap = false;
    }

    bool selectionIsTheCurrentOne =
        _selectedUserVisibility == _currentUserVisibility;

    List<Widget> columnItems = [
      Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
        child: OBText(
          'Update profile visibility',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          textAlign: TextAlign.left,
        ),
      ),
      const SizedBox(height: 10,),
      OBCheckboxField(
        leading: OBUserVisibilityIcon(visibility: UserVisibility.public,),
        value: _selectedUserVisibility == UserVisibility.public,
        title: _userVisibilitiesLocalizationMap[UserVisibility.public]!['title']!,
        subtitle: _userVisibilitiesLocalizationMap[UserVisibility.public]!
            ['description']!,
        onTap: () {
          _setSelectedVisibility(UserVisibility.public);
        },
      ),
      const SizedBox(height: 10,),
      OBCheckboxField(
        leading: OBUserVisibilityIcon(visibility: UserVisibility.okuna,),
        value: _selectedUserVisibility == UserVisibility.okuna,
        title: _userVisibilitiesLocalizationMap[UserVisibility.okuna]!['title']!,
        subtitle: _userVisibilitiesLocalizationMap[UserVisibility.okuna]!
            ['description']!,
        onTap: () {
          _setSelectedVisibility(UserVisibility.okuna);
        },
      ),
      const SizedBox(height: 10,),
      OBCheckboxField(
        leading: OBUserVisibilityIcon(visibility: UserVisibility.private,),
        value: _selectedUserVisibility == UserVisibility.private,
        title: _userVisibilitiesLocalizationMap[UserVisibility.private]!
            ['title']!,
        subtitle: _userVisibilitiesLocalizationMap[UserVisibility.private]!
            ['description']!,
        onTap: () {
          _setSelectedVisibility(UserVisibility.private);
        },
      ),
      const SizedBox(
        height: 20,
      ),
      Row(
        children: <Widget>[
          Expanded(
            child: OBButton(
              size: OBButtonSize.large,
              child: Text(selectionIsTheCurrentOne ? _localizationService.bottom_sheets__dismiss : _localizationService.post__edit_save),
              type: selectionIsTheCurrentOne
                  ? OBButtonType.highlight
                  : OBButtonType.success,
              isLoading: _isUserVisibilityPickerInProgress,
              onPressed:
                  selectionIsTheCurrentOne ? _onPressedCancel : _onPressedSave,
            ),
          )
        ],
      )
    ];

    return OBRoundedBottomSheet(
        child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 20),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: columnItems),
    ));
  }

  Future<void> _onPressedSave() async {
    _setUserVisibilityPickerInProgress(true);

    try {
      _userVisibilityPickerOperation = CancelableOperation.fromFuture(
          _userService.updateUser(visibility: _selectedUserVisibility));
      await _userVisibilityPickerOperation?.value;
      Navigator.pop(context);
    } catch (error) {
      _onError(error);
      rethrow;
    } finally {
      _setUserVisibilityPickerInProgress(false);
      _userVisibilityPickerOperation = null;
    }
  }

  void _onPressedCancel() {
    Navigator.pop(context);
  }

  void _onError(error) async {
    if (error is HttpieConnectionRefusedError) {
      _toastService.error(
          message: error.toHumanReadableMessage(), context: context);
    } else if (error is HttpieRequestError) {
      String? errorMessage = await error.toHumanReadableMessage();
      _toastService.error(message: errorMessage ?? _localizationService.error__unknown_error, context: context);
    } else {
      _toastService.error(
          message: _localizationService.error__unknown_error, context: context);
      throw error;
    }
  }

  void _setUserVisibilityPickerInProgress(bool userVisibilityPickerInProgress) {
    setState(() {
      _isUserVisibilityPickerInProgress = userVisibilityPickerInProgress;
    });
  }

  void _setSelectedVisibility(UserVisibility visibility) {
    setState(() {
      _selectedUserVisibility = visibility;
    });
  }
}
