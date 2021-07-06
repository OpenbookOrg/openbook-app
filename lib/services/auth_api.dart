import 'dart:io';

import 'package:Okuna/models/language.dart';
import 'package:Okuna/services/httpie.dart';
import 'package:Okuna/services/string_template.dart';
import 'package:meta/meta.dart';

class AuthApiService {
  late HttpieService _httpService;
  late StringTemplateService _stringTemplateService;

  late String apiURL;

  static const CHECK_USERNAME_PATH = 'api/auth/username-check/';
  static const CHECK_EMAIL_PATH = 'api/auth/email-check/';
  static const UPDATE_EMAIL_PATH = 'api/auth/user/settings/';
  static const VERIFY_EMAIL_TOKEN = 'api/auth/email/verify/';
  static const ACCEPT_GUIDELINES = 'api/auth/user/accept-guidelines/';
  static const SET_NEW_LANGUAGE = 'api/auth/user/languages/';
  static const GET_NEW_LANGUAGE = 'api/auth/user/languages/';
  static const UPDATE_PASSWORD_PATH = 'api/auth/user/settings/';
  static const CREATE_ACCOUNT_PATH = 'api/auth/register/';
  static const VERIFY_REGISTER_TOKEN = 'api/auth/register/verify-token/';
  static const DELETE_ACCOUNT_PATH = 'api/auth/user/delete/';
  static const GET_AUTHENTICATED_USER_PATH = 'api/auth/user/';
  static const UPDATE_AUTHENTICATED_USER_PATH = 'api/auth/user/';
  static const GET_USERS_PATH = 'api/auth/users/';
  static const REPORT_USER_PATH = 'api/auth/users/{userUsername}/report/';
  static const GET_LINKED_USERS_PATH = 'api/auth/linked-users/';
  static const SEARCH_LINKED_USERS_PATH = 'api/auth/linked-users/search/';
  static const GET_BLOCKED_USERS_PATH = 'api/auth/blocked-users/';
  static const SEARCH_BLOCKED_USERS_PATH = 'api/auth/blocked-users/search/';
  static const ENABLE_NEW_POST_NOTIFICATIONS_FOR_USER_PATH = 'api/auth/users/{userUsername}/notifications/subscribe/new-post/';
  static const BLOCK_USER_PATH = 'api/auth/users/{userUsername}/block/';
  static const UNBLOCK_USER_PATH = 'api/auth/users/{userUsername}/unblock/';
  static const GET_FOLLOWERS_PATH = 'api/auth/followers/';
  static const SEARCH_FOLLOWERS_PATH = 'api/auth/followers/search/';
  static const GET_FOLLOWINGS_PATH = 'api/auth/followings/';
  static const SEARCH_FOLLOWINGS_PATH = 'api/auth/followings/search/';
  static const LOGIN_PATH = 'api/auth/login/';
  static const REQUEST_RESET_PASSWORD_PATH = 'api/auth/password/reset/';
  static const VERIFY_RESET_PASSWORD_PATH = 'api/auth/password/verify/';
  static const AUTHENTICATED_USER_NOTIFICATIONS_SETTINGS_PATH =
      'api/auth/user/notifications-settings/';

  void setHttpService(HttpieService httpService) {
    _httpService = httpService;
  }

  void setStringTemplateService(StringTemplateService stringTemplateService) {
    _stringTemplateService = stringTemplateService;
  }

  void setApiURL(String newApiURL) {
    apiURL = newApiURL;
  }

  Future<HttpieResponse> deleteUser({required String password}) {
    Map<String, dynamic> body = {'password': password};
    return _httpService.post('$apiURL$DELETE_ACCOUNT_PATH',
        body: body, appendAuthorizationToken: true);
  }

  Future<HttpieResponse> checkUsernameIsAvailable({required String username}) {
    return _httpService
        .postJSON('$apiURL$CHECK_USERNAME_PATH', body: {'username': username});
  }

  Future<HttpieResponse> checkEmailIsAvailable({required String email}) {
    return _httpService
        .postJSON('$apiURL$CHECK_EMAIL_PATH', body: {'email': email});
  }

  Future<HttpieStreamedResponse> updateUserEmail({required String email}) {
    Map<String, dynamic> body = {};
    body['email'] = email;
    return _httpService.patchMultiform('$apiURL$UPDATE_EMAIL_PATH',
        body: body, appendAuthorizationToken: true);
  }

