
import 'package:Okuna/services/httpie.dart';
import 'package:Okuna/services/string_template.dart';
import 'package:meta/meta.dart';

class FollowsListsApiService {
  late HttpieService _httpService;
  late StringTemplateService _stringTemplateService;

  late String apiURL;

  static const GET_LISTS_PATH = 'api/lists/';
  static const CREATE_LIST_PATH = 'api/lists/';
  static const UPDATE_LIST_PATH = 'api/lists/{listId}/';
  static const DELETE_LIST_PATH = 'api/lists/{listId}/';
  static const GET_LIST_PATH = 'api/lists/{listId}/';
  static const CHECK_NAME_PATH = 'api/lists/name-check/';

  void setHttpService(HttpieService httpService) {
    _httpService = httpService;
  }

  void setStringTemplateService(StringTemplateService stringTemplateService) {
    _stringTemplateService = stringTemplateService;
  }

  void setApiURL(String newApiURL) {
    apiURL = newApiURL;
  }

  Future<HttpieResponse> getLists() {
    String url = _makeApiUrl(GET_LISTS_PATH);
    return _httpService.get(url, appendAuthorizationToken: true);
  }

  Future<HttpieResponse> createList({required String name, int? emojiId}) {
    String url = _makeApiUrl(CREATE_LIST_PATH);
    Map<String, dynamic> body = {'name': name};

    if (emojiId != null) body['emoji_id'] = emojiId;

    return _httpService.putJSON(url,
        appendAuthorizationToken: true, body: body);
  }

  Future<HttpieResponse> updateListWithId(int listId,
      {String? name, int? emojiId, List<String>? usernames}) {
    Map<String, dynamic> body = {};

    if (emojiId != null) body['emoji_id'] = emojiId;

    if (name != null) body['name'] = name;

    if (usernames != null) body['usernames'] = usernames;

    String url = _makeUpdateListPath(listId);
    return _httpService.patchJSON(url,
        appendAuthorizationToken: true, body: body);
  }

  Future<HttpieResponse> deleteListWithId(int listId) {
    String url = _makeDeleteListPath(listId);
    return _httpService.delete(url, appendAuthorizationToken: true);
  }

  Future<HttpieResponse> getListWithId(int listId) {
    String url = _makeGetListPath(listId);
    return _httpService.get(url, appendAuthorizationToken: true);
  }

  Future<HttpieResponse> checkNameIsAvailable({required String name}) {
    return _httpService.postJSON('$apiURL$CHECK_NAME_PATH',
        body: {'name': name}, appendAuthorizationToken: true);
  }

  String _makeUpdateListPath(int listId) {
    return _stringTemplateService
        .parse('$apiURL$UPDATE_LIST_PATH', {'listId': listId});
  }

  String _makeDeleteListPath(int listId) {
    return _stringTemplateService
        .parse('$apiURL$DELETE_LIST_PATH', {'listId': listId});
  }

  String _makeGetListPath(int listId) {
    return _stringTemplateService
        .parse('$apiURL$GET_LIST_PATH', {'listId': listId});
  }

  String _makeApiUrl(String string) {
    return '$apiURL$string';
  }
}
