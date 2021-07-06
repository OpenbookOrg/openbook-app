import 'package:Okuna/libs/str_utils.dart';
import 'package:Okuna/models/community.dart';
import 'package:Okuna/models/hashtag.dart';
import 'package:Okuna/models/moderation/moderation_category.dart';
import 'package:Okuna/models/post.dart';
import 'package:Okuna/models/post_comment.dart';
import 'package:Okuna/models/updatable_model.dart';
import 'package:Okuna/models/user.dart';
import 'package:dcache/dcache.dart';
import 'package:meta/meta.dart';

class ModeratedObject extends UpdatableModel<ModeratedObject> {
  static final factory = ModeratedObjectFactory();

  factory ModeratedObject.fromJSON(Map<String, dynamic> json) {
    return factory.fromJson(json);
  }

  static String objectTypePost = 'P';
  static String objectTypePostComment = 'PC';
  static String objectTypeCommunity = 'C';
  static String objectTypeUser = 'U';
  static String objectTypeHashtag = 'H';

  static String statusPending = 'P';
  static String statusApproved = 'A';
  static String statusRejected = 'R';

  final int? id;
  final Community? community;

  dynamic contentObject;
  ModeratedObjectType? type;
  ModeratedObjectStatus? status;
  ModerationCategory? category;

  String? description;
  bool? verified;
  int? reportsCount;

  ModeratedObject(
      {this.id,
      this.community,
      this.contentObject,
      this.type,
      this.status,
      this.reportsCount,
      this.category,
      this.description,
      this.verified});

  @override
  void updateFromJson(Map json) {
    if (json.containsKey('description')) {
      description = json['description'];
    }

    if (json.containsKey('category')) {
      category = factory.parseModerationCategory(json['category']);
    }

    if (json.containsKey('verified')) {
      verified = json['verified'];
    }

    if (json.containsKey('reports_count')) {
      reportsCount = json['reports_count'];
    }

    if (json.containsKey('status')) {
      status = factory.parseStatus(json['status']);
    }

    if (json.containsKey('type')) {
      type = factory.parseType(json['object_type']);
    }

    if (json.containsKey('content_object')) {
      contentObject = factory.parseContentObject(
          contentObjectData: json['content_object'], type: type);
    }
  }

  void setIsVerified(bool isVerified) {
    verified = isVerified;
    notifyUpdate();
  }

  bool isVerified() {
    return verified ?? false;
  }

  void setIsApproved() {
    setStatus(ModeratedObjectStatus.approved);
  }

  void setIsRejected() {
    setStatus(ModeratedObjectStatus.rejected);
  }

  void setStatus(ModeratedObjectStatus newStatus) {
    status = newStatus;
    notifyUpdate();
  }
}

class ModeratedObjectFactory extends UpdatableModelFactory<ModeratedObject> {
  @override
  SimpleCache<int, ModeratedObject>? cache =
      SimpleCache(storage: UpdatableModelSimpleStorage(size: 120));

  @override
  ModeratedObject makeFromJson(Map json) {
    ModeratedObjectType? type = parseType(json['object_type']);
    ModeratedObjectStatus? status = parseStatus(json['status']);
    ModerationCategory? category = parseModerationCategory(json['category']);
    Community? community = parseCommunity(json['community']);

    return ModeratedObject(
        id: json['id'],
        community: community,
        category: category,
        description: json['description'],
        reportsCount: json['reports_count'],
        status: status,
        type: type,
        contentObject: parseContentObject(
            contentObjectData: json['content_object'], type: type),
        verified: json['verified']);
  }

  Community? parseCommunity(Map<String, dynamic>? communityData) {
    if (communityData == null) return null;
    return Community.fromJSON(communityData);
  }

  ModerationCategory? parseModerationCategory(Map<String, dynamic>? moderationCategoryData) {
    if (moderationCategoryData == null) return null;
    return ModerationCategory.fromJson(moderationCategoryData);
  }

  ModeratedObjectType? parseType(String? moderatedObjectTypeStr) {
    if (moderatedObjectTypeStr == null) return null;

    ModeratedObjectType? moderatedObjectType;
    if (moderatedObjectTypeStr == ModeratedObject.objectTypeCommunity) {
      moderatedObjectType = ModeratedObjectType.community;
    } else if (moderatedObjectTypeStr == ModeratedObject.objectTypePost) {
      moderatedObjectType = ModeratedObjectType.post;
    } else if (moderatedObjectTypeStr ==
        ModeratedObject.objectTypePostComment) {
      moderatedObjectType = ModeratedObjectType.postComment;
    } else if (moderatedObjectTypeStr == ModeratedObject.objectTypeUser) {
      moderatedObjectType = ModeratedObjectType.user;
    } else if (moderatedObjectTypeStr == ModeratedObject.objectTypeHashtag) {
      moderatedObjectType = ModeratedObjectType.hashtag;
    } else {
      // Don't throw as we might introduce new moderatedObjects on the API which might not be yet in code
      print('Unsupported moderatedObject type');
    }

    return moderatedObjectType;
  }

