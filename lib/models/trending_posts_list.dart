import 'package:Okuna/models/top_post.dart';
import 'package:Okuna/models/trending_post.dart';

class TrendingPostsList {
  final List<TrendingPost>? posts;

  TrendingPostsList({
    this.posts,
  });

  factory TrendingPostsList.fromJson(List<dynamic> parsedJson) {
    List<TrendingPost> posts =
        parsedJson.map((postJson) => TrendingPost.fromJson(postJson)).toList();

    return new TrendingPostsList(
      posts: posts,
    );
  }
}
