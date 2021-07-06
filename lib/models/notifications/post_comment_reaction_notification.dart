import 'package:Okuna/models/post_comment_reaction.dart';

class PostCommentReactionNotification {
  final int? id;
  final PostCommentReaction? postCommentReaction;

  PostCommentReactionNotification({this.id, this.postCommentReaction});

  factory PostCommentReactionNotification.fromJson(Map<String, dynamic> json) {
    return PostCommentReactionNotification(
        id: json['id'],
        postCommentReaction:
            _parsePostCommentReaction(json['post_comment_reaction']));
  }

  static PostCommentReaction _parsePostCommentReaction(
      Map<String, dynamic> postCommentReactionData) {
    return PostCommentReaction.fromJson(postCommentReactionData);
  }
}
