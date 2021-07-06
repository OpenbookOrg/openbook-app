import 'package:Okuna/models/hashtag.dart';
import 'package:Okuna/models/hashtags_list.dart';
import 'package:Okuna/models/post.dart';
import 'package:Okuna/models/post_comment_list.dart';
import 'package:Okuna/models/post_comment_reaction.dart';
import 'package:Okuna/models/reactions_emoji_count.dart';
import 'package:Okuna/models/reactions_emoji_count_list.dart';
import 'package:Okuna/models/user.dart';
import 'package:dcache/dcache.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:Okuna/models/updatable_model.dart';

import 'emoji.dart';
import 'language.dart';

import 'package:collection/collection.dart';

class PostComment extends UpdatableModel<PostComment> {
  final int? id;
  int? creatorId;
  int? repliesCount;
  DateTime? created;
  String? text;
  Language? language;
  User? commenter;
  PostComment? parentComment;
  PostCommentList? replies;
  ReactionsEmojiCountList? reactionsEmojiCounts;
  PostCommentReaction? reaction;
  HashtagsList? hashtagsList;
  Map<String, Hashtag>? hashtagsMap;

  Post? post;
  bool? isEdited;
  bool? isReported;
  bool? isMuted;

  static convertPostCommentSortTypeToString(PostCommentsSortType type) {
    String result;
    switch (type) {
      case PostCommentsSortType.asc:
        result = 'ASC';
        break;
      case PostCommentsSortType.dec:
        result = 'DESC';
        break;
      default:
        throw 'Unsupported post comment sort type';
    }
    return result;
  }

  static PostCommentsSortType parsePostCommentSortType(String sortType) {
    late PostCommentsSortType type;
    if (sortType == 'ASC') {
      type = PostCommentsSortType.asc;
    }

    if (sortType == 'DESC') {
      type = PostCommentsSortType.dec;
    }

    return type;
  }

  static void clearCache() {
    factory.clearCache();
  }

  PostComment(
      {this.id,
      this.created,
      this.text,
      this.language,
      this.creatorId,
      this.commenter,
      this.post,
      this.isEdited,
      this.isReported,
      this.isMuted,
      this.parentComment,
      this.hashtagsList,
      this.replies,
      this.repliesCount,
      this.reactionsEmojiCounts,
      this.reaction}) {
    _updateHashtagsMap();
  }

  static final factory = PostCommentFactory();

  factory PostComment.fromJSON(Map<String, dynamic> json) {
    return factory.fromJson(json);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created': created?.toString(),
      'text': text,
      'language': language?.toJson(),
      'creator_id': creatorId,
      'commenter': commenter?.toJson(),
      'post': post?.toJson(),
      'is_edited': isEdited,
      'is_reported': isReported,
      'is_muted': isMuted,
      'parent_comment': parentComment?.toJson(),
      'replies':
          replies?.comments?.map((PostComment reply) => reply.toJson()).toList(),
      'hashtags': hashtagsList?.hashtags
          ?.map((Hashtag hashtag) => hashtag.toJson())
          .toList(),
      'replies_count': repliesCount,
      'reactions_emoji_counts': reactionsEmojiCounts?.counts
          ?.map((ReactionsEmojiCount? reaction) => reaction?.toJson())
          .toList(),
      'reaction': reaction?.toJson()
    };
  }

  @override
  void updateFromJson(Map json) {
    if (json.containsKey('commenter')) {
      commenter = factory.parseUser(json['commenter']);
    }

    if (json.containsKey('creater_id')) {
      creatorId = json['creator_id'];
    }

    if (json.containsKey('replies_count')) {
      repliesCount = json['replies_count'];
    }

    if (json.containsKey('is_edited')) {
      isEdited = json['is_edited'];
    }

    if (json.containsKey('is_muted')) {
      isMuted = json['is_muted'];
    }

    if (json.containsKey('is_reported')) {
      isReported = json['is_reported'];
    }

    if (json.containsKey('text')) {
      text = json['text'];
    }

    if (json.containsKey('language')) {
      language = factory.parseLanguage(json['language']);
    }

    if (json.containsKey('post')) {
      post = factory.parsePost(json['post']);
    }

    if (json.containsKey('created')) {
      created = factory.parseCreated(json['created']);
    }

    if (json.containsKey('parent_comment')) {
      parentComment = factory.parseParentComment(json['parent_comment']);
    }

    if (json.containsKey('replies')) {
      replies = factory.parseCommentReplies(json['replies']);
    }

    if (json.containsKey('reactions_emoji_counts'))
      reactionsEmojiCounts =
          factory.parseReactionsEmojiCounts(json['reactions_emoji_counts']);
    if (json.containsKey('reaction'))
      reaction = factory.parseReaction(json['reaction']);

    if (json.containsKey('hashtags')) {
      hashtagsList = factory.parseHashtagsList(json['hashtags']);
      _updateHashtagsMap();
    }
  }

  String? getRelativeCreated() {
    if (created == null) {
      return null;
    }

    return timeago.format(created!);
  }

  String? getCommenterUsername() {
    return this.commenter?.username;
  }

  String? getCommenterName() {
    return this.commenter?.getProfileName();
  }

  String? getCommenterProfileAvatar() {
    return this.commenter?.getProfileAvatar();
  }

  bool hasReplies() {
    return repliesCount != null && repliesCount! > 0 && replies != null;
  }

  bool hasLanguage() {
    return language != null;
  }

  List<PostComment> getPostCommentReplies() {
    if (replies == null) return [];
    return replies!.comments ?? [];
  }

  int? getCommenterId() {
    return this.commenter?.id;
  }

  int? getPostCreatorId() {
    return post?.getCreatorId();
  }

  Language? getLanguage() {
    return this.language;
  }

  void setIsReported(isReported) {
    this.isReported = isReported;
    notifyUpdate();
  }

  void setIsMuted(isMuted) {
    this.isMuted = isMuted;
    notifyUpdate();
  }

  void clearReaction() {
    this.setReaction(null);
  }

  bool isReactionEmoji(Emoji emoji) {
    return hasReaction() && reaction!.getEmojiId() == emoji.id;
  }

  void setReaction(PostCommentReaction? newReaction) {
    bool hasReaction = this.hasReaction();

    if (!hasReaction && newReaction == null) {
      throw 'Trying to remove no reaction';
    }

    List<ReactionsEmojiCount?> newEmojiCounts = reactionsEmojiCounts?.counts != null
        ? reactionsEmojiCounts!.counts!.toList()
        : [];

    if (hasReaction) {
      var currentReactionEmojiCount = newEmojiCounts.firstWhere((emojiCount) {
        return emojiCount?.getEmojiId() == reaction!.getEmojiId();
      });

      if (currentReactionEmojiCount?.count != null && currentReactionEmojiCount!.count! > 1) {
        // Decrement emoji reaction counts
        currentReactionEmojiCount.count = currentReactionEmojiCount.count! - 1;
      } else {
        // Remove emoji reaction count
        newEmojiCounts.remove(currentReactionEmojiCount);
      }
    }

    if (newReaction != null) {
      var reactionEmojiCount = newEmojiCounts.firstWhereOrNull((emojiCount) {
        return emojiCount?.getEmojiId() == newReaction.getEmojiId();
      });

      if (reactionEmojiCount != null) {
        // Up existing count
        reactionEmojiCount.count = reactionEmojiCount.count! + 1;
      } else {
        // Add new emoji count
        newEmojiCounts
            .add(ReactionsEmojiCount(emoji: newReaction.emoji, count: 1));
      }
    }

    this.reaction = newReaction;
    this._setReactionsEmojiCounts(
        ReactionsEmojiCountList(counts: newEmojiCounts));

    this.notifyUpdate();
  }

  void _setReactionsEmojiCounts(ReactionsEmojiCountList emojiCounts) {
    reactionsEmojiCounts = emojiCounts;
  }

  bool hasReaction() {
    return reaction != null;
  }

  void _updateHashtagsMap() {
    if (hashtagsList == null) {
      this.hashtagsMap = null;
      return;
    }

    Map<String, Hashtag> updatedMap = Map();
    hashtagsList?.hashtags
        ?.forEach((hashtag) => updatedMap[hashtag.name!] = hashtag);
    hashtagsMap = updatedMap;
  }
}

