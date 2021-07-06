import 'package:Okuna/services/httpie.dart';
import 'package:Okuna/services/string_template.dart';

class ModerationApiService {
  late HttpieService _httpService;
  late StringTemplateService _stringTemplateService;

  late String apiURL;

  static const GET_GLOBAL_MODERATED_OBJECTS_PATH =
      'api/moderation/moderated-objects/global/';
  static const USER_MODERATION_PENALTIES_PATH =
      'api/moderation/user/penalties/';
  static const USER_PENDING_MODERATED_OBJECTS_COMMUNITIES_PATH =
      'api/moderation/user/pending-moderated-objects-communities/';
  static const GET_MODERATION_CATEGORIES_PATH = 'api/moderation/categories/';
  static const MODERATED_OBJECT_PATH =
      'api/moderation/moderated-objects/{moderatedObjectId}/';
  static const APPROVE_MODERATED_OBJECT_PATH =
      'api/moderation/moderated-objects/{moderatedObjectId}/approve/';
  static const REJECT_MODERATED_OBJECT_PATH =
      'api/moderation/moderated-objects/{moderatedObjectId}/reject/';
  static const VERIFY_MODERATED_OBJECT_PATH =
      'api/moderation/moderated-objects/{moderatedObjectId}/verify/';
  static const UNVERIFY_MODERATED_OBJECT_PATH =
      'api/moderation/moderated-objects/{moderatedObjectId}/unverify/';
  static const MODERATED_OBJECT_LOGS_PATH =
      'api/moderation/moderated-objects/{moderatedObjectId}/logs/';
  static const MODERATED_OBJECT_REPORTS_PATH =
      'api/moderation/moderated-objects/{moderatedObjectId}/reports/';

  void setHttpieService(HttpieService httpService) {
    _httpService = httpService;
  }

  void setStringTemplateService(StringTemplateService stringTemplateService) {
    _stringTemplateService = stringTemplateService;
  }

  void setApiURL(String newApiURL) {
    apiURL = newApiURL;
  }

  Future<HttpieResponse> getGlobalModeratedObjects({
    int? count,
    int? maxId,
    String? type,
    bool? verified,
    List<String>? statuses,
    List<String>? types,
  }) {
    Map<String, dynamic> queryParams = {};
    if (count != null) queryParams['count'] = count;

    if (maxId != null) queryParams['max_id'] = maxId;

    if (statuses != null) queryParams['statuses'] = statuses;

    if (types != null) queryParams['types'] = types;

    if (verified != null) queryParams['verified'] = verified;

    String path = GET_GLOBAL_MODERATED_OBJECTS_PATH;

    return _httpService.get(_makeApiUrl(path),
        queryParameters: queryParams, appendAuthorizationToken: true);
  }

  Future<HttpieResponse> getModeratedObjectLogs(
    int moderatedObjectId, {
    int? count,
    int? maxId,
  }) {
    Map<String, dynamic> queryParams = {};
    if (count != null) queryParams['count'] = count;

    if (maxId != null) queryParams['max_id'] = maxId;

    String path = _makeModeratedObjectLogsPath(moderatedObjectId);

    return _httpService.get(_makeApiUrl(path),
        queryParameters: queryParams, appendAuthorizationToken: true);
  }

  Future<HttpieResponse> getModeratedObjectReports(
    int moderatedObjectId, {
    int? count,
    int? maxId,
  }) {
    Map<String, dynamic> queryParams = {};
    if (count != null) queryParams['count'] = count;

    if (maxId != null) queryParams['max_id'] = maxId;

    String path = _makeModeratedObjectReportsPath(moderatedObjectId);

    return _httpService.get(_makeApiUrl(path),
        queryParameters: queryParams, appendAuthorizationToken: true);
  }

  Future<HttpieResponse> getModerationCategories() {
    String path = GET_MODERATION_CATEGORIES_PATH;

    return _httpService.get(_makeApiUrl(path), appendAuthorizationToken: true);
  }

