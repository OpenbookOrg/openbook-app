import 'package:Okuna/models/reactions_emoji_count.dart';

class ReactionsEmojiCountList {
  final List<ReactionsEmojiCount?>? counts;

  ReactionsEmojiCountList({
    this.counts,
  });

  factory ReactionsEmojiCountList.fromJson(List<dynamic> parsedJson) {
    List<ReactionsEmojiCount> postReactionsEmojiCounts = parsedJson
        .map((postJson) => ReactionsEmojiCount.fromJson(postJson))
        .toList();

    return new ReactionsEmojiCountList(
      counts: postReactionsEmojiCounts,
    );
  }
}
