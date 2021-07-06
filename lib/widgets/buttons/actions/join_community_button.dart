import 'package:Okuna/models/community.dart';
import 'package:Okuna/models/user.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/httpie.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/toast.dart';
import 'package:Okuna/services/user.dart';
import 'package:Okuna/widgets/buttons/button.dart';
import 'package:Okuna/widgets/buttons/community_button.dart';
import 'package:flutter/material.dart';

class OBJoinCommunityButton extends StatefulWidget {
  final Community community;
  final bool communityThemed;

  OBJoinCommunityButton(this.community, {this.communityThemed = true});

  @override
  OBJoinCommunityButtonState createState() {
    return OBJoinCommunityButtonState();
  }
}

class OBJoinCommunityButtonState extends State<OBJoinCommunityButton> {
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
      stream: widget.community.updateSubject,
      initialData: widget.community,
      builder: (BuildContext context, AsyncSnapshot<Community> snapshot) {
        var community = snapshot.data!;

        bool isCreator = community.isCreator ?? true;

        if (isCreator) return SizedBox();

        bool isInvited = community.isInvited ?? false;

        User loggedInUser = _userService.getLoggedInUser()!;

        bool isMember = community.isMember(loggedInUser);

        if (community.type == CommunityType.private && !isMember && !isInvited)
          return SizedBox();

        return widget.communityThemed
            ? OBCommunityButton(
                community: community,
                text: isMember
                    ? _localizationService.community__leave_community
                    : _localizationService.community__join_community,
                isLoading: _requestInProgress,
                onPressed: isMember ? _leaveCommunity : _joinCommunity,
              )
            : OBButton(
                child: Text(isMember
                    ? _localizationService.community__leave_community
                    : _localizationService.community__join_community),
                isLoading: _requestInProgress,
                onPressed: isMember ? _leaveCommunity : _joinCommunity,
              );
      },
    );
  }

  void _joinCommunity() async {
    _setRequestInProgress(true);
    try {
      await _userService.joinCommunity(widget.community);
      widget.community.incrementMembersCount();
    } catch (error) {
      _onError(error);
    } finally {
      _setRequestInProgress(false);
    }
  }

  void _leaveCommunity() async {
    _setRequestInProgress(true);
    try {
      await _userService.leaveCommunity(widget.community);
      widget.community.decrementMembersCount();
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
      _toastService.error(message: errorMessage ?? _localizationService.error__unknown_error, context: context);
    } else {
      _toastService.error(
          message: _localizationService.error__unknown_error, context: context);
      throw error;
    }
  }

  void _setRequestInProgress(bool requestInProgress) {
    setState(() {
      _requestInProgress = requestInProgress;
    });
  }
}
