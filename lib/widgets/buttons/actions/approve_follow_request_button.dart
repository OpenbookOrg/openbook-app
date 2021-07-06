import 'package:Okuna/models/follow_request.dart';
import 'package:Okuna/models/user.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/httpie.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/toast.dart';
import 'package:Okuna/services/user.dart';
import 'package:Okuna/widgets/buttons/button.dart';
import 'package:flutter/material.dart';
import 'package:async/async.dart';
import 'package:intl/intl.dart';

class OBApproveFollowRequestButton extends StatefulWidget {
  final User user;
  final VoidCallback? onFollowRequestApproved;
  final OBButtonSize size;

  const OBApproveFollowRequestButton(this.user,
      {Key? key, this.onFollowRequestApproved, this.size = OBButtonSize.medium})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return OBApproveFollowRequestButtonState();
  }
}

class OBApproveFollowRequestButtonState extends State<OBApproveFollowRequestButton> {
  late ToastService _toastService;
  late LocalizationService _localizationService;
  late UserService _userService;
  late bool _needsBootstrap;

  late bool _isFollowRequestActionInProgress;
  CancelableOperation? _followRequestActionOperation;

  @override
  void initState() {
    super.initState();
    _needsBootstrap = true;
    _isFollowRequestActionInProgress = false;
  }

  @override
  Widget build(BuildContext context) {
    var openbookProvider = OpenbookProvider.of(context);

    if (_needsBootstrap) {
      _localizationService = openbookProvider.localizationService;
      _userService = openbookProvider.userService;
      _toastService = openbookProvider.toastService;
    }

    return OBButton(
      size: OBButtonSize.small,
      isLoading: _isFollowRequestActionInProgress,
      child: Text(toBeginningOfSentenceCase(
          _localizationService.moderation__community_review_approve)!),
      type: OBButtonType.success,
      onPressed: _onWantsToApproveRequest,
    );
  }

  Future<void> _onWantsToApproveRequest() async {
    _setFollowRequestActionInProgress(true);

    try {
      _followRequestActionOperation = CancelableOperation.fromFuture(
          _userService
              .approveFollowRequestFromUser(widget.user));
      await _followRequestActionOperation!.value;
      if(widget.onFollowRequestApproved != null) widget.onFollowRequestApproved!();
    } catch (error) {
      _onError(error);
      rethrow;
    } finally {
      _setFollowRequestActionInProgress(false);
      _followRequestActionOperation = null;
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
      _toastService.error(
          message: _localizationService.error__unknown_error, context: context);
      throw error;
    }
  }

  void _setFollowRequestActionInProgress(bool followRequestActionInProgress) {
    setState(() {
      _isFollowRequestActionInProgress = followRequestActionInProgress;
    });
  }
}
