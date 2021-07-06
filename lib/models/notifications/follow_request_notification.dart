import 'package:Okuna/models/user.dart';

import '../follow_request.dart';

class FollowRequestNotification {
  final int? id;
  final FollowRequest? followRequest;

  FollowRequestNotification({this.id, this.followRequest});

  factory FollowRequestNotification.fromJson(Map<String, dynamic> json) {
    return FollowRequestNotification(
        id: json['id'],
        followRequest: FollowRequest.fromJson(json['follow_request']));
  }
}
