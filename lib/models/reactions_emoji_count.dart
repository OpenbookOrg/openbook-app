import 'package:Okuna/models/emoji.dart';

class ReactionsEmojiCount {
  final Emoji? emoji;
  int? count;

  ReactionsEmojiCount({this.emoji, this.count});

  factory ReactionsEmojiCount.fromJson(Map<String, dynamic> parsedJson) {
    Emoji emoji = Emoji.fromJson(parsedJson['emoji']);

    return ReactionsEmojiCount(emoji: emoji, count: parsedJson['count']);
  }

  Map<String, dynamic> toJson() {
    return {
      'emoji': emoji?.toJson(),
      'count': count
    };
  }

  ReactionsEmojiCount copy({newEmoji, newCount, newReacted}) {
    return ReactionsEmojiCount(
        emoji: newEmoji ?? this.emoji, count: newCount ?? this.count);
  }

  String getPrettyCount() {
    return count.toString();
  }

  int? getEmojiId() {
    return emoji?.id;
  }
}
