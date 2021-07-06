import 'package:Okuna/models/categories_list.dart';
import 'package:Okuna/models/community_membership.dart';
import 'package:Okuna/models/community_membership_list.dart';
import 'package:Okuna/models/updatable_model.dart';
import 'package:Okuna/models/user.dart';
import 'package:Okuna/models/users_list.dart';
import 'package:dcache/dcache.dart';

import 'category.dart';

class Community extends UpdatableModel<Community> {
  static convertTypeToString(CommunityType type) {
    String result;
    switch (type) {
      case CommunityType.private:
        result = 'T';
        break;
      case CommunityType.public:
        result = 'P';
        break;
      default:
        throw 'Unsupported community type';
    }
    return result;
  }

  static String convertExclusionToString(CommunityMembersExclusion exclusion) {
    String result;
    switch (exclusion) {
      case CommunityMembersExclusion.administrators:
        result = 'administrators';
        break;
      case CommunityMembersExclusion.moderators:
        result = 'moderators';
        break;
      default:
        throw 'Unsupported community members exclusion';
    }
    return result;
  }

  static void clearCache() {
    factory.clearCache();
  }

  final int? id;
  final User? creator;
  String? name;
  String? title;
  String? description;
  String? rules;
  String? color;
  String? avatar;
  String? cover;
  String? userAdjective;
  String? usersAdjective;
  int? membersCount;
  int? postsCount;
  int? pendingModeratedObjectsCount;

  CommunityType? type;

  // Whether the user has been invited to the community
  bool? isInvited;

  // Whether the user has subscribed to the community
  bool? areNewPostNotificationsEnabled;

  // Whether the user is the creator of the community
  bool? isCreator;

  bool? isFavorite;

  bool? isReported;

  bool? invitesEnabled;

  CategoriesList? categories;

  UsersList? moderators;

  UsersList? administrators;

  CommunityMembershipList? memberships;

  Community(
      {this.id,
      this.creator,
      this.rules,
      this.avatar,
      this.title,
      this.type,
      this.userAdjective,
      this.usersAdjective,
      this.description,
      this.name,
      this.color,
      this.cover,
      this.isInvited,
      this.areNewPostNotificationsEnabled,
      this.isCreator,
      this.isReported,
      this.moderators,
      this.memberships,
      this.administrators,
      this.isFavorite,
      this.invitesEnabled,
      this.membersCount,
      this.postsCount,
      this.pendingModeratedObjectsCount,
      this.categories});

  bool hasDescription() {
    return description != null;
  }

  bool hasCover() {
    return cover != null;
  }

  bool hasAvatar() {
    return avatar != null;
  }

  bool isPrivate() {
    return type == CommunityType.private;
  }

  bool isPublic() {
    return type == CommunityType.public;
  }

  bool isAdministrator(User user) {
    CommunityMembership? membership = getMembershipForUser(user);
    if (membership == null) return false;
    return membership.isAdministrator ?? false;
  }

  bool isModerator(User user) {
    CommunityMembership? membership = getMembershipForUser(user);
    if (membership == null) return false;
    return membership.isModerator ?? false;
  }

  bool isMember(User user) {
    return getMembershipForUser(user) != null;
  }

  CommunityMembership? getMembershipForUser(User user) {
    if (memberships == null) return null;

    int membershipIndex = memberships!.communityMemberships!
        .indexWhere((CommunityMembership communityMembership) {
      return communityMembership.userId == user.id &&
          communityMembership.communityId == this.id;
    });

    if (membershipIndex < 0) return null;

    return memberships!.communityMemberships![membershipIndex];
  }

  static final factory = CommunityFactory();