  Future<HttpieStreamedResponse> updateUserPassword(
      {required String currentPassword, required String newPassword}) {
    Map<String, dynamic> body = {};
    body['current_password'] = currentPassword;
    body['new_password'] = newPassword;
    return _httpService.patchMultiform('$apiURL$UPDATE_PASSWORD_PATH',
        body: body, appendAuthorizationToken: true);
  }

  Future<HttpieResponse> verifyEmailWithToken(String token) {
    Map<String, dynamic> body = {'token': token};
    return _httpService.postJSON('$apiURL$VERIFY_EMAIL_TOKEN',
        body: body, appendAuthorizationToken: true);
  }

  Future<HttpieStreamedResponse> updateUser({
    dynamic avatar,
    dynamic cover,
    String? name,
    String? username,
    String? url,
    bool? followersCountVisible,
    bool? communityPostsVisible,
    String? bio,
    String? location,
    String? visibility,
  }) {
    Map<String, dynamic> body = {};

    if (avatar is File) {
      body['avatar'] = avatar;
    } else if (avatar is String && avatar.isEmpty) {
      // This is what deletes the avatar. Ugly af.
      body['avatar'] = avatar;
    }

    if (cover is File) {
      body['cover'] = cover;
    } else if (cover is String && cover.isEmpty) {
      // This is what deletes the cover. Ugly af.
      body['cover'] = cover;
    }

    if (name != null) body['name'] = name;

    if (username != null) body['username'] = username;

    if (url != null) body['url'] = url;

    if (bio != null) body['bio'] = bio;

    if (visibility != null) body['visibility'] = visibility;

    if (followersCountVisible != null)
      body['followers_count_visible'] = followersCountVisible;

    if (communityPostsVisible != null)
      body['community_posts_visible'] = communityPostsVisible;

    if (location != null) body['location'] = location;

    return _httpService.patchMultiform('$apiURL$UPDATE_AUTHENTICATED_USER_PATH',
        body: body, appendAuthorizationToken: true);
  }

  Future<HttpieStreamedResponse> createUser(
      {required String email,
      required String token,
      required String name,
      required String username,
      required bool isOfLegalAge,
      required bool areGuidelinesAccepted,
      required String password,
      File? avatar}) {
    Map<String, dynamic> body = {
      'email': email,
      'token': token,
      'name': name,
      'username': username,
      'is_of_legal_age': isOfLegalAge,
      'are_guidelines_accepted': areGuidelinesAccepted,
      'password': password
    };

    if (avatar != null) {
      body['avatar'] = avatar;
    }

    return _httpService.postMultiform('$apiURL$CREATE_ACCOUNT_PATH',
        body: body);
  }

  Future<HttpieResponse> verifyRegisterToken(
      {required String token}) {
    Map<String, dynamic> body = {'token': token};

    return _httpService.post('$apiURL$VERIFY_REGISTER_TOKEN',
        body: body);
  }

  Future<HttpieResponse> getUserWithAuthToken(String authToken) {
    Map<String, String> headers = {'Authorization': 'Token $authToken'};

    return _httpService.get('$apiURL$GET_AUTHENTICATED_USER_PATH',
        headers: headers);
  }

  Future<HttpieResponse> getUserWithUsername(String username,
      {bool authenticatedRequest = true}) {
    return _httpService.get('$apiURL$GET_USERS_PATH$username/',
        appendAuthorizationToken: authenticatedRequest);
  }

  Future<HttpieResponse> getPostsCountForUserWithName(String username,
      {bool authenticatedRequest = true}) {
    return _httpService.get('$apiURL$GET_USERS_PATH$username/posts/count/',
        appendAuthorizationToken: authenticatedRequest);
  }

  Future<HttpieResponse> getUsersWithQuery(String query,
      {bool authenticatedRequest = true}) {
    return _httpService.get('$apiURL$GET_USERS_PATH',
        queryParameters: {'query': query},
        appendAuthorizationToken: authenticatedRequest);
  }

  Future<HttpieResponse> searchLinkedUsers(
      {required String query, int? count, String? withCommunity}) {
    Map<String, dynamic> queryParams = {'query': query};

    if (count != null) queryParams['count'] = count;

    if (withCommunity != null) queryParams['with_community'] = withCommunity;

    return _httpService.get('$apiURL$SEARCH_LINKED_USERS_PATH',
        queryParameters: queryParams, appendAuthorizationToken: true);
  }

  Future<HttpieResponse> getLinkedUsers(
      {bool authenticatedRequest = true,
      int? maxId,
      int? count,
      String? withCommunity}) {
    Map<String, dynamic> queryParams = {};

    if (count != null) queryParams['count'] = count;

    if (maxId != null) queryParams['max_id'] = maxId;

    if (withCommunity != null) queryParams['with_community'] = withCommunity;

    return _httpService.get('$apiURL$GET_LINKED_USERS_PATH',
        queryParameters: queryParams,
        appendAuthorizationToken: authenticatedRequest);
  }

