import 'package:Okuna/models/post.dart';
import 'package:Okuna/models/updatable_model.dart';
import 'package:dcache/dcache.dart';

class TopPost extends UpdatableModel<TopPost> {
  final int? id;
  Post? post;
  DateTime? created;

  static final factory = TopPostFactory();

  factory TopPost.fromJson(Map<String, dynamic> json) {
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

  TopPost(
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

class TopPostFactory extends UpdatableModelFactory<TopPost> {
  @override
  SimpleCache<int, TopPost>? cache =
      SimpleCache(storage: UpdatableModelSimpleStorage(size: 50));

  @override
  TopPost makeFromJson(Map json) {
    return TopPost(
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
