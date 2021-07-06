import 'package:Okuna/models/post.dart';
import 'package:Okuna/models/user.dart';

class PostUserMention {
  final int? id;
  final User? user;
  final Post? post;

  PostUserMention({
    this.id,
    this.user,
    this.post,
  });

  factory PostUserMention.fromJSON(Map<String, dynamic> parsedJson) {
    return PostUserMention(
      id: parsedJson['id'],
      user: parseUser(parsedJson['user']),
      post: parsePost(parsedJson['post']),
    );
  }

  static User? parseUser(Map<String, dynamic>? userData) {
    if (userData == null) return null;
    return User.fromJson(userData);
  }

  static Post? parsePost(Map<String, dynamic>? postData) {
    if (postData == null) return null;
    return Post.fromJson(postData);
  }
}