  Future<HttpieResponse> searchBlockedUsers(
      {required String query, int? count}) {
    Map<String, dynamic> queryParams = {'query': query};

    if (count != null) queryParams['count'] = count;

    return _httpService.get('$apiURL$SEARCH_BLOCKED_USERS_PATH',
        queryParameters: queryParams, appendAuthorizationToken: true);
  }

  Future<HttpieResponse> getBlockedUsers({
    bool authenticatedRequest = true,
    int? maxId,
    int? count,
  }) {
    Map<String, dynamic> queryParams = {};

    if (count != null) queryParams['count'] = count;

    if (maxId != null) queryParams['max_id'] = maxId;

    return _httpService.get('$apiURL$GET_BLOCKED_USERS_PATH',
        queryParameters: queryParams,
        appendAuthorizationToken: authenticatedRequest);
  }

  Future<HttpieResponse> blockUserWithUsername(String userUsername) {
    String path = _makeBlockUserWithUsernamePath(userUsername);
    return _httpService.post(_makeApiUrl(path), appendAuthorizationToken: true);
  }

  Future<HttpieResponse> unblockUserWithUsername(String userUsername) {
    String path = _makeUnblockUserWithUsernamePath(userUsername);
    return _httpService.post(_makeApiUrl(path), appendAuthorizationToken: true);
  }

  Future<HttpieResponse> enableNewPostNotificationsForUserWithUsername(String userUsername) {
    String path = _makeEnableNewPostNotificationsForUserWithUsernamePath(userUsername);
    return _httpService.putJSON(_makeApiUrl(path), appendAuthorizationToken: true);
  }

  Future<HttpieResponse> disableNewPostNotificationsForUserWithUsername(String userUsername) {
    String path = _makeEnableNewPostNotificationsForUserWithUsernamePath(userUsername);
    return _httpService.delete(_makeApiUrl(path), appendAuthorizationToken: true);
  }

  Future<HttpieResponse> searchFollowers({required String query, int? count}) {
    Map<String, dynamic> queryParams = {'query': query};

    if (count != null) queryParams['count'] = count;

    return _httpService.get('$apiURL$SEARCH_FOLLOWERS_PATH',
        queryParameters: queryParams, appendAuthorizationToken: true);
  }

  Future<HttpieResponse> getFollowers(
      {bool authenticatedRequest = true, int? maxId, int? count}) {
    Map<String, dynamic> queryParams = {};

    if (count != null) queryParams['count'] = count;

    if (maxId != null) queryParams['max_id'] = maxId;

    return _httpService.get('$apiURL$GET_FOLLOWERS_PATH',
        queryParameters: queryParams,
        appendAuthorizationToken: authenticatedRequest);
  }

  Future<HttpieResponse> searchFollowings({required String query, int? count}) {
    Map<String, dynamic> queryParams = {'query': query};

    if (count != null) queryParams['count'] = count;

    return _httpService.get('$apiURL$SEARCH_FOLLOWINGS_PATH',
        queryParameters: queryParams, appendAuthorizationToken: true);
  }

  Future<HttpieResponse> getFollowings({
    bool authenticatedRequest = true,
    int? maxId,
    int? count,
  }) {
    Map<String, dynamic> queryParams = {};

    if (count != null) queryParams['count'] = count;

    if (maxId != null) queryParams['max_id'] = maxId;

    return _httpService.get('$apiURL$GET_FOLLOWINGS_PATH',
        queryParameters: queryParams,
        appendAuthorizationToken: authenticatedRequest);
  }

  Future<HttpieResponse> loginWithCredentials(
      {required String username, required String password}) {

    return this._httpService.postJSON('$apiURL$LOGIN_PATH',
        body: {'username': username, 'password': password});
  }

  Future<HttpieResponse> requestPasswordReset({required String email}) {
    var body = {};
    if (email != null && email != '') {
      body['email'] = email;
    }
    return this
        ._httpService
        .postJSON('$apiURL$REQUEST_RESET_PASSWORD_PATH', body: body);
  }

  Future<HttpieResponse> verifyPasswordReset(
      {String? newPassword, String? passwordResetToken}) {
    return this._httpService.postJSON('$apiURL$VERIFY_RESET_PASSWORD_PATH',
        body: {'new_password': newPassword, 'token': passwordResetToken});
  }

