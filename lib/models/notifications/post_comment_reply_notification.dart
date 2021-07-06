import 'package:Okuna/models/post_comment.dart';

class PostCommentReplyNotification {
  final int? id;
  final PostComment? postComment;

  PostCommentReplyNotification({this.id, this.postComment});

  factory PostCommentReplyNotification.fromJson(Map<String, dynamic> json) {
    return PostCommentReplyNotification(
        id: json['id'],
        postComment: _parsePostComment(json['post_comment']),
    );
  }

  static PostComment _parsePostComment(Map<String, dynamic> postCommentData) {
    return PostComment.fromJSON(postCommentData);
  }

  int? getPostCreatorId() {
    return postComment?.getPostCreatorId();
  }
}
