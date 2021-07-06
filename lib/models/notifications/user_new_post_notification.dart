import '../post.dart';

class UserNewPostNotification {
  final int? id;
  final Post? post;

  const UserNewPostNotification({
    this.post,
    this.id,
  });

  factory UserNewPostNotification.fromJson(Map<String, dynamic> json) {
    return UserNewPostNotification(
        id: json['id'],
        post: _parsePost(json['post']));
  }

  static Post _parsePost(Map<String, dynamic> postData) {
    return Post.fromJson(postData);
  }
}
