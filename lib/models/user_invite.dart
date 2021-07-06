import 'package:Okuna/models/updatable_model.dart';
import 'package:Okuna/models/user.dart';
import 'package:dcache/dcache.dart';

class UserInvite extends UpdatableModel<UserInvite> {
  final int? id;
  String? email;
  final DateTime? created;
  User? createdUser;
  String? nickname;
  final String? token;
  bool? isInviteEmailSent;

  static const String IOS_DOWNLOAD_LINK = 'https://testflight.apple.com/join/XniAjdyF';
  static const String TESTFLIGHT_DOWNLOAD_LINK = 'https://itunes.apple.com/us/app/testflight/id899247664';
  static const String ANDROID_DOWNLOAD_LINK = 'https://play.google.com/store/apps/details?id=social.openbook.app';
  static const  INVITE_LINK = '{apiURL}api/auth/invite?token={token}';

  static convertUserInviteStatusToBool(UserInviteFilterByStatus value) {
    bool? isPending;
    switch (value) {
      case UserInviteFilterByStatus.all:
        isPending = null;
        break;
      case UserInviteFilterByStatus.pending:
        isPending = true;
        break;
      case UserInviteFilterByStatus.accepted:
        isPending = false;
        break;
      default:
        throw 'Unsupported post comment sort type';
    }
    return isPending;
  }

  static void clearCache() {
    factory.clearCache();
  }

  static final factory = UserInviteFactory();

  factory UserInvite.fromJSON(Map<String, dynamic> json) {
    return factory.fromJson(json);
  }

  UserInvite({this.id, this.email, this.created, this.createdUser, this.nickname, this.token, this.isInviteEmailSent});

  @override
  void updateFromJson(Map json) {
    if (json.containsKey('email')) {
      email = json['email'];
    }

    if (json.containsKey('created_user')) {
      createdUser = factory.parseUser(json['created_user']);
    }

    if (json.containsKey('nickname')) {
      nickname = json['nickname'];
    }

    if (json.containsKey('is_invite_email_sent')) {
      isInviteEmailSent = json['is_invite_email_sent'];
    }
  }
}

class UserInviteFactory extends UpdatableModelFactory<UserInvite> {
  @override
  SimpleCache<int, UserInvite>? cache =
  LruCache(storage: UpdatableModelSimpleStorage(size: 10));

  @override
  UserInvite makeFromJson(Map json) {
    DateTime? created;
    var createdData = json['created'];
    if (createdData != null) created = DateTime.parse(createdData).toLocal();

    return UserInvite(
        id: json['id'],
        email: json['email'],
        created: created,
        createdUser: parseUser(json['created_user']),
        nickname: json['nickname'],
        token: json['token'],
        isInviteEmailSent: json['is_invite_email_sent']);
  }

  User? parseUser(Map<String, dynamic>? userData) {
    if (userData == null) return null;
    return User.fromJson(userData);
  }
}

enum UserInviteFilterByStatus { pending, accepted, all }
