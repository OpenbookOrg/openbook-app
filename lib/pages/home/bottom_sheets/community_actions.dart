import 'package:Okuna/models/community.dart';
import 'package:Okuna/models/user.dart';
import 'package:Okuna/pages/home/bottom_sheets/rounded_bottom_sheet.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/modal_service.dart';
import 'package:Okuna/services/toast.dart';
import 'package:Okuna/services/user.dart';
import 'package:Okuna/widgets/icon.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:Okuna/widgets/tiles/actions/favorite_community_tile.dart';
import 'package:Okuna/widgets/tiles/actions/report_community_tile.dart';
import 'package:Okuna/widgets/tiles/actions/new_post_notifications_for_community_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OBCommunityActionsBottomSheet extends StatefulWidget {
  final Community community;
  final OnCommunityReported? onCommunityReported;

  const OBCommunityActionsBottomSheet(
      {Key? key, required this.community, this.onCommunityReported})
      : super(key: key);

  @override
  OBCommunityActionsBottomSheetState createState() {
    return OBCommunityActionsBottomSheetState();
  }
}

class OBCommunityActionsBottomSheetState
    extends State<OBCommunityActionsBottomSheet> {
  late UserService _userService;
  late ToastService _toastService;
  late ModalService _modalService;
  late LocalizationService _localizationService;

  @override
  Widget build(BuildContext context) {
    var openbookProvider = OpenbookProvider.of(context);
    _userService = openbookProvider.userService;
    _toastService = openbookProvider.toastService;
    _modalService = openbookProvider.modalService;
    _localizationService = openbookProvider.localizationService;

    List<Widget> communityActions = [
      OBFavoriteCommunityTile(
        community: widget.community,
        onFavoritedCommunity: _dismiss,
        onUnfavoritedCommunity: _dismiss,
      )
    ];

    User loggedInUser = _userService.getLoggedInUser()!;
    Community community = widget.community;

    bool isMemberOfCommunity = community.isMember(loggedInUser);
    bool isCommunityAdministrator = community.isAdministrator(loggedInUser);
    bool isCommunityModerator = community.isModerator(loggedInUser);
    bool communityHasInvitesEnabled = community.invitesEnabled ?? false;

    if (isMemberOfCommunity) {
      communityActions.add(OBNewPostNotificationsForCommunityTile(
        community: community,
        onSubscribed: _dismiss,
        onUnsubscribed: _dismiss,
      ));
    }

    if (communityHasInvitesEnabled && isMemberOfCommunity) {
      communityActions.add(ListTile(
        leading: const OBIcon(OBIcons.communityInvites),
        title: OBText(
          _localizationService.community__actions_invite_people_title,
        ),
        onTap: _onWantsToInvitePeople,
      ));
    }

    if (!isCommunityAdministrator && !isCommunityModerator) {
      communityActions.add(OBReportCommunityTile(
        community: community,
        onWantsToReportCommunity: () {
          Navigator.of(context).pop();
        },
      ));
    }

    return OBRoundedBottomSheet(
      child: Column(
        children: communityActions,
        mainAxisSize: MainAxisSize.min,
      ),
    );
  }

  Future _onWantsToInvitePeople() async {
    _dismiss();
    _modalService.openInviteToCommunity(
        context: context, community: widget.community);
  }

  void _dismiss() {
    Navigator.pop(context);
  }
}

typedef OnCommunityReported(Community community);
