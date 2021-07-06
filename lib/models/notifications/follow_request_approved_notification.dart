import 'package:Okuna/models/follow.dart';

class FollowRequestApprovedNotification {
  final int? id;
  final Follow? follow;

  FollowRequestApprovedNotification({this.id, this.follow});

  factory FollowRequestApprovedNotification.fromJson(Map<String, dynamic> json) {
    return FollowRequestApprovedNotification(
        id: json['id'],
        follow: Follow.fromJson(json['follow']));
  }
}
