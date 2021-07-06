import 'package:Okuna/models/post_user_mention.dart';

class PostUserMentionNotification {
  final int? id;
  final PostUserMention? postUserMention;

  PostUserMentionNotification({this.id, this.postUserMention});

  factory PostUserMentionNotification.fromJson(Map<String, dynamic> json) {
    return PostUserMentionNotification(
        id: json['id'],
        postUserMention: _parsePostUserMention(json['post_user_mention']));
  }

  static PostUserMention _parsePostUserMention(
      Map<String, dynamic> postUserMentionData) {
    return PostUserMention.fromJSON(postUserMentionData);
  }
}
