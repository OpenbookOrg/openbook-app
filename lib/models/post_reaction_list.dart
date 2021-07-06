import 'package:Okuna/models/post_reaction.dart';

class PostReactionList {
  final List<PostReaction>? reactions;

  PostReactionList({
    this.reactions,
  });

  factory PostReactionList.fromJson(List<dynamic> parsedJson) {
    List<PostReaction> postReactions =
        parsedJson.map((postJson) => PostReaction.fromJson(postJson)).toList();

    return new PostReactionList(
      reactions: postReactions,
    );
  }
}
