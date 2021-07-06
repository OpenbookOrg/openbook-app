import 'package:Okuna/models/post_reaction.dart';

class PostReactionNotification {
  final int? id;
  final PostReaction? postReaction;

  PostReactionNotification({this.id, this.postReaction});

  factory PostReactionNotification.fromJson(Map<String, dynamic> json) {
    return PostReactionNotification(
        id: json['id'],
        postReaction: _parsePostReaction(json['post_reaction']));
  }

  static PostReaction _parsePostReaction(
      Map<String, dynamic> postReactionData) {
    return PostReaction.fromJson(postReactionData);
  }
}
