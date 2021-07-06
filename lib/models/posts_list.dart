import 'package:Okuna/models/post.dart';

class PostsList {
  final List<Post>? posts;

  PostsList({
    this.posts,
  });

  factory PostsList.fromJson(List<dynamic> parsedJson) {
    List<Post> posts =
        parsedJson.map((postJson) => Post.fromJson(postJson)).toList();

    return new PostsList(
      posts: posts,
    );
  }
}
