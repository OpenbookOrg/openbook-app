import '../post.dart';

class CommunityNewPostNotification {
  final int? id;
  final Post? post;

  const CommunityNewPostNotification({
    this.post,
    this.id,
  });

  factory CommunityNewPostNotification.fromJson(Map<String, dynamic> json) {
    return CommunityNewPostNotification(
        id: json['id'],
        post: _parsePost(json['post']));
  }

  static Post _parsePost(Map<String, dynamic> postData) {
    return Post.fromJson(postData);
  }
}
