import 'package:Okuna/models/emoji.dart';
import 'package:Okuna/models/post_comment.dart';
import 'package:Okuna/models/user.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostCommentReaction {
  final int? id;
  final DateTime? created;
  final Emoji? emoji;
  final User? reactor;
  final PostComment? postComment;

  PostCommentReaction(
      {this.id, this.created, this.emoji, this.reactor, this.postComment});

  factory PostCommentReaction.fromJson(Map<String, dynamic> parsedJson) {
    DateTime? created;
    var createdData = parsedJson['created'];
    if (createdData != null) created = DateTime.parse(createdData).toLocal();

    User? reactor;
    var reactorData = parsedJson['reactor'];
    if (reactorData != null) reactor = User.fromJson(reactorData);

    PostComment? postComment;
    if (parsedJson.containsKey('post_comment')) {
      postComment = PostComment.fromJSON(parsedJson['post_comment']);
    }

    Emoji? emoji = Emoji.fromJson(parsedJson['emoji']);

    return PostCommentReaction(
        id: parsedJson['id'],
        created: created,
        reactor: reactor,
        emoji: emoji,
        postComment: postComment);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created': created?.toString(),
      'emoji': emoji?.toJson(),
      'reactor': reactor?.toJson(),
      'post_comment': postComment?.toJson()
    };
  }

  String? getRelativeCreated() {
    if (created == null) {
      return null;
    }

    return timeago.format(created!);
  }

  String? getReactorUsername() {
    return this.reactor?.username;
  }

  String? getReactorProfileAvatar() {
    return this.reactor?.getProfileAvatar();
  }

  int? getReactorId() {
    return this.reactor?.id;
  }

  int? getEmojiId() {
    return this.emoji?.id;
  }

  String? getEmojiImage() {
    return this.emoji?.image;
  }

  String? getEmojiKeyword() {
    return this.emoji?.keyword;
  }

  PostCommentReaction copy({Emoji? newEmoji}) {
    return PostCommentReaction(emoji: newEmoji ?? emoji);
  }
}