  factory Community.fromJSON(Map<String, dynamic> json) {
    return factory.fromJson(json);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creator': creator?.toJson(),
      'name': name,
      'type': factory.typeToString(type),
      'rules': rules,
      'avatar': avatar,
      'title': title,
      'user_adjective': userAdjective,
      'users_adjective': usersAdjective,
      'description': description,
      'color': color,
      'cover': cover,
      'is_invited': isInvited,
      'are_new_post_notifications_enabled': areNewPostNotificationsEnabled,
      'is_creator': isCreator,
      'is_reported': isReported,
      'moderators':
          moderators?.users?.map((User user) => user.toJson()).toList(),
      'memberships': memberships?.communityMemberships
          ?.map((CommunityMembership membership) => membership.toJson())
          .toList(),
      'administrators':
          administrators?.users?.map((User user) => user.toJson()).toList(),
      'is_favorite': isFavorite,
      'invites_enabled': invitesEnabled,
      'members_count': membersCount,
      'posts_count': postsCount,
      'pending_moderated_objects_count': pendingModeratedObjectsCount,
      'categories': categories?.categories
          ?.map((Category category) => category.toJson())
          .toList()
    };
  }

  @override
  void updateFromJson(Map json) {
    if (json.containsKey('name')) {
      name = json['name'];
    }

    if (json.containsKey('type')) {
      type = factory.parseType(json['type']);
    }

    if (json.containsKey('is_invited')) {
      isInvited = json['is_invited'];
    }

    if (json.containsKey('are_new_post_notifications_enabled')) {
      areNewPostNotificationsEnabled =
          json['are_new_post_notifications_enabled'];
    }

    if (json.containsKey('is_favorite')) {
      isFavorite = json['is_favorite'];
    }

    if (json.containsKey('memberships')) {
      memberships = factory.parseMemberships(json['memberships']);
    }

    if (json.containsKey('is_creator')) {
      isCreator = json['is_creator'];
    }

    if (json.containsKey('invites_enabled')) {
      invitesEnabled = json['invites_enabled'];
    }

    if (json.containsKey('title')) {
      title = json['title'];
    }

    if (json.containsKey('rules')) {
      rules = json['rules'];
    }

    if (json.containsKey('description')) {
      description = json['description'];
    }

    if (json.containsKey('user_adjective')) {
      userAdjective = json['user_adjective'];
    }

    if (json.containsKey('users_adjective')) {
      usersAdjective = json['users_adjective'];
    }

    if (json.containsKey('is_reported')) {
      isReported = json['is_reported'];
    }

    if (json.containsKey('pending_moderated_objects_count')) {
      pendingModeratedObjectsCount = json['pending_moderated_objects_count'];
    }

    if (json.containsKey('color')) {
      color = json['color'];
    }

    if (json.containsKey('avatar')) {
      avatar = json['avatar'];
    }

    if (json.containsKey('cover')) {
      cover = json['cover'];
    }

    if (json.containsKey('members_count')) {
      membersCount = json['members_count'];
    }

    if (json.containsKey('posts_count')) {
      postsCount = json['posts_count'];
    }

    if (json.containsKey('color')) {
      color = json['color'];
    }

    if (json.containsKey('categories')) {
      categories = factory.parseCategories(json['categories']);
    }

    if (json.containsKey('moderators')) {
      moderators = factory.parseUsers(json['moderators']);
    }

    if (json.containsKey('administrators')) {
      administrators = factory.parseUsers(json['administrators']);
    }
  }

  void incrementMembersCount() {
    if (this.membersCount != null) {
      this.membersCount = this.membersCount! + 1;
      notifyUpdate();
    }
  }

  void decrementMembersCount() {
    if (this.membersCount != null && this.membersCount! > 0) {
      this.membersCount = this.membersCount! - 1;
      notifyUpdate();
    }
  }

  void incrementPostsCount() {
    if (this.postsCount != null) {
      this.postsCount = this.postsCount! + 1;
      notifyUpdate();
    }
  }

  void decrementPostsCount() {
    if (this.postsCount != null && this.postsCount! > 0) {
      this.postsCount = this.postsCount! - 1;
      notifyUpdate();
    }
  }

  void setIsReported(isReported) {
    this.isReported = isReported;
    notifyUpdate();
  }
}

class CommunityFactory extends UpdatableModelFactory<Community> {
  @override
  SimpleCache<int, Community>? cache =
      SimpleCache(storage: UpdatableModelSimpleStorage(size: 200));

  @override
  Community makeFromJson(Map json) {
    return Community(
        id: json['id'],
        name: json['name'],
        title: json['title'],
        description: json['description'],
        rules: json['rules'],
        avatar: json['avatar'],
        isInvited: json['is_invited'],
        areNewPostNotificationsEnabled:
            json['are_new_post_notifications_enabled'],
        isCreator: json['is_creator'],
        isReported: json['is_reported'],
        isFavorite: json['is_favorite'],
        invitesEnabled: json['invites_enabled'],
        pendingModeratedObjectsCount: json['pending_moderated_objects_count'],
        cover: json['cover'],
        color: json['color'],
        memberships: parseMemberships(json['memberships']),
        membersCount: json['members_count'],
        postsCount: json['posts_count'],
        userAdjective: json['user_adjective'],
        usersAdjective: json['users_adjective'],
        type: parseType(json['type']),
        creator: parseUser(json['creator']),
        moderators: parseUsers(json['moderators']),
        administrators: parseUsers(json['administrators']),
        categories: parseCategories(json['categories']));
  }

  User? parseUser(Map<String, dynamic>? userData) {
    if (userData == null) return null;
    return User.fromJson(userData);
  }

  UsersList? parseUsers(List? usersData) {
    if (usersData == null) return null;
    return UsersList.fromJson(usersData);
  }

  CommunityMembershipList? parseMemberships(List? membershipsData) {
    if (membershipsData == null) return null;
    return CommunityMembershipList.fromJson(membershipsData);
  }

  CategoriesList? parseCategories(List? categoriesData) {
    if (categoriesData == null) return null;
    return CategoriesList.fromJson(categoriesData);
  }

  CommunityType? parseType(String? strType) {
    if (strType == null) return null;

    CommunityType type;
    if (strType == 'P') {
      type = CommunityType.public;
    } else if (strType == 'T') {
      type = CommunityType.private;
    } else {
      throw 'Unsupported community type';
    }

    return type;
  }

  String typeToString(CommunityType? type) {
    switch (type) {
      case CommunityType.public:
        return 'P';
      case CommunityType.private:
        return 'T';
      default:
        return '<unknown>';
    }
  }
}

enum CommunityType { public, private }

enum CommunityMembersExclusion { administrators, moderators }
