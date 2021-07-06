class CommunityMembership {
  final int? id;
  final int? userId;
  final int? communityId;
  bool? isAdministrator;
  bool? isModerator;

  CommunityMembership(
      {this.id,
      this.userId,
      this.communityId,
      this.isAdministrator,
      this.isModerator});

  factory CommunityMembership.fromJSON(Map<String, dynamic> parsedJson) {
    return CommunityMembership(
        id: parsedJson['id'],
        communityId: parsedJson['community_id'],
        userId: parsedJson['user_id'],
        isAdministrator: parsedJson['is_administrator'],
        isModerator: parsedJson['is_moderator']);
  }

  Map<String, dynamic> toJson() {
    return {
    'id': id,
    'user_id': userId,
    'community_id': communityId,
    'is_administrator': isAdministrator,
    'is_moderator': isModerator
    };
  }

  void updateFromJson(Map<String, dynamic> json) {
    if (json.containsKey('is_administrator'))
      isAdministrator = json['is_administrator'];
    if (json.containsKey('is_moderator')) isModerator = json['is_moderator'];
  }
}
