import 'package:Okuna/models/community_invite.dart';

class CommunityInviteNotification {
  final int? id;
  final CommunityInvite? communityInvite;

  const CommunityInviteNotification({
    this.communityInvite,
    this.id,
  });

  factory CommunityInviteNotification.fromJson(Map<String, dynamic> json) {
    return CommunityInviteNotification(
        id: json['id'],
        communityInvite: _parseCommunityInvite(json['community_invite']));
  }

  static CommunityInvite _parseCommunityInvite(Map<String, dynamic> communityInviteData) {
    return CommunityInvite.fromJSON(communityInviteData);
  }
}
