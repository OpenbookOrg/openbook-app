import 'package:Okuna/models/follow_request.dart';
import 'package:Okuna/models/user.dart';
import 'package:Okuna/widgets/buttons/actions/approve_follow_request_button.dart';
import 'package:Okuna/widgets/buttons/actions/reject_follow_request_button.dart';
import 'package:Okuna/widgets/buttons/button.dart';
import 'package:Okuna/widgets/tiles/user_tile.dart';
import 'package:flutter/material.dart';

import '../../provider.dart';

class OBReceivedFollowRequestTile extends StatelessWidget {
  final FollowRequest followRequest;
  final ValueChanged<FollowRequest>? onFollowRequestApproved;
  final ValueChanged<FollowRequest>? onFollowRequestRejected;

  const OBReceivedFollowRequestTile(this.followRequest,
      {Key? key, this.onFollowRequestApproved, this.onFollowRequestRejected})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var openbookProvider = OpenbookProvider.of(context);
    var navigationService = openbookProvider.navigationService;

    return OBUserTile(
      followRequest.creator!,
      onUserTilePressed: (User user) {
        navigationService.navigateToUserProfile(user: user, context: context);
      },
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          OBRejectFollowRequestButton(
            followRequest.creator!,
            onFollowRequestRejected: () {
              if(onFollowRequestRejected != null)  onFollowRequestRejected!(followRequest);
            },
            size: OBButtonSize.small,
          ),
          const SizedBox(
            width: 10,
          ),
          OBApproveFollowRequestButton(
            followRequest.creator!,
            onFollowRequestApproved: () {
              if(onFollowRequestApproved != null) onFollowRequestApproved!(followRequest);
            },
            size: OBButtonSize.small,
          ),
        ],
      ),
    );
  }
}
