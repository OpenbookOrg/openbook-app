import 'package:Okuna/models/user_invite.dart';

class UserInvitesList {
  final List<UserInvite>? invites;

  UserInvitesList({
    this.invites,
  });

  factory UserInvitesList.fromJson(List<dynamic> parsedJson) {
    List<UserInvite> userInvites =
    parsedJson.map((inviteJson) => UserInvite.fromJSON(inviteJson)).toList();

    return new UserInvitesList(
      invites: userInvites,
    );
  }
}
