class UserNotificationsSettings {
  final int? id;
  bool? postCommentNotifications;
  bool? postCommentReactionNotifications;
  bool? postCommentReplyNotifications;
  bool? postCommentUserMentionNotifications;
  bool? postUserMentionNotifications;
  bool? postReactionNotifications;
  bool? followNotifications;
  bool? followRequestNotifications;
  bool? followRequestApprovedNotifications;
  bool? connectionRequestNotifications;
  bool? connectionConfirmedNotifications;
  bool? communityInviteNotifications;
  bool? communityNewPostNotifications;
  bool? userNewPostNotifications;

  UserNotificationsSettings(
      {this.id,
      this.connectionConfirmedNotifications,
      this.connectionRequestNotifications,
      this.followNotifications,
      this.followRequestNotifications,
      this.followRequestApprovedNotifications,
      this.postCommentNotifications,
      this.postCommentReactionNotifications,
      this.postCommentUserMentionNotifications,
      this.postUserMentionNotifications,
      this.postCommentReplyNotifications,
      this.postReactionNotifications,
      this.communityInviteNotifications,
      this.communityNewPostNotifications,
      this.userNewPostNotifications});

  factory UserNotificationsSettings.fromJSON(Map<String, dynamic> parsedJson) {
    return UserNotificationsSettings(
      id: parsedJson['id'],
      connectionConfirmedNotifications:
          parsedJson['connections_confirmed_notifications'],
      connectionRequestNotifications:
          parsedJson['connection_request_notifications'],
      followNotifications: parsedJson['follow_notifications'],
      followRequestNotifications: parsedJson['follow_request_notifications'],
      followRequestApprovedNotifications: parsedJson['follow_request_approved_notifications'],
      postCommentNotifications: parsedJson['post_comment_notifications'],
      postCommentReactionNotifications:
          parsedJson['post_comment_reaction_notifications'],
      postCommentReplyNotifications:
          parsedJson['post_comment_reply_notifications'],
      postCommentUserMentionNotifications:
          parsedJson['post_comment_user_mention_notifications'],
      postUserMentionNotifications:
          parsedJson['post_user_mention_notifications'],
      postReactionNotifications: parsedJson['post_reaction_notifications'],
      communityInviteNotifications:
          parsedJson['community_invite_notifications'],
      communityNewPostNotifications:
          parsedJson['community_new_post_notifications'],
      userNewPostNotifications:
          parsedJson['user_new_post_notifications'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'connections_confirmed_notifications': connectionConfirmedNotifications,
      'connection_request_notifications': connectionRequestNotifications,
      'follow_notifications': followNotifications,
      'follow_request_notifications': followRequestNotifications,
      'follow_request_approved_notifications': followRequestApprovedNotifications,
      'post_comment_notifications': postCommentNotifications,
      'post_comment_reaction_notifications': postCommentReactionNotifications,
      'post_comment_user_mention_notifications': postCommentUserMentionNotifications,
      'post_user_mention_notifications': postUserMentionNotifications,
      'post_comment_reply_notifications': postCommentReplyNotifications,
      'post_reaction_notifications': postReactionNotifications,
      'community_invite_notifications': communityInviteNotifications,
      'community_new_post_notifications': communityNewPostNotifications,
      'user_new_post_notifications': userNewPostNotifications,
    };
  }

  void updateFromJson(Map<String, dynamic> json) {
    if (json.containsKey('connections_confirmed_notifications'))
      connectionConfirmedNotifications =
          json['connections_confirmed_notifications'];
    if (json.containsKey('connection_request_notifications'))
      connectionRequestNotifications = json['connection_request_notifications'];
    if (json.containsKey('follow_notifications'))
      followNotifications = json['follow_notifications'];

    if (json.containsKey('follow_request_notifications'))
      followRequestNotifications = json['follow_request_notifications'];

    if (json.containsKey('follow_request_approved_notifications'))
      followRequestApprovedNotifications = json['follow_request_approved_notifications'];

    if (json.containsKey('post_comment_notifications'))
      postCommentNotifications = json['post_comment_notifications'];

    if (json.containsKey('post_comment_reaction_notifications'))
      postCommentReactionNotifications =
          json['post_comment_reaction_notifications'];

    if (json.containsKey('post_comment_reply_notifications'))
      postCommentReplyNotifications = json['post_comment_reply_notifications'];

    if (json.containsKey('post_comment_user_mention_notifications'))
      postCommentUserMentionNotifications = json['post_comment_user_mention_notifications'];

    if (json.containsKey('post_user_mention_notifications'))
      postUserMentionNotifications = json['post_user_mention_notifications'];

    if (json.containsKey('post_reaction_notifications'))
      postReactionNotifications = json['post_reaction_notifications'];
    if (json.containsKey('community_invite_notifications'))
      communityInviteNotifications = json['community_invite_notifications'];
    if (json.containsKey('community_new_post_notifications'))
      communityNewPostNotifications = json['community_new_post_notifications'];
    if (json.containsKey('user_new_post_notifications'))
      userNewPostNotifications = json['user_new_post_notifications'];
  }
}
