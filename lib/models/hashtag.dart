import 'package:Okuna/models/emoji.dart';
import 'package:Okuna/models/updatable_model.dart';
import 'package:dcache/dcache.dart';

class Hashtag extends UpdatableModel<Hashtag> {
  final int? id;
  String? name;
  String? image;
  Emoji? emoji;
  String? color;
  String? textColor;
  int? postsCount;
  bool? isReported;

  Hashtag({
    this.id,
    this.name,
    this.image,
    this.emoji,
    this.color,
    this.textColor,
    this.postsCount,
    this.isReported,
  });

  static final factory = HashtagFactory();

  factory Hashtag.fromJSON(Map<String, dynamic> json) {
    return factory.fromJson(json);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'emoji': emoji,
      'image': image,
      'color': color,
      'text_color': textColor,
      'posts_count': postsCount,
      'is_reported': isReported,
    };
  }

  @override
  void updateFromJson(Map json) {
    if (json.containsKey('name')) {
      name = json['name'];
    }

    if (json.containsKey('is_reported')) {
      isReported = json['is_reported'];
    }

    if (json.containsKey('posts_count')) {
      postsCount = json['posts_count'];
    }
    if (json.containsKey('color')) {
      color = json['color'];
    }

    if (json.containsKey('text_color')) {
      textColor = json['text_color'];
    }

    if (json.containsKey('image')) {
      image = json['image'];
    }

    if (json.containsKey('emoji')) {
      emoji = factory.parseEmoji(json['emoji']);
    }
  }

  bool hasEmoji() {
    return this.emoji != null;
  }

  bool hasImage() {
    return this.image != null;
  }

  void setIsReported(isReported) {
    this.isReported = isReported;
    notifyUpdate();
  }
}

class HashtagFactory extends UpdatableModelFactory<Hashtag> {
  @override
  SimpleCache<int, Hashtag>? cache =
      SimpleCache(storage: UpdatableModelSimpleStorage(size: 20));

  @override
  Hashtag makeFromJson(Map json) {
    return Hashtag(
      id: json['id'],
      name: json['name'],
      color: json['color'],
      isReported: json['is_reported'],
      textColor: json['text_color'],
      emoji: parseEmoji(json['emoji']),
      postsCount: json['posts_count'],
    );
  }

  Emoji? parseEmoji(emojiRawData) {
    if (emojiRawData == null) return null;
    return Emoji.fromJson(emojiRawData);
  }
}
