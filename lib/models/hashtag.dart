import 'package:Okuna/models/updatable_model.dart';
import 'package:Okuna/models/users_list.dart';
import 'package:dcache/dcache.dart';

class Hashtag extends UpdatableModel<Hashtag> {
  final int id;
  String name;
  String color;
  int postsCount;
  UsersList users;

  Hashtag({
    this.id,
    this.name,
    this.color,
    this.postsCount,
    this.users,
  });

  static final factory = HashtagFactory();

  factory Hashtag.fromJSON(Map<String, dynamic> json) {
    if (json == null) return null;
    return factory.fromJson(json);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'posts_count': postsCount,
    };
  }

  @override
  void updateFromJson(Map json) {
    if (json.containsKey('name')) {
      name = json['name'];
    }
    if (json.containsKey('posts_count')) {
      postsCount = json['posts_count'];
    }
    if (json.containsKey('color')) {
      color = json['color'];
    }
  }

  bool hasUsers() {
    return users != null && users.users.length > 0;
  }
}

class HashtagFactory extends UpdatableModelFactory<Hashtag> {
  @override
  SimpleCache<int, Hashtag> cache =
      SimpleCache(storage: UpdatableModelSimpleStorage(size: 20));

  @override
  Hashtag makeFromJson(Map json) {
    return Hashtag(
      id: json['id'],
      name: json['name'],
      color: json['color'],
      postsCount: json['posts_count'],
    );
  }
}
