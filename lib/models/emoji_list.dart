import 'package:Okuna/models/emoji.dart';

class EmojisList {
  final List<Emoji>? emojis;

  EmojisList({
    this.emojis,
  });

  factory EmojisList.fromJson(List<dynamic> parsedJson) {
    List<Emoji> emojis =
        parsedJson.map((emojiJson) => Emoji.fromJson(emojiJson)).toList();

    return new EmojisList(
      emojis: emojis,
    );
  }
}
