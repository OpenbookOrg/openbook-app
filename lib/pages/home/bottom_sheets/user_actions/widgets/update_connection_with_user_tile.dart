import 'package:Okuna/models/circle.dart';
import 'package:Okuna/models/user.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/bottom_sheet.dart';
import 'package:Okuna/services/httpie.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/toast.dart';
import 'package:Okuna/services/user.dart';
import 'package:Okuna/widgets/icon.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:flutter/material.dart';

class OBUpdateConnectionWithUserTile extends StatefulWidget {
  final User user;

  const OBUpdateConnectionWithUserTile(this.user,
      {Key? key})
      : super(key: key);

  @override
  OBUpdateConnectionWithUserTileState createState() {
    return OBUpdateConnectionWithUserTileState();
  }
}

class OBUpdateConnectionWithUserTileState
    extends State<OBUpdateConnectionWithUserTile> {
  late UserService _userService;
  late ToastService _toastService;
  late LocalizationService _localizationService;
  late BottomSheetService _bottomSheetService;

  @override
  Widget build(BuildContext context) {
    var openbookProvider = OpenbookProvider.of(context);
    _userService = openbookProvider.userService;
    _toastService = openbookProvider.toastService;
    _localizationService = openbookProvider.localizationService;
    _bottomSheetService = openbookProvider.bottomSheetService;

    return ListTile(
        title: OBText(_localizationService.trans('user__update_connection_circles_title')),
        leading: const OBIcon(OBIcons.circles),
        onTap: _displayAddConnectionToCirclesBottomSheet);
  }

  void _displayAddConnectionToCirclesBottomSheet() {
    List<Circle> connectedCircles = widget.user.connectedCircles!.circles!;

    _bottomSheetService.showConnectionsCirclesPicker(
        context: context,
        title: _localizationService.trans('user__update_connection_circles_title'),
        actionLabel: _localizationService.trans('user__update_connection_circle_save'),
        initialPickedCircles: connectedCircles,
        onPickedCircles: _onWantsToUpdateConnectionCircles);
  }

  Future _onWantsToUpdateConnectionCircles(List<Circle> circles) async {
    await _updateConnectionWithUser(circles);
  }

  Future _updateConnectionWithUser(List<Circle> circles) async {
    try {
      await _userService.updateConnectionWithUsername(widget.user.username!,
          circles: circles);
      if (!widget.user.isFollowing!) widget.user.incrementFollowersCount();
      _toastService.success(message: _localizationService.trans('user__update_connection_circle_updated'), context: context);
    } catch (error) {
      _onError(error);
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
}