  Future<HttpieResponse> getAuthenticatedUserNotificationsSettings() {
    return this._httpService.get(
        '$apiURL$AUTHENTICATED_USER_NOTIFICATIONS_SETTINGS_PATH',
        appendAuthorizationToken: true);
  }

  Future<HttpieResponse> updateAuthenticatedUserNotificationsSettings({
    bool? postCommentNotifications,
    bool? postCommentReplyNotifications,
    bool? postCommentReactionNotifications,
    bool? postCommentUserMentionNotifications,
    bool? postUserMentionNotifications,
    bool? postReactionNotifications,
    bool? followNotifications,
    bool? followRequestNotifications,
    bool? followRequestApprovedNotifications,
    bool? connectionRequestNotifications,
    bool? connectionConfirmedNotifications,
    bool? communityInviteNotifications,
    bool? communityNewPostNotifications,
    bool? userNewPostNotifications,
  }) {
    Map<String, dynamic> body = {};

    if (postCommentNotifications != null)
      body['post_comment_notifications'] = postCommentNotifications;

    if (postCommentReplyNotifications != null)
      body['post_comment_reply_notifications'] = postCommentReplyNotifications;

    if (postCommentUserMentionNotifications != null)
      body['post_comment_user_mention_notifications'] =
          postCommentUserMentionNotifications;

    if (postUserMentionNotifications != null)
      body['post_user_mention_notifications'] = postUserMentionNotifications;

    if (postCommentReactionNotifications != null)
      body['post_comment_reaction_notifications'] =
          postCommentReactionNotifications;

    if (postReactionNotifications != null)
      body['post_reaction_notifications'] = postReactionNotifications;

    if (followNotifications != null)
      body['follow_notifications'] = followNotifications;

    if (followRequestNotifications != null)
      body['follow_request_notifications'] = followRequestNotifications;

    if (followRequestApprovedNotifications != null)
      body['follow_request_approved_notifications'] = followRequestApprovedNotifications;

    if (connectionRequestNotifications != null)
      body['connection_request_notifications'] = connectionRequestNotifications;

    if (communityInviteNotifications != null)
      body['community_invite_notifications'] = communityInviteNotifications;

    if (communityNewPostNotifications != null)
      body['community_new_post_notifications'] = communityNewPostNotifications;

    if (userNewPostNotifications != null)
      body['user_new_post_notifications'] = userNewPostNotifications;

    if (connectionConfirmedNotifications != null)
      body['connection_confirmed_notifications'] =
          connectionConfirmedNotifications;

    return _httpService.patchJSON(
        '$apiURL$AUTHENTICATED_USER_NOTIFICATIONS_SETTINGS_PATH',
        body: body,
        appendAuthorizationToken: true);
  }

  Future<HttpieResponse> acceptGuidelines() {
    return this
        ._httpService
        .post('$apiURL$ACCEPT_GUIDELINES', appendAuthorizationToken: true);
  }

  Future<HttpieResponse> getAllLanguages() {
    String url = _makeApiUrl(GET_NEW_LANGUAGE);
    return _httpService.get(url, appendAuthorizationToken: true);
  }

  Future<HttpieResponse> setNewLanguage(Language language) {
    Map<String, String> body = {'language_id': language.id.toString()};
    return this._httpService.post('$apiURL$SET_NEW_LANGUAGE',
        body: body, appendAuthorizationToken: true);
  }

  Future<HttpieResponse> reportUserWithUsername(
      {required String userUsername,
      required int moderationCategoryId,
      String? description}) {
    String path = _makeReportUserPath(username: userUsername);

    Map<String, String> body = {'category_id': moderationCategoryId.toString()};

    if (description != null && description.isNotEmpty) {
      body['description'] = description;
    }

    return _httpService.post(_makeApiUrl(path),
        body: body, appendAuthorizationToken: true);
  }

  String _makeBlockUserWithUsernamePath(String username) {
    return _stringTemplateService
        .parse(BLOCK_USER_PATH, {'userUsername': username});
  }

  String _makeUnblockUserWithUsernamePath(String username) {
    return _stringTemplateService
        .parse(UNBLOCK_USER_PATH, {'userUsername': username});
  }

  String _makeEnableNewPostNotificationsForUserWithUsernamePath(String username) {
    return _stringTemplateService
        .parse(ENABLE_NEW_POST_NOTIFICATIONS_FOR_USER_PATH, {'userUsername': username});
  }

  String _makeReportUserPath({required username}) {
    return _stringTemplateService
        .parse(REPORT_USER_PATH, {'userUsername': username});
  }

  String _makeApiUrl(String string) {
    return '$apiURL$string';
  }
}
