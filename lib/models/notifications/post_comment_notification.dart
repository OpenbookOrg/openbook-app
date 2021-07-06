import 'package:Okuna/models/post_comment.dart';

class PostCommentNotification {
  final int? id;
  final PostComment? postComment;

  PostCommentNotification({this.id, this.postComment});

  factory PostCommentNotification.fromJson(Map<String, dynamic> json) {
    return PostCommentNotification(
        id: json['id'], postComment: _parsePostComment(json['post_comment']));
  }

  static PostComment _parsePostComment(Map<String, dynamic> postCommentData) {
    return PostComment.fromJSON(postCommentData);
  }

  int? getPostCreatorId() {
    return postComment?.getPostCreatorId();
  }
}
