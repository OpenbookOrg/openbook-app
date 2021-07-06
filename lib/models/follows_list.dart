import 'package:Okuna/models/emoji.dart';
import 'package:Okuna/models/updatable_model.dart';
import 'package:Okuna/models/user.dart';
import 'package:Okuna/models/users_list.dart';
import 'package:dcache/dcache.dart';

class FollowsList extends UpdatableModel<FollowsList> {
  final int? id;
  final User? creator;
  UsersList? users;
  Emoji? emoji;
  String? name;
  int? followsCount;

  static final factory = FollowsListFactory();

  factory FollowsList.fromJSON(Map<String, dynamic> json) {
    return factory.fromJson(json);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creator': creator?.toJson(),
      'users': users?.users?.map((User user) => user.toJson()).toList(),
      'emoji': emoji?.toJson(),
      'name': name,
      'follows_count': followsCount
    };
  }

  FollowsList(
      {this.id,
      this.creator,
      this.emoji,
      this.name,
      this.followsCount,
      this.users});

  @override
  void updateFromJson(Map json) {
    if (json.containsKey('users')) {
      users = factory.parseUsers(json['users']);
    }
    if (json.containsKey('emoji')) {
      emoji = factory.parseEmoji(json['emoji']);
    }
    if (json.containsKey('name')) {
      name = json['name'];
    }
    if (json.containsKey('follows_count')) {
      followsCount = json['follows_count'];
    }
  }

  bool hasUsers() {
    return this.users != null;
  }

  String? getEmojiImage() {
    return emoji?.image;
  }

  String getPrettyFollowsCount() {
    String followsCountStr = followsCount.toString();
    return followsCountStr + (followsCount != null && followsCount! > 1 ? '' : '');
  }
}

class FollowsListFactory extends UpdatableModelFactory<FollowsList> {
  @override
  SimpleCache<int, FollowsList>? cache =
      SimpleCache(storage: UpdatableModelSimpleStorage(size: 20));

  @override
  FollowsList makeFromJson(Map json) {
    return FollowsList(
        id: json['id'],
        name: json['name'],
        followsCount: json['follows_count'],
        creator: parseUser(json['creator']),
        users: parseUsers(json['users']),
        emoji: parseEmoji(json['emoji']));
  }

  User? parseUser(Map<String, dynamic>? userData) {
    if (userData == null) return null;
    return User.fromJson(userData);
  }

  UsersList? parseUsers(List? usersData) {
    if (usersData == null) return null;
    return UsersList.fromJson(usersData);
  }

  Emoji? parseEmoji(Map<String, dynamic>? emojiData) {
    if(emojiData == null) return null;
    return Emoji.fromJson(emojiData);
  }
}