class PostCommentFactory extends UpdatableModelFactory<PostComment> {
  @override
  SimpleCache<int, PostComment>? cache =
      LruCache(storage: UpdatableModelSimpleStorage(size: 200));

  @override
  PostComment makeFromJson(Map json) {
    return PostComment(
        id: json['id'],
        creatorId: json['creator_id'],
        created: parseCreated(json['created']),
        commenter: parseUser(json['commenter']),
        post: parsePost(json['post']),
        repliesCount: json['replies_count'],
        replies: parseCommentReplies(json['replies']),
        parentComment: parseParentComment(json['parent_comment']),
        isEdited: json['is_edited'],
        isMuted: json['is_muted'],
        isReported: json['is_reported'],
        text: json['text'],
        language: parseLanguage(json['language']),
        reaction: parseReaction(json['reaction']),
        hashtagsList: parseHashtagsList(json['hashtags']),
        reactionsEmojiCounts:
            parseReactionsEmojiCounts(json['reactions_emoji_counts']));
  }

  Post? parsePost(Map<String, dynamic>? post) {
    if (post == null) return null;
    return Post.fromJson(post);
  }

  DateTime? parseCreated(String? created) {
    if (created == null) return null;
    return DateTime.parse(created).toLocal();
  }

  User? parseUser(Map<String, dynamic>? userData) {
    if (userData == null) return null;
    return User.fromJson(userData);
  }

  PostComment? parseParentComment(Map<String, dynamic>? commentData) {
    if (commentData == null) return null;
    return PostComment.fromJSON(commentData);
  }

  PostCommentList? parseCommentReplies(List<dynamic>? repliesData) {
    if (repliesData == null) return null;
    return PostCommentList.fromJson(repliesData);
  }

  PostCommentReaction? parseReaction(Map<String, dynamic>? postCommentReaction) {
    if (postCommentReaction == null) return null;
    return PostCommentReaction.fromJson(postCommentReaction);
  }

  ReactionsEmojiCountList? parseReactionsEmojiCounts(List? reactionsEmojiCounts) {
    if (reactionsEmojiCounts == null) return null;
    return ReactionsEmojiCountList.fromJson(reactionsEmojiCounts);
  }

  Language? parseLanguage(Map<String, dynamic>? languageData) {
    if (languageData == null) return null;
    return Language.fromJson(languageData);
  }

  HashtagsList? parseHashtagsList(List? hashtagsList) {
    if (hashtagsList == null) return null;
    return HashtagsList.fromJson(hashtagsList);
  }
}

enum PostCommentsSortType { asc, dec }
