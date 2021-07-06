import 'package:Okuna/models/community_invite.dart';

class CommunityInviteList {
  final List<CommunityInvite>? communityInvites;

  CommunityInviteList({
    this.communityInvites,
  });

  factory CommunityInviteList.fromJson(List<dynamic> parsedJson) {
    List<CommunityInvite> communityInvites = parsedJson
        .map((communityInviteJson) =>
            CommunityInvite.fromJSON(communityInviteJson))
        .toList();

    return new CommunityInviteList(
      communityInvites: communityInvites,
    );
  }
}
