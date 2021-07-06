import 'package:Okuna/models/post_comment.dart';

class PostCommentList {
  final List<PostComment>? comments;

  PostCommentList({
    this.comments,
  });

  factory PostCommentList.fromJson(List<dynamic> parsedJson) {

    List<PostComment> postComments =
        parsedJson.map((postJson) => PostComment.fromJSON(postJson)).toList();

    return new PostCommentList(
      comments: postComments,
    );
  }
}
