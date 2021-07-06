import 'package:Okuna/services/httpie.dart';

class FollowsApiService {
  late HttpieService _httpService;

  late String apiURL;

  static const FOLLOW_USER_PATH = 'api/follows/follow/';
  static const REQUEST_TO_FOLLOW_USER_PATH = 'api/follows/requests/';
  static const CANCEL_REQUEST_TO_FOLLOW_USER_PATH =
      'api/follows/requests/cancel/';
  static const APPROVE_USER_FOLLOW_REQUEST_PATH =
      'api/follows/requests/approve/';
  static const REJECT_USER_FOLLOW_REQUEST_PATH = 'api/follows/requests/reject/';
  static const RECEIVED_FOLLOW_REQUESTS_PATH = 'api/follows/requests/received/';
  static const UNFOLLOW_USER_PATH = 'api/follows/unfollow/';
  static const UPDATE_FOLLOW_PATH = 'api/follows/update/';

  void setHttpService(HttpieService httpService) {
    _httpService = httpService;
  }

  void setApiURL(String newApiURL) {
    apiURL = newApiURL;
  }

  Future<HttpieResponse> requestToFollowUserWithUsername(String username) {
    Map<String, dynamic> body = {'username': username};

    return _httpService.putJSON('$apiURL$REQUEST_TO_FOLLOW_USER_PATH',
        body: body, appendAuthorizationToken: true);
  }

  Future<HttpieResponse> cancelRequestToFollowUserWithUsername(
      String username) {
    return _httpService.postJSON('$apiURL$CANCEL_REQUEST_TO_FOLLOW_USER_PATH',
        body: {'username': username}, appendAuthorizationToken: true);
  }

  Future<HttpieResponse> approveFollowRequestFromUserWithUsername(
      String username) {
    Map<String, dynamic> body = {'username': username};

    return _httpService.postJSON('$apiURL$APPROVE_USER_FOLLOW_REQUEST_PATH',
        body: body, appendAuthorizationToken: true);
  }

  Future<HttpieResponse> rejectFollowRequestFromUserWithUsername(
      String username) {
    Map<String, dynamic> body = {'username': username};

    return _httpService.postJSON('$apiURL$REJECT_USER_FOLLOW_REQUEST_PATH',
        body: body, appendAuthorizationToken: true);
  }

  Future<HttpieResponse> getReceivedFollowRequests( {
    int? maxId,
    int? count,}) {

    Map<String, dynamic> queryParams = {};

    if (count != null) queryParams['count'] = count;

    if (maxId != null) queryParams['max_id'] = maxId;

    return _httpService.get('$apiURL$RECEIVED_FOLLOW_REQUESTS_PATH',
        queryParameters: queryParams,
        appendAuthorizationToken: true);
  }

  Future<HttpieResponse> followUserWithUsername(String username,
      {List<int>? listsIds}) {
    Map<String, dynamic> body = {'username': username};

    if (listsIds != null) body['lists_ids'] = listsIds;

    return _httpService.postJSON('$apiURL$FOLLOW_USER_PATH',
        body: body, appendAuthorizationToken: true);
  }

  Future<HttpieResponse> unFollowUserWithUsername(String username) {
    return _httpService.postJSON('$apiURL$UNFOLLOW_USER_PATH',
        body: {'username': username}, appendAuthorizationToken: true);
  }

  Future<HttpieResponse> updateFollowWithUsername(String username,
      {List<int>? listsIds}) {
    Map<String, dynamic> body = {'username': username};

    if (listsIds != null) body['lists_ids'] = listsIds;

    return _httpService.postJSON('$apiURL$UPDATE_FOLLOW_PATH',
        body: body, appendAuthorizationToken: true);
  }
}
