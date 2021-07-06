import 'package:Okuna/models/post.dart';
import 'package:Okuna/models/updatable_model.dart';
import 'package:dcache/dcache.dart';

class TrendingPost extends UpdatableModel<TrendingPost> {
  final int? id;
  Post? post;
  DateTime? created;

  static final factory = TrendingPostFactory();

  factory TrendingPost.fromJson(Map<String, dynamic> json) {
    return factory.fromJson(json);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post': post?.toJson(),
      'created': created?.toString()
    };
  }

  static void clearCache() {
    factory.clearCache();
  }

  TrendingPost(
      {this.id,
      this.post,
      this.created})
      : super();

  void updateFromJson(Map json) {
    if (json.containsKey('post')) {
      post = factory.parsePost(json['post']);
    }

    if (json.containsKey('created'))
      created = factory.parseCreated(json['created']);
  }
}

class TrendingPostFactory extends UpdatableModelFactory<TrendingPost> {
  @override
  SimpleCache<int, TrendingPost>? cache =
      SimpleCache(storage: UpdatableModelSimpleStorage(size: 50));

  @override
  TrendingPost makeFromJson(Map json) {
    return TrendingPost(
        id: json['id'],
        post: parsePost(json['post']),
        created: parseCreated(json['created']),);
  }

  Post? parsePost(Map<String, dynamic>? postData) {
    if (postData == null) return null;
    return Post.fromJson(postData);
  }

  DateTime? parseCreated(String? created) {
    if (created == null) return null;
    return DateTime.parse(created).toLocal();
  }

}
