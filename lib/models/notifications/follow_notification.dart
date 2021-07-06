import 'package:Okuna/models/user.dart';

class FollowNotification {
  final int? id;
  final User? follower;

  FollowNotification({this.id, this.follower});

  factory FollowNotification.fromJson(Map<String, dynamic> json) {
    return FollowNotification(
        id: json['id'], follower: _parseUser(json['follower']));
  }

  static User _parseUser(Map<String, dynamic> userData) {
    return User.fromJson(userData);
  }
}
