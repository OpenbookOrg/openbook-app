import 'package:Okuna/models/community.dart';
import 'package:Okuna/models/user.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/httpie.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/toast.dart';
import 'package:Okuna/services/user.dart';
import 'package:Okuna/widgets/buttons/button.dart';
import 'package:flutter/material.dart';

class OBInviteUserToCommunityButton extends StatefulWidget {
  final User user;
  final Community community;

  OBInviteUserToCommunityButton(
      {required this.user, required this.community});

  @override
  OBInviteUserToCommunityButtonState createState() {
    return OBInviteUserToCommunityButtonState();
  }
}

class OBInviteUserToCommunityButtonState
    extends State<OBInviteUserToCommunityButton> {
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

    User loggedInUser = _userService.getLoggedInUser()!;

    return StreamBuilder(
      stream: loggedInUser.updateSubject,
      initialData: loggedInUser,
      builder:
          (BuildContext context, AsyncSnapshot<User> loggedInUserSnapshot) {
        return StreamBuilder(
          stream: widget.user.updateSubject,
          initialData: widget.user,
          builder:
              (BuildContext context, AsyncSnapshot<User> latestUserSnapshot) {
            User? latestUser = latestUserSnapshot.data;
            if (latestUser == null) return const SizedBox();

            bool isCommunityMember =
                latestUser.isMemberOfCommunity(widget.community);
            bool isInvitedToCommunity =
                latestUser.isInvitedToCommunity(widget.community);

            if (isCommunityMember) {
              return _buildAlreadyMemberButton();
            }

            return isInvitedToCommunity
                ? _buildUninviteUserToCommunityButton()
                : _buildInviteUserToCommunityButton();
          },
        );
      },
    );
  }

  Widget _buildInviteUserToCommunityButton() {
    return OBButton(
      size: OBButtonSize.small,
      type: OBButtonType.primary,
      isLoading: _requestInProgress,
      onPressed: _inviteUser,
      child: Text(_localizationService.trans('user__invite')),
    );
  }

  Widget _buildUninviteUserToCommunityButton() {
    return OBButton(
      size: OBButtonSize.small,
      type: OBButtonType.highlight,
      isLoading: _requestInProgress,
      onPressed: _uninviteUser,
      child: Text(_localizationService.trans('user__uninvite')),
    );
  }

  Widget _buildAlreadyMemberButton() {
    return OBButton(
      size: OBButtonSize.small,
      type: OBButtonType.highlight,
      isDisabled: true,
      isLoading: _requestInProgress,
      onPressed: () {},
      child: Text(_localizationService.trans('user__invite_member')),
    );
  }

  void _inviteUser() async {
    _setRequestInProgress(true);
    try {
      await _userService.inviteUserToCommunity(
          user: widget.user, community: widget.community);
    } catch (e) {
      _onError(e);
    } finally {
      _setRequestInProgress(false);
    }
  }

  void _uninviteUser() async {
    _setRequestInProgress(true);
    try {
      await _userService.uninviteUserFromCommunity(
          user: widget.user, community: widget.community);
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
      _toastService.error(message: errorMessage ?? _localizationService.trans('error__unknown_error'), context: context);
    } else {
      _toastService.error(message: _localizationService.trans('error__unknown_error'), context: context);
      throw error;
    }
  }

  void _setRequestInProgress(bool requestInProgress) {
    setState(() {
      _requestInProgress = requestInProgress;
    });
  }
}
