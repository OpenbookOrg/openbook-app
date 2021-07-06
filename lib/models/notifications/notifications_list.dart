import 'package:Okuna/models/notifications/notification.dart';

class NotificationsList {
  final List<OBNotification>? notifications;

  NotificationsList({
    this.notifications,
  });

  factory NotificationsList.fromJson(List<dynamic> parsedJson) {
    List<OBNotification> notifications = parsedJson
        .map((notificationJson) => OBNotification.fromJSON(notificationJson))
        .toList();

    return new NotificationsList(
      notifications: notifications,
    );
  }
}
