import 'package:Okuna/models/notifications/notification.dart';
import 'package:Okuna/services/httpie.dart';
import 'package:Okuna/services/string_template.dart';

class NotificationsApiService {
  late HttpieService _httpService;
  late StringTemplateService _stringTemplateService;

  late String apiURL;

  static const NOTIFICATIONS_PATH = 'api/notifications/';
  static const NOTIFICATIONS_READ_PATH = 'api/notifications/read/';
  static const NOTIFICATIONS_UNREAD_COUNT_PATH = 'api/notifications/unread/count/';
  static const NOTIFICATION_PATH = 'api/notifications/{notificationId}/';
  static const NOTIFICATION_READ_PATH =
      'api/notifications/{notificationId}/read/';

  void setHttpService(HttpieService httpService) {
    _httpService = httpService;
  }

  void setStringTemplateService(StringTemplateService stringTemplateService) {
    _stringTemplateService = stringTemplateService;
  }

  void setApiURL(String newApiURL) {
    apiURL = newApiURL;
  }

  Future<HttpieResponse> getNotifications(
      {int? maxId, int? count, List<NotificationType>? types}) {
    Map<String, dynamic> queryParams = {};

    if (maxId != null) queryParams['max_id'] = maxId;

    if (count != null) queryParams['count'] = count;

    if (types != null && types.isNotEmpty)
      queryParams['types'] = types.map<String>((type) => type.code).toList();

    String url = _makeApiUrl(NOTIFICATIONS_PATH);
    return _httpService.get(url,
        appendAuthorizationToken: true, queryParameters: queryParams);
  }

  Future<HttpieResponse> getUnreadNotificationsCount(
      {int? maxId, List<NotificationType>? types}) {
    Map<String, dynamic> queryParams = {};

    if (maxId != null) queryParams['max_id'] = maxId;

    if (types != null && types.isNotEmpty)
      queryParams['types'] = types.map<String>((type) => type.code).toList();

    String url = _makeApiUrl(NOTIFICATIONS_UNREAD_COUNT_PATH);
    return _httpService.get(url,
        appendAuthorizationToken: true, queryParameters: queryParams);
  }

  Future<HttpieResponse> readNotifications(
      {int? maxId, List<NotificationType>? types}) {
    String url = _makeApiUrl(NOTIFICATIONS_READ_PATH);
    Map<String, dynamic> body = {};

    if (maxId != null) body['max_id'] = maxId.toString();

    if (types != null && types.isNotEmpty)
      body['types'] = types.map<String>((type) => type.code).join(',');

    return _httpService.post(url, body: body, appendAuthorizationToken: true);
  }

  Future<HttpieResponse> deleteNotifications() {
    String url = _makeApiUrl(NOTIFICATIONS_PATH);
    return _httpService.delete(url, appendAuthorizationToken: true);
  }

  Future<HttpieResponse> deleteNotificationWithId(int notificationId) {
    String url = _makeNotificationPath(notificationId);
    return _httpService.delete(url, appendAuthorizationToken: true);
  }

  Future<HttpieResponse> getNotificationWithId(int notificationId) {
    String url = _makeNotificationPath(notificationId);
    return _httpService.get(url, appendAuthorizationToken: true);
  }

  Future<HttpieResponse> readNotificationWithId(int notificationId) {
    String url = _makeReadNotificationPath(notificationId);
    return _httpService.post(url, appendAuthorizationToken: true);
  }

  String _makeNotificationPath(int notificationId) {
    return _stringTemplateService
        .parse('$apiURL$NOTIFICATION_PATH', {'notificationId': notificationId});
  }

  String _makeReadNotificationPath(int notificationId) {
    return _stringTemplateService.parse(
        '$apiURL$NOTIFICATION_READ_PATH', {'notificationId': notificationId});
  }

  String _makeApiUrl(String string) {
    return '$apiURL$string';
  }
}
