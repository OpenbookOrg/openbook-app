import 'package:Okuna/models/emoji.dart';
import 'package:Okuna/models/emoji_list.dart';

class EmojiGroup {
  final String? keyword;
  final int? id;
  final int? order;
  final DateTime? created;
  final String? color;
  final EmojisList? emojis;

  EmojiGroup(
      {this.keyword,
      this.id,
      this.order,
      this.created,
      this.color,
      this.emojis});

  factory EmojiGroup.fromJson(Map<String, dynamic> parsedJson) {
    var emojisData = parsedJson['emojis'];
    EmojisList emojis = EmojisList.fromJson(emojisData);

    return EmojiGroup(
        id: parsedJson['id'],
        keyword: parsedJson['keyword'],
        created: _parseCreated(parsedJson['created']),
        order: parsedJson['order'],
        color: parsedJson['color'],
        emojis: emojis);
  }

  List<Emoji>? getEmojis() {
    return emojis?.emojis;
  }

  static DateTime? _parseCreated(String? created) {
    if (created == null) return null;
    return DateTime.parse(created).toLocal();
  }
}
