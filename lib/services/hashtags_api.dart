import 'package:Okuna/services/httpie.dart';
import 'package:Okuna/services/string_template.dart';
import 'package:meta/meta.dart';

class HashtagsApiService {
  late HttpieService _httpService;
  late StringTemplateService _stringTemplateService;

  late String apiURL;

  static const SEARCH_HASHTAGS_PATH = 'api/hashtags/search/';
  static const GET_TRENDING_HASHTAGS_PATH = 'api/hashtags/trending/';
  static const GET_SUGGESTED_HASHTAGS_PATH = 'api/hashtags/suggested/';
  static const GET_HASHTAG_PATH = 'api/hashtags/{hashtagName}/';
  static const REPORT_HASHTAG_PATH =
      'api/hashtags/{hashtagName}/report/';
  static const GET_HASHTAG_POSTS_PATH =
      'api/hashtags/{hashtagName}/posts/';

  void setHttpieService(HttpieService httpService) {
    _httpService = httpService;
  }

  void setStringTemplateService(StringTemplateService stringTemplateService) {
    _stringTemplateService = stringTemplateService;
  }

  void setApiURL(String newApiURL) {
    apiURL = newApiURL;
  }

  Future<HttpieResponse> getTrendingHashtags(
      {bool authenticatedRequest = true}) {
    Map<String, dynamic> queryParams = {};

    return _httpService.get('$apiURL$GET_TRENDING_HASHTAGS_PATH',
        queryParameters: queryParams,
        appendAuthorizationToken: authenticatedRequest);
  }

  Future<HttpieResponse> getSuggestedHashtags(
      {bool authenticatedRequest = true}) {

    return _httpService.get('$apiURL$GET_SUGGESTED_HASHTAGS_PATH',
        appendAuthorizationToken: authenticatedRequest);
  }

  Future<HttpieResponse> getHashtagsWithQuery(
      {bool authenticatedRequest = true, required String query}) {
    Map<String, dynamic> queryParams = {'query': query};

    return _httpService.get('$apiURL$SEARCH_HASHTAGS_PATH',
        queryParameters: queryParams,
        appendAuthorizationToken: authenticatedRequest);
  }

  Future<HttpieResponse> getHashtagWithName(String name,
      {bool authenticatedRequest = true}) {
    String url = _makeGetHashtagPath(name);
    return _httpService.get(_makeApiUrl(url),
        appendAuthorizationToken: authenticatedRequest);
  }

  Future<HttpieResponse> reportHashtagWithName(
      {required String hashtagName,
      required int moderationCategoryId,
      String? description}) {
    String path = _makeReportHashtagPath(hashtagName);

    Map<String, dynamic> body = {
      'category_id': moderationCategoryId.toString()
    };

    if (description != null && description.isNotEmpty) {
      body['description'] = description;
    }

    return _httpService.post(_makeApiUrl(path),
        body: body, appendAuthorizationToken: true);
  }

  Future<HttpieResponse> getPostsForHashtagWithName(String hashtagName,
      {int? maxId, int? count, bool authenticatedRequest = true}) {
    Map<String, dynamic> queryParams = {};

    if (count != null) queryParams['count'] = count;

    if (maxId != null) queryParams['max_id'] = maxId;

    String url = _makeGetHashtagPostsPath(hashtagName);

    return _httpService.get(_makeApiUrl(url),
        queryParameters: queryParams,
        appendAuthorizationToken: authenticatedRequest);
  }

  String _makeReportHashtagPath(String hashtagName) {
    return _stringTemplateService
        .parse(REPORT_HASHTAG_PATH, {'hashtagName': hashtagName});
  }

  String _makeGetHashtagPath(String hashtagName) {
    return _stringTemplateService
        .parse(GET_HASHTAG_PATH, {'hashtagName': hashtagName});
  }

  String _makeGetHashtagPostsPath(String hashtagName) {
    return _stringTemplateService
        .parse(GET_HASHTAG_POSTS_PATH, {'hashtagName': hashtagName});
  }


  String _makeApiUrl(String string) {
    return '$apiURL$string';
  }
}
