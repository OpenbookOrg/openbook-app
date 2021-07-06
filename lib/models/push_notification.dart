import 'package:Okuna/models/notifications/notification.dart';

class PushNotification {
  static PushNotificationType? parseType(String? pushNotificationTypeStr) {
    if (pushNotificationTypeStr == null) return null;

    PushNotificationType pushNotificationType;
    if (pushNotificationTypeStr == NotificationType.postReaction.code) {
      pushNotificationType = PushNotificationType.postReaction;
    } else if (pushNotificationTypeStr == NotificationType.postComment.code) {
      pushNotificationType = PushNotificationType.postComment;
    } else if (pushNotificationTypeStr == NotificationType.connectionRequest.code) {
      pushNotificationType = PushNotificationType.connectionRequest;
    } else if (pushNotificationTypeStr == NotificationType.follow.code) {
      pushNotificationType = PushNotificationType.follow;
    } else if (pushNotificationTypeStr == NotificationType.communityInvite.code) {
      pushNotificationType = PushNotificationType.communityInvite;
    } else {
      throw 'Unsupported push notification type';
    }

    return pushNotificationType;
  }

  final PushNotificationType? type;
  final int? notificationId;

  const PushNotification({this.notificationId, this.type});

  factory PushNotification.fromJson(Map<String, dynamic> parsedJson) {
    PushNotificationType? type = parseType(parsedJson['type']);

    return PushNotification(
        notificationId: parsedJson['notification_id'], type: type);
  }
}

enum PushNotificationType {
  postReaction,
  postComment,
  connectionRequest,
  follow,
  communityInvite
}