  Future<HttpieResponse> getUserModerationPenalties({int? maxId, int? count}) {
    Map<String, dynamic> queryParams = {};
    if (count != null) queryParams['count'] = count;

    if (maxId != null) queryParams['max_id'] = maxId;

    String path = USER_MODERATION_PENALTIES_PATH;

    return _httpService.get(_makeApiUrl(path),
        queryParameters: queryParams, appendAuthorizationToken: true);
  }

  Future<HttpieResponse> getUserPendingModeratedObjectsCommunities(
      {int? maxId, int? count}) {
    Map<String, dynamic> queryParams = {};
    if (count != null) queryParams['count'] = count;

    if (maxId != null) queryParams['max_id'] = maxId;

    String path = USER_PENDING_MODERATED_OBJECTS_COMMUNITIES_PATH;

    return _httpService.get(_makeApiUrl(path),
        queryParameters: queryParams, appendAuthorizationToken: true);
  }

  Future<HttpieResponse> verifyModeratedObjectWithId(int moderatedObjectId) {
    String path = _makeVerifyModeratedObjectsPath(moderatedObjectId);

    return _httpService.post(_makeApiUrl(path), appendAuthorizationToken: true);
  }

  Future<HttpieResponse> unverifyModeratedObjectWithId(int moderatedObjectId) {
    String path = _makeUnverifyModeratedObjectsPath(moderatedObjectId);

    return _httpService.post(_makeApiUrl(path), appendAuthorizationToken: true);
  }

  Future<HttpieResponse> approveModeratedObjectWithId(int moderatedObjectId) {
    String path = _makeApproveModeratedObjectsPath(moderatedObjectId);

    return _httpService.post(_makeApiUrl(path), appendAuthorizationToken: true);
  }

  Future<HttpieResponse> rejectModeratedObjectWithId(int moderatedObjectId) {
    String path = _makeRejectModeratedObjectsPath(moderatedObjectId);

    return _httpService.post(_makeApiUrl(path), appendAuthorizationToken: true);
  }

  Future<HttpieResponse> updateModeratedObjectWithId(int moderatedObjectId,
      {String? description, int? categoryId}) {
    Map<String, dynamic> body = {};

    if (description != null) body['description'] = description;

    if (categoryId != null) body['category_id'] = categoryId.toString();

    String path = _makeModeratedObjectsPath(moderatedObjectId);

    return _httpService.patchJSON(_makeApiUrl(path),
        body: body, appendAuthorizationToken: true);
  }

  String _makeModeratedObjectsPath(int moderatedObjectId) {
    return _stringTemplateService
        .parse(MODERATED_OBJECT_PATH, {'moderatedObjectId': moderatedObjectId});
  }

  String _makeVerifyModeratedObjectsPath(int moderatedObjectId) {
    return _stringTemplateService.parse(
        VERIFY_MODERATED_OBJECT_PATH, {'moderatedObjectId': moderatedObjectId});
  }

  String _makeUnverifyModeratedObjectsPath(int moderatedObjectId) {
    return _stringTemplateService.parse(UNVERIFY_MODERATED_OBJECT_PATH,
        {'moderatedObjectId': moderatedObjectId});
  }

  String _makeApproveModeratedObjectsPath(int moderatedObjectId) {
    return _stringTemplateService.parse(APPROVE_MODERATED_OBJECT_PATH,
        {'moderatedObjectId': moderatedObjectId});
  }

  String _makeModeratedObjectLogsPath(int moderatedObjectId) {
    return _stringTemplateService.parse(
        MODERATED_OBJECT_LOGS_PATH, {'moderatedObjectId': moderatedObjectId});
  }

  String _makeModeratedObjectReportsPath(int moderatedObjectId) {
    return _stringTemplateService.parse(MODERATED_OBJECT_REPORTS_PATH,
        {'moderatedObjectId': moderatedObjectId});
  }

  String _makeRejectModeratedObjectsPath(int moderatedObjectId) {
    return _stringTemplateService.parse(
        REJECT_MODERATED_OBJECT_PATH, {'moderatedObjectId': moderatedObjectId});
  }

  String _makeApiUrl(String string) {
    return '$apiURL$string';
  }
}
