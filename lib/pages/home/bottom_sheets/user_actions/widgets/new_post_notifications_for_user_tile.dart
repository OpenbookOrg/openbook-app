import 'package:Okuna/models/user.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/httpie.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/toast.dart';
import 'package:Okuna/services/user.dart';
import 'package:Okuna/widgets/icon.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:Okuna/widgets/tiles/loading_tile.dart';
import 'package:flutter/material.dart';

class OBNewPostNotificationsForUserTile extends StatefulWidget {
  final User user;
  final VoidCallback? onSubscribed;
  final VoidCallback? onUnsubscribed;

  const OBNewPostNotificationsForUserTile({
    Key? key,
    required this.user,
    this.onSubscribed,
    this.onUnsubscribed,
  }) : super(key: key);

  @override
  OBNewPostNotificationsForUserTileState createState() {
    return OBNewPostNotificationsForUserTileState();
  }
}

class OBNewPostNotificationsForUserTileState extends State<OBNewPostNotificationsForUserTile> {
  late UserService _userService;
  late ToastService _toastService;
  late LocalizationService _localizationService;
  late bool _requestInProgress;

  @override
  void initState() {
    super.initState();
    _requestInProgress = false;
  }

  @override
  Widget build(BuildContext context) {
    var openbookProvider = OpenbookProvider.of(context);
    _userService = openbookProvider.userService;
    _toastService = openbookProvider.toastService;
    _localizationService = openbookProvider.localizationService;

    return StreamBuilder(
      stream: widget.user.updateSubject,
      initialData: widget.user,
      builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
        var user = snapshot.data!;

        bool areNotificationsEnabled = user.areNewPostNotificationsEnabled ?? false;

        return OBLoadingTile(
          isLoading: _requestInProgress,
          leading: OBIcon(areNotificationsEnabled ? OBIcons.notifications_off : OBIcons.notifications),
          title: OBText(areNotificationsEnabled
              ? _localizationService.user__disable_new_post_notifications
              : _localizationService.user__enable_new_post_notifications),
          onTap: areNotificationsEnabled ? _unsubscribeUser : _susbcribeUser,
        );
      },
    );
  }

  void _susbcribeUser() async {
    _setRequestInProgress(true);
    try {
      await _userService.enableNewPostNotificationsForUser(widget.user);
      if (widget.onSubscribed != null) widget.onSubscribed!();
    } catch (e) {
      _onError(e);
    } finally {
      _setRequestInProgress(false);
    }
  }

  void _unsubscribeUser() async {
    _setRequestInProgress(true);
    try {
      await _userService.disableNewPostNotificationsForUser(widget.user);
      if (widget.onUnsubscribed != null) widget.onUnsubscribed!();
    } catch (e) {
      _onError(e);
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
}
