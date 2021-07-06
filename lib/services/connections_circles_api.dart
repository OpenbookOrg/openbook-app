
import 'package:Okuna/services/httpie.dart';
import 'package:Okuna/services/string_template.dart';
import 'package:meta/meta.dart';

class ConnectionsCirclesApiService {
  late HttpieService _httpService;
  late StringTemplateService _stringTemplateService;

  late String apiURL;

  static const GET_CIRCLES_PATH = 'api/circles/';
  static const CREATE_CIRCLE_PATH = 'api/circles/';
  static const UPDATE_CIRCLE_PATH = 'api/circles/{circleId}/';
  static const DELETE_CIRCLE_PATH = 'api/circles/{circleId}/';
  static const GET_CIRCLE_PATH = 'api/circles/{circleId}/';
  static const CHECK_NAME_PATH = 'api/circles/name-check/';

  void setHttpService(HttpieService httpService) {
    _httpService = httpService;
  }

  void setStringTemplateService(StringTemplateService stringTemplateService) {
    _stringTemplateService = stringTemplateService;
  }

  void setApiURL(String newApiURL) {
    apiURL = newApiURL;
  }

  Future<HttpieResponse> getCircles() {
    String url = _makeApiUrl(GET_CIRCLES_PATH);
    return _httpService.get(url, appendAuthorizationToken: true);
  }

  Future<HttpieResponse> createCircle({required String name, String? color}) {
    String url = _makeApiUrl(CREATE_CIRCLE_PATH);
    Map<String, dynamic> body = {'name': name};

    if (color != null) body['color'] = color;

    return _httpService.putJSON(url,
        appendAuthorizationToken: true, body: body);
  }

  Future<HttpieResponse> updateCircleWithId(int circleId,
      {String? name, String? color, List<String>? usernames}) {
    Map<String, dynamic> body = {};

    if (color != null) body['color'] = color;

    if (name != null) body['name'] = name;

    if (usernames != null) body['usernames'] = usernames;

    String url = _makeUpdateCirclePath(circleId);
    return _httpService.patchJSON(url,
        appendAuthorizationToken: true, body: body);
  }

  Future<HttpieResponse> deleteCircleWithId(int circleId) {
    String url = _makeDeleteCirclePath(circleId);
    return _httpService.delete(url, appendAuthorizationToken: true);
  }

  Future<HttpieResponse> getCircleWithId(int circleId) {
    String url = _makeGetCirclePath(circleId);
    return _httpService.get(url, appendAuthorizationToken: true);
  }

  Future<HttpieResponse> checkNameIsAvailable({required String name}) {
    return _httpService.postJSON('$apiURL$CHECK_NAME_PATH',
        body: {'name': name}, appendAuthorizationToken: true);
  }

  String _makeUpdateCirclePath(int circleId) {
    return _stringTemplateService
        .parse('$apiURL$UPDATE_CIRCLE_PATH', {'circleId': circleId});
  }

  String _makeDeleteCirclePath(int circleId) {
    return _stringTemplateService
        .parse('$apiURL$DELETE_CIRCLE_PATH', {'circleId': circleId});
  }

  String _makeGetCirclePath(int circleId) {
    return _stringTemplateService
        .parse('$apiURL$GET_CIRCLE_PATH', {'circleId': circleId});
  }

  String _makeApiUrl(String string) {
    return '$apiURL$string';
  }
}
