import 'package:Okuna/models/user.dart';

class FollowRequest {
  final int? id;
  final User? creator;
  final User? targetUser;

  FollowRequest({this.id, this.creator, this.targetUser});

  factory FollowRequest.fromJson(Map<String, dynamic> json) {
    return FollowRequest(
      id: json['id'],
      creator: _parseFollowRequestedUser(json['creator']),
      targetUser: _parseFollowRequestedUser(json['target_user']),
    );
  }

  static User? _parseFollowRequestedUser(Map<String, dynamic>? followRequestedUserData) {
    if (followRequestedUserData == null) return null;
    return User.fromJson(followRequestedUserData);
  }
}