  ModeratedObjectStatus? parseStatus(String? moderatedObjectStatusStr) {
    if (moderatedObjectStatusStr == null) return null;

    ModeratedObjectStatus? moderatedObjectStatus;
    if (moderatedObjectStatusStr == ModeratedObject.statusPending) {
      moderatedObjectStatus = ModeratedObjectStatus.pending;
    } else if (moderatedObjectStatusStr == ModeratedObject.statusApproved) {
      moderatedObjectStatus = ModeratedObjectStatus.approved;
    } else if (moderatedObjectStatusStr == ModeratedObject.statusRejected) {
      moderatedObjectStatus = ModeratedObjectStatus.rejected;
    } else {
      // Don't throw as we might introduce new moderatedObjects on the API which might not be yet in code
      print('Unsupported moderatedObject status');
    }

    return moderatedObjectStatus;
  }

  String? convertStatusToString(ModeratedObjectStatus? moderatedObjectStatus) {
    if (moderatedObjectStatus == null) return null;

    switch (moderatedObjectStatus) {
      case ModeratedObjectStatus.approved:
        return ModeratedObject.statusApproved;
      case ModeratedObjectStatus.rejected:
        return ModeratedObject.statusRejected;
      case ModeratedObjectStatus.pending:
        return ModeratedObject.statusPending;
      default:
        return '';
    }
  }

  String? convertStatusToHumanReadableString(
      ModeratedObjectStatus? moderatedObjectStatus,
      {capitalize = false}) {
    if (moderatedObjectStatus == null) return null;

    late String result;

    switch (moderatedObjectStatus) {
      case ModeratedObjectStatus.approved:
        result = 'approved';
        break;
      case ModeratedObjectStatus.rejected:
        result = 'rejected';
        break;
      case ModeratedObjectStatus.pending:
        result = 'pending';
        break;
      default:
    }

    return capitalize ? toCapital(result) : result;
  }

  String? convertTypeToString(ModeratedObjectType? moderatedObjectType) {
    if (moderatedObjectType == null) return null;

    switch (moderatedObjectType) {
      case ModeratedObjectType.community:
        return ModeratedObject.objectTypeCommunity;
      case ModeratedObjectType.user:
        return ModeratedObject.objectTypeUser;
        case ModeratedObjectType.hashtag:
        return ModeratedObject.objectTypeHashtag;
      case ModeratedObjectType.post:
        return ModeratedObject.objectTypePost;
      case ModeratedObjectType.postComment:
        return ModeratedObject.objectTypePostComment;
      default:
        return '';
    }
  }

  String? convertTypeToHumanReadableString(
      ModeratedObjectType? moderatedObjectType,
      {capitalize = false}) {
    if (moderatedObjectType == null) return null;

    String result = 'object';

    switch (moderatedObjectType) {
      case ModeratedObjectType.community:
        result = 'community';
        break;
      case ModeratedObjectType.user:
        result = 'user';
        break;
      case ModeratedObjectType.hashtag:
        result = 'hashtag';
        break;
      case ModeratedObjectType.post:
        result = 'post';
        break;
      case ModeratedObjectType.postComment:
        result = 'post comment';
        break;
      default:
    }

    return capitalize ? toCapital(result) : result;
  }

  dynamic parseContentObject(
      {required Map<String, dynamic>? contentObjectData, required ModeratedObjectType? type}) {
    if (contentObjectData == null) return null;

    dynamic contentObject;
    switch (type) {
      case ModeratedObjectType.post:
        contentObject = Post.fromJson(contentObjectData);
        break;
      case ModeratedObjectType.postComment:
        contentObject = PostComment.fromJSON(contentObjectData);
        break;
      case ModeratedObjectType.community:
        contentObject = Community.fromJSON(contentObjectData);
        break;
      case ModeratedObjectType.user:
        contentObject = User.fromJson(contentObjectData);
        break;
      case ModeratedObjectType.hashtag:
        contentObject = Hashtag.fromJSON(contentObjectData);
        break;
      default:
    }
    return contentObject;
  }

  DateTime parseCreated(String created) {
    return DateTime.parse(created).toLocal();
  }
}

enum ModeratedObjectType { post, postComment, user, community, hashtag }

enum ModeratedObjectStatus {
  approved,
  rejected,
  pending,
}
