import 'dart:io';

import 'package:Okuna/services/httpie.dart';
import 'package:Okuna/services/string_template.dart';
import 'package:meta/meta.dart';

class CommunitiesApiService {
  late HttpieService _httpService;
  late StringTemplateService _stringTemplateService;

  late String apiURL;

  static const SEARCH_COMMUNITIES_PATH = 'api/communities/search/';
  static const GET_TRENDING_COMMUNITIES_PATH = 'api/communities/trending/';
  static const GET_SUGGESTED_COMMUNITIES_PATH = 'api/communities/suggested/';
  static const GET_JOINED_COMMUNITIES_PATH = 'api/communities/joined/';
  static const SEARCH_JOINED_COMMUNITIES_PATH =
      'api/communities/joined/search/';
  static const CHECK_COMMUNITY_NAME_PATH = 'api/communities/name-check/';
  static const CREATE_COMMUNITY_PATH = 'api/communities/';
  static const DELETE_COMMUNITY_PATH = 'api/communities/{communityName}/';
  static const UPDATE_COMMUNITY_PATH = 'api/communities/{communityName}/';
  static const GET_COMMUNITY_PATH = 'api/communities/{communityName}/';
  static const REPORT_COMMUNITY_PATH =
      'api/communities/{communityName}/report/';
  static const JOIN_COMMUNITY_PATH =
      'api/communities/{communityName}/members/join/';
  static const LEAVE_COMMUNITY_PATH =
      'api/communities/{communityName}/members/leave/';
  static const INVITE_USER_TO_COMMUNITY_PATH =
      'api/communities/{communityName}/members/invite/';
  static const UNINVITE_USER_TO_COMMUNITY_PATH =
      'api/communities/{communityName}/members/uninvite/';
  static const BAN_COMMUNITY_USER_PATH =
      'api/communities/{communityName}/banned-users/ban/';
  static const UNBAN_COMMUNITY_USER_PATH =
      'api/communities/{communityName}/banned-users/unban/';
  static const SEARCH_COMMUNITY_BANNED_USERS_PATH =
      'api/communities/{communityName}/banned-users/search/';
  static const COMMUNITY_AVATAR_PATH =
      'api/communities/{communityName}/avatar/';
  static const COMMUNITY_COVER_PATH = 'api/communities/{communityName}/cover/';
  static const SEARCH_COMMUNITY_PATH =
      'api/communities/{communityName}/search/';
  static const FAVORITE_COMMUNITY_PATH =
      'api/communities/{communityName}/favorite/';
  static const ENABLE_NEW_POST_NOTIFICATIONS_FOR_COMMUNITY_PATH =
      'api/communities/{communityName}/notifications/subscribe/new-post/';
  static const GET_FAVORITE_COMMUNITIES_PATH = 'api/communities/favorites/';
  static const SEARCH_FAVORITE_COMMUNITIES_PATH =
      'api/communities/favorites/search/';
  static const GET_ADMINISTRATED_COMMUNITIES_PATH =
      'api/communities/administrated/';
  static const SEARCH_ADMINISTRATED_COMMUNITIES_PATH =
      'api/communities/administrated/search/';
  static const GET_MODERATED_COMMUNITIES_PATH = 'api/communities/moderated/';
  static const SEARCH_MODERATED_COMMUNITIES_PATH =
      'api/communities/moderated/search/';
  static const GET_COMMUNITY_POSTS_PATH =
      'api/communities/{communityName}/posts/';
  static const COUNT_COMMUNITY_POSTS_PATH =
      'api/communities/{communityName}/posts/count/';
  static const CREATE_COMMUNITY_POST_PATH =
      'api/communities/{communityName}/posts/';
  static const CLOSED_COMMUNITY_POSTS_PATH =
      'api/communities/{communityName}/posts/closed/';
  static const GET_COMMUNITY_MEMBERS_PATH =
      'api/communities/{communityName}/members/';
  static const SEARCH_COMMUNITY_MEMBERS_PATH =
      'api/communities/{communityName}/members/search/';
  static const GET_COMMUNITY_BANNED_USERS_PATH =
      'api/communities/{communityName}/banned-users/';
  static const GET_COMMUNITY_ADMINISTRATORS_PATH =
      'api/communities/{communityName}/administrators/';
  static const SEARCH_COMMUNITY_ADMINISTRATORS_PATH =
      'api/communities/{communityName}/administrators/search/';
  static const ADD_COMMUNITY_ADMINISTRATOR_PATH =
      'api/communities/{communityName}/administrators/';
  static const REMOVE_COMMUNITY_ADMINISTRATORS_PATH =
      'api/communities/{communityName}/administrators/{username}/';
  static const GET_COMMUNITY_MODERATORS_PATH =
      'api/communities/{communityName}/moderators/';
  static const SEARCH_COMMUNITY_MODERATORS_PATH =
      'api/communities/{communityName}/moderators/search/';
  static const ADD_COMMUNITY_MODERATOR_PATH =
      'api/communities/{communityName}/moderators/';
  static const REMOVE_COMMUNITY_MODERATORS_PATH =
      'api/communities/{communityName}/moderators/{username}/';
  static const CREATE_COMMUNITY_POSTS_PATH =
      'api/communities/{communityName}/posts/';
  static const GET_COMMUNITY_MODERATED_OBJECTS_PATH =
      'api/communities/{communityName}/moderated-objects/';

  void setHttpieService(HttpieService httpService) {
    _httpService = httpService;
  }

  void setStringTemplateService(StringTemplateService stringTemplateService) {
    _stringTemplateService = stringTemplateService;
  }

  void setApiURL(String newApiURL) {
    apiURL = newApiURL;
  }

  Future<HttpieResponse> checkNameIsAvailable({required String name}) {
    return _httpService.postJSON('$apiURL$CHECK_COMMUNITY_NAME_PATH',
        body: {'name': name}, appendAuthorizationToken: true);
  }

  Future<HttpieResponse> getTrendingCommunities(
      {bool authenticatedRequest = true, String? category}) {
    Map<String, dynamic> queryParams = {};

    if (category != null) queryParams['category'] = category;

    return _httpService.get('$apiURL$GET_TRENDING_COMMUNITIES_PATH',
        queryParameters: queryParams,
        appendAuthorizationToken: authenticatedRequest);
  }

  Future<HttpieResponse> getSuggestedCommunities(
      {bool authenticatedRequest = true}) {
    return _httpService.get('$apiURL$GET_SUGGESTED_COMMUNITIES_PATH',
        appendAuthorizationToken: authenticatedRequest);
  }

  Future<HttpieStreamedResponse> createPostForCommunityWithId(
      String communityName,
      {String? text,
      File? image,
      File? video,
      bool isDraft = false}) {
    Map<String, dynamic> body = {};

    if (image != null) {
      body['image'] = image;
    }

    if (video != null) {
      body['video'] = video;
    }

    if (isDraft != null) {
      body['is_draft'] = isDraft;
    }

    if (text != null && text.length > 0) {
      body['text'] = text;
    }

    String url = _makeCreateCommunityPost(communityName);

    return _httpService.putMultiform(_makeApiUrl(url),
        body: body, appendAuthorizationToken: true);
  }

  Future<HttpieResponse> getPostsForCommunityWithName(String communityName,
      {int? maxId, int? count, bool authenticatedRequest = true}) {
    Map<String, dynamic> queryParams = {};

    if (count != null) queryParams['count'] = count;

    if (maxId != null) queryParams['max_id'] = maxId;

    String url = _makeGetCommunityPostsPath(communityName);

    return _httpService.get(_makeApiUrl(url),
        queryParameters: queryParams,
        appendAuthorizationToken: authenticatedRequest);
  }

  Future<HttpieResponse> getPostsCountForCommunityWithName(String communityName,
      {bool authenticatedRequest = true}) {
    String url = _makeGetPostsCountForCommunityWithNamePath(communityName);

    return _httpService.get(_makeApiUrl(url),
        appendAuthorizationToken: authenticatedRequest);
  }

  Future<HttpieResponse> getClosedPostsForCommunityWithName(
      String communityName,
      {int? maxId,
      int? count,
      bool authenticatedRequest = true}) {
    Map<String, dynamic> queryParams = {};

    if (count != null) queryParams['count'] = count;

    if (maxId != null) queryParams['max_id'] = maxId;

    String url = _makeClosedCommunityPostsPath(communityName);

    return _httpService.get(_makeApiUrl(url),
        queryParameters: queryParams,
        appendAuthorizationToken: authenticatedRequest);
  }

  Future<HttpieResponse> searchCommunitiesWithQuery(
      {bool authenticatedRequest = true,
      required String query,
      bool? excludedFromProfilePosts}) {
    Map<String, dynamic> queryParams = {'query': query};

    if (excludedFromProfilePosts != null)
      queryParams['excluded_from_profile_posts'] = excludedFromProfilePosts;

    return _httpService.get('$apiURL$SEARCH_COMMUNITIES_PATH',
        queryParameters: queryParams,
        appendAuthorizationToken: authenticatedRequest);
  }

  Future<HttpieResponse> getCommunityWithName(String name,
      {bool authenticatedRequest = true}) {
    String url = _makeGetCommunityPath(name);
    return _httpService.get(_makeApiUrl(url),
        appendAuthorizationToken: authenticatedRequest,
        headers: {'Accept': 'application/json; version=1.0'});
  }

  Future<HttpieStreamedResponse> createCommunity(
      {required String name,
      required String title,
      required List<String> categories,
      required String type,
      bool? invitesEnabled,
      String? color,
      String? userAdjective,
      String? usersAdjective,
      String? description,
      String? rules,
      File? cover,
      File? avatar}) {
    Map<String, dynamic> body = {
      'name': name,
      'title': title,
      'categories': categories,
      'type': type
    };

    if (avatar != null) {
      body['avatar'] = avatar;
    }

    if (cover != null) {
      body['cover'] = cover;
    }

    if (color != null) {
      body['color'] = color;
    }

    if (rules != null) {
      body['rules'] = rules;
    }

    if (description != null) {
      body['description'] = description;
    }

    if (userAdjective != null && userAdjective.isNotEmpty) {
      body['user_adjective'] = userAdjective;
    }

    if (usersAdjective != null && usersAdjective.isNotEmpty) {
      body['users_adjective'] = usersAdjective;
    }

    if (invitesEnabled != null) {
      body['invites_enabled'] = invitesEnabled;
    }

    return _httpService.putMultiform(_makeApiUrl(CREATE_COMMUNITY_PATH),
        body: body, appendAuthorizationToken: true);
  }

  Future<HttpieStreamedResponse> updateCommunityWithName(String communityName,
      {String? name,
      String? title,
      List<String>? categories,
      bool? invitesEnabled,
      String? type,
      String? color,
      String? userAdjective,
      String? usersAdjective,
      String? description,
      String? rules}) {
    Map<String, dynamic> body = {};

    if (name != null) {
      body['name'] = name;
    }

    if (title != null) {
      body['title'] = title;
    }

    if (categories != null) {
      body['categories'] = categories;
    }

    if (type != null) {
      body['type'] = type;
    }

    if (invitesEnabled != null) {
      body['invites_enabled'] = invitesEnabled;
    }

    if (color != null) {
      body['color'] = color;
    }

    if (rules != null) {
      body['rules'] = rules;
    }

    if (description != null) {
      body['description'] = description;
    }

    if (userAdjective != null && userAdjective.isNotEmpty) {
      body['user_adjective'] = userAdjective;
    }

    if (usersAdjective != null && usersAdjective.isNotEmpty) {
      body['users_adjective'] = usersAdjective;
    }

    return _httpService.patchMultiform(
        _makeApiUrl(_makeUpdateCommunityPath(communityName)),
        body: body,
        appendAuthorizationToken: true);
  }

  Future<HttpieStreamedResponse> updateAvatarForCommunityWithName(
      String communityName,
      {File? avatar}) {
    Map<String, dynamic> body = {'avatar': avatar};

    return _httpService.putMultiform(
        _makeApiUrl(_makeCommunityAvatarPath(communityName)),
        body: body,
        appendAuthorizationToken: true);
  }

  Future<HttpieResponse> deleteAvatarForCommunityWithName(
      String communityName) {
    return _httpService.delete(
        _makeApiUrl(_makeCommunityAvatarPath(communityName)),
        appendAuthorizationToken: true);
  }

  Future<HttpieStreamedResponse> updateCoverForCommunityWithName(
      String communityName,
      {File? cover}) {
    Map<String, dynamic> body = {'cover': cover};

    return _httpService.putMultiform(
        _makeApiUrl(_makeCommunityCoverPath(communityName)),
        body: body,
        appendAuthorizationToken: true);
  }

  Future<HttpieResponse> deleteCoverForCommunityWithName(String communityName) {
    return _httpService.delete(
        _makeApiUrl(_makeCommunityCoverPath(communityName)),
        appendAuthorizationToken: true);
  }

  Future<HttpieResponse> deleteCommunityWithName(String communityName) {
    String path = _makeDeleteCommunityPath(communityName);

    return _httpService.delete(_makeApiUrl(path),
        appendAuthorizationToken: true);
  }

  Future<HttpieResponse> getMembersForCommunityWithId(String communityName,
      {int? count, int? maxId, List<String>? exclude}) {
    Map<String, dynamic> queryParams = {};
    if (count != null) queryParams['count'] = count;

    if (maxId != null) queryParams['max_id'] = maxId;

    if (exclude != null && exclude.isNotEmpty) queryParams['exclude'] = exclude;

    String path = _makeGetCommunityMembersPath(communityName);

    return _httpService.get(_makeApiUrl(path),
        queryParameters: queryParams, appendAuthorizationToken: true);
  }

  Future<HttpieResponse> searchMembers(
      {required String communityName,
      required String query,
      List<String>? exclude}) {
    Map<String, dynamic> queryParams = {'query': query};

    if (exclude != null && exclude.isNotEmpty) queryParams['exclude'] = exclude;

    String path = _makeSearchCommunityMembersPath(communityName);

    return _httpService.get(_makeApiUrl(path),
        queryParameters: queryParams, appendAuthorizationToken: true);
  }

  Future<HttpieResponse> inviteUserToCommunity(
      {required String communityName, required String username}) {
    Map<String, dynamic> body = {'username': username};
    String path = _makeInviteUserToCommunityPath(communityName);
    return _httpService.post(_makeApiUrl(path),
        body: body, appendAuthorizationToken: true);
  }

  Future<HttpieResponse> uninviteUserFromCommunity(
      {required String communityName, required String username}) {
    Map<String, dynamic> body = {'username': username};
    String path = _makeUninviteUserToCommunityPath(communityName);
    return _httpService.post(_makeApiUrl(path),
        body: body, appendAuthorizationToken: true);
  }

  Future<HttpieResponse> getJoinedCommunities(
      {bool authenticatedRequest = true,
      int? offset,
      bool? excludedFromProfilePosts}) {
    Map<String, dynamic> queryParams = {'offset': offset};

    if (excludedFromProfilePosts != null)
      queryParams['excluded_from_profile_posts'] = excludedFromProfilePosts;

    return _httpService.get('$apiURL$GET_JOINED_COMMUNITIES_PATH',
        appendAuthorizationToken: authenticatedRequest,
        queryParameters: queryParams);
  }

  Future<HttpieResponse> searchJoinedCommunities({
    required String query,
    int? count,
  }) {
    Map<String, dynamic> queryParams = {'query': query};

    if (count != null) queryParams['count'] = count;

    return _httpService.get(_makeApiUrl('$SEARCH_JOINED_COMMUNITIES_PATH'),
        queryParameters: queryParams, appendAuthorizationToken: true);
  }

  Future<HttpieResponse> joinCommunityWithId(String communityName) {
    String path = _makeJoinCommunityPath(communityName);
    return _httpService.post(_makeApiUrl(path), appendAuthorizationToken: true);
  }

  Future<HttpieResponse> leaveCommunityWithId(String communityName) {
    String path = _makeLeaveCommunityPath(communityName);
    return _httpService.post(_makeApiUrl(path), appendAuthorizationToken: true);
  }

  Future<HttpieResponse> getModeratorsForCommunityWithId(String communityName,
      {int? count, int? maxId}) {
    Map<String, dynamic> queryParams = {};
    if (count != null) queryParams['count'] = count;

    if (maxId != null) queryParams['max_id'] = maxId;

    String path = _makeGetCommunityModeratorsPath(communityName);

    return _httpService.get(_makeApiUrl(path),
        queryParameters: queryParams, appendAuthorizationToken: true);
  }

  Future<HttpieResponse> searchModerators({
    required String communityName,
    required String query,
  }) {
    Map<String, dynamic> queryParams = {'query': query};

    String path = _makeSearchCommunityModeratorsPath(communityName);

    return _httpService.get(_makeApiUrl(path),
        queryParameters: queryParams, appendAuthorizationToken: true);
  }

  Future<HttpieResponse> addCommunityModerator(
      {required String communityName, required String username}) {
    Map<String, dynamic> body = {'username': username};

    String path = _makeAddCommunityModeratorPath(communityName);
    return _httpService.putJSON(_makeApiUrl(path),
        body: body, appendAuthorizationToken: true);
  }

  Future<HttpieResponse> removeCommunityModerator(
      {required String communityName, required String username}) {
    String path = _makeRemoveCommunityModeratorPath(communityName, username);
    return _httpService.delete(_makeApiUrl(path),
        appendAuthorizationToken: true);
  }

  Future<HttpieResponse> getAdministratorsForCommunityWithName(
      String communityName,
      {int? count,
      int? maxId}) {
    Map<String, dynamic> queryParams = {};
    if (count != null) queryParams['count'] = count;

    if (maxId != null) queryParams['max_id'] = maxId;

    String path = _makeGetCommunityAdministratorsPath(communityName);

    return _httpService.get(_makeApiUrl(path),
        queryParameters: queryParams, appendAuthorizationToken: true);
  }

  Future<HttpieResponse> searchAdministrators({
    required String communityName,
    required String query,
  }) {
    Map<String, dynamic> queryParams = {'query': query};

    String path = _makeSearchCommunityAdministratorsPath(communityName);

    return _httpService.get(_makeApiUrl(path),
        queryParameters: queryParams, appendAuthorizationToken: true);
  }

  Future<HttpieResponse> addCommunityAdministrator(
      {required String communityName, required String username}) {
    Map<String, dynamic> body = {'username': username};

    String path = _makeAddCommunityAdministratorPath(communityName);
    return _httpService.putJSON(_makeApiUrl(path),
        body: body, appendAuthorizationToken: true);
  }

  Future<HttpieResponse> removeCommunityAdministrator(
      {required String communityName, required String username}) {
    String path =
        _makeRemoveCommunityAdministratorPath(communityName, username);
    return _httpService.delete(_makeApiUrl(path),
        appendAuthorizationToken: true);
  }

  Future<HttpieResponse> getBannedUsersForCommunityWithId(String communityName,
      {int? count, int? maxId}) {
    Map<String, dynamic> queryParams = {};
    if (count != null) queryParams['count'] = count;

    if (maxId != null) queryParams['max_id'] = maxId;

    String path = _makeGetCommunityBannedUsersPath(communityName);

    return _httpService.get(_makeApiUrl(path),
        queryParameters: queryParams, appendAuthorizationToken: true);
  }

  Future<HttpieResponse> searchBannedUsers({
    required String communityName,
    required String query,
  }) {
    Map<String, dynamic> queryParams = {'query': query};

    String path = _makeSearchCommunityBannedUsersPath(communityName);

    return _httpService.get(_makeApiUrl(path),
        queryParameters: queryParams, appendAuthorizationToken: true);
  }

  Future<HttpieResponse> banCommunityUser(
      {required String communityName, required String username}) {
    Map<String, dynamic> body = {'username': username};
    String path = _makeBanCommunityUserPath(communityName);
    return _httpService.postJSON(_makeApiUrl(path),
        body: body, appendAuthorizationToken: true);
  }

  Future<HttpieResponse> unbanCommunityUser(
      {required String communityName, required String username}) {
    Map<String, dynamic> body = {'username': username};
    String path = _makeUnbanCommunityUserPath(communityName);
    return _httpService.post(_makeApiUrl(path),
        body: body, appendAuthorizationToken: true);
  }

  Future<HttpieResponse> getFavoriteCommunities(
      {bool authenticatedRequest = true, int? offset}) {
    return _httpService.get('$apiURL$GET_FAVORITE_COMMUNITIES_PATH',
        appendAuthorizationToken: authenticatedRequest,
        queryParameters: {'offset': offset});
  }

  Future<HttpieResponse> searchFavoriteCommunities(
      {required String query, int? count}) {
    Map<String, dynamic> queryParams = {'query': query};

    if (count != null) queryParams['count'] = count;

    return _httpService.get('$apiURL$SEARCH_FAVORITE_COMMUNITIES_PATH',
        queryParameters: queryParams, appendAuthorizationToken: true);
  }

  Future<HttpieResponse> favoriteCommunity({required String communityName}) {
    String path = _makeFavoriteCommunityPath(communityName);
    return _httpService.putJSON(_makeApiUrl(path),
        appendAuthorizationToken: true);
  }

  Future<HttpieResponse> unfavoriteCommunity({required String communityName}) {
    String path = _makeFavoriteCommunityPath(communityName);
    return _httpService.delete(_makeApiUrl(path),
        appendAuthorizationToken: true);
  }

  Future<HttpieResponse> enableNewPostNotificationsForCommunity(
      {required String communityName}) {
    String path =
        _makeEnableNewPostNotificationsForCommunityPath(communityName);
    return _httpService.putJSON(_makeApiUrl(path),
        appendAuthorizationToken: true);
  }

  Future<HttpieResponse> disableNewPostNotificationsForCommunity(
      {required String communityName}) {
    String path =
        _makeEnableNewPostNotificationsForCommunityPath(communityName);
    return _httpService.delete(_makeApiUrl(path),
        appendAuthorizationToken: true);
  }

  Future<HttpieResponse> getAdministratedCommunities(
      {bool authenticatedRequest = true, int? offset}) {
    return _httpService.get('$apiURL$GET_ADMINISTRATED_COMMUNITIES_PATH',
        appendAuthorizationToken: authenticatedRequest,
        queryParameters: {'offset': offset});
  }

  Future<HttpieResponse> searchAdministratedCommunities(
      {required String query, int? count}) {
    Map<String, dynamic> queryParams = {'query': query};

    if (count != null) queryParams['count'] = count;

    return _httpService.get('$apiURL$SEARCH_ADMINISTRATED_COMMUNITIES_PATH',
        queryParameters: queryParams, appendAuthorizationToken: true);
  }

  Future<HttpieResponse> searchModeratedCommunities(
      {required String query, int? count}) {
    Map<String, dynamic> queryParams = {'query': query};

    if (count != null) queryParams['count'] = count;

    return _httpService.get('$apiURL$SEARCH_MODERATED_COMMUNITIES_PATH',
        queryParameters: queryParams, appendAuthorizationToken: true);
  }

  Future<HttpieResponse> getModeratedCommunities(
      {bool authenticatedRequest = true, int? offset}) {
    return _httpService.get('$apiURL$GET_MODERATED_COMMUNITIES_PATH',
        appendAuthorizationToken: authenticatedRequest,
        queryParameters: {'offset': offset});
  }

  Future<HttpieResponse> reportCommunityWithName(
      {required String communityName,
      required int moderationCategoryId,
      String? description}) {
    String path = _makeReportCommunityPath(communityName);

    Map<String, dynamic> body = {
      'category_id': moderationCategoryId.toString()
    };

    if (description != null && description.isNotEmpty) {
      body['description'] = description;
    }

    return _httpService.post(_makeApiUrl(path),
        body: body, appendAuthorizationToken: true);
  }

  Future<HttpieResponse> getModeratedObjects({
    required String communityName,
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

    String path = _makeGetCommunityModeratedObjectsPath(communityName);

    return _httpService.get(_makeApiUrl(path),
        queryParameters: queryParams, appendAuthorizationToken: true);
  }

  String _makeGetCommunityModeratedObjectsPath(String communityName) {
    return _stringTemplateService.parse(
        GET_COMMUNITY_MODERATED_OBJECTS_PATH, {'communityName': communityName});
  }

  String _makeCreateCommunityPost(String communityName) {
    return _stringTemplateService
        .parse(CREATE_COMMUNITY_POST_PATH, {'communityName': communityName});
  }

  String _makeReportCommunityPath(String communityName) {
    return _stringTemplateService
        .parse(REPORT_COMMUNITY_PATH, {'communityName': communityName});
  }

  String _makeClosedCommunityPostsPath(String communityName) {
    return _stringTemplateService
        .parse(CLOSED_COMMUNITY_POSTS_PATH, {'communityName': communityName});
  }

  String _makeInviteUserToCommunityPath(String communityName) {
    return _stringTemplateService
        .parse(INVITE_USER_TO_COMMUNITY_PATH, {'communityName': communityName});
  }

  String _makeUninviteUserToCommunityPath(String communityName) {
    return _stringTemplateService.parse(
        UNINVITE_USER_TO_COMMUNITY_PATH, {'communityName': communityName});
  }

  String _makeUnbanCommunityUserPath(String communityName) {
    return _stringTemplateService
        .parse(UNBAN_COMMUNITY_USER_PATH, {'communityName': communityName});
  }

  String _makeBanCommunityUserPath(String communityName) {
    return _stringTemplateService
        .parse(BAN_COMMUNITY_USER_PATH, {'communityName': communityName});
  }

  String _makeSearchCommunityBannedUsersPath(String communityName) {
    return _stringTemplateService.parse(
        SEARCH_COMMUNITY_BANNED_USERS_PATH, {'communityName': communityName});
  }

  String _makeDeleteCommunityPath(String communityName) {
    return _stringTemplateService
        .parse(DELETE_COMMUNITY_PATH, {'communityName': communityName});
  }

  String _makeGetCommunityPath(String communityName) {
    return _stringTemplateService
        .parse(GET_COMMUNITY_PATH, {'communityName': communityName});
  }

  String _makeAddCommunityAdministratorPath(String communityName) {
    return _stringTemplateService.parse(
        ADD_COMMUNITY_ADMINISTRATOR_PATH, {'communityName': communityName});
  }

  String _makeRemoveCommunityAdministratorPath(
      String communityName, String username) {
    return _stringTemplateService.parse(REMOVE_COMMUNITY_ADMINISTRATORS_PATH,
        {'communityName': communityName, 'username': username});
  }

  String _makeAddCommunityModeratorPath(String communityName) {
    return _stringTemplateService
        .parse(ADD_COMMUNITY_MODERATOR_PATH, {'communityName': communityName});
  }

  String _makeRemoveCommunityModeratorPath(
      String communityName, String username) {
    return _stringTemplateService.parse(REMOVE_COMMUNITY_MODERATORS_PATH,
        {'communityName': communityName, 'username': username});
  }

  String _makeGetCommunityPostsPath(String communityName) {
    return _stringTemplateService
        .parse(GET_COMMUNITY_POSTS_PATH, {'communityName': communityName});
  }

  String _makeGetPostsCountForCommunityWithNamePath(String communityName) {
    return _stringTemplateService
        .parse(COUNT_COMMUNITY_POSTS_PATH, {'communityName': communityName});
  }

  String _makeFavoriteCommunityPath(String communityName) {
    return _stringTemplateService
        .parse(FAVORITE_COMMUNITY_PATH, {'communityName': communityName});
  }

  String _makeEnableNewPostNotificationsForCommunityPath(String communityName) {
    return _stringTemplateService.parse(
        ENABLE_NEW_POST_NOTIFICATIONS_FOR_COMMUNITY_PATH,
        {'communityName': communityName});
  }

  String _makeJoinCommunityPath(String communityName) {
    return _stringTemplateService
        .parse(JOIN_COMMUNITY_PATH, {'communityName': communityName});
  }

  String _makeLeaveCommunityPath(String communityName) {
    return _stringTemplateService
        .parse(LEAVE_COMMUNITY_PATH, {'communityName': communityName});
  }

  String _makeUpdateCommunityPath(String communityName) {
    return _stringTemplateService
        .parse(UPDATE_COMMUNITY_PATH, {'communityName': communityName});
  }

  String _makeCommunityAvatarPath(String communityName) {
    return _stringTemplateService
        .parse(COMMUNITY_AVATAR_PATH, {'communityName': communityName});
  }

  String _makeCommunityCoverPath(String communityName) {
    return _stringTemplateService
        .parse(COMMUNITY_COVER_PATH, {'communityName': communityName});
  }

  String _makeGetCommunityMembersPath(String communityName) {
    return _stringTemplateService
        .parse(GET_COMMUNITY_MEMBERS_PATH, {'communityName': communityName});
  }

  String _makeSearchCommunityMembersPath(String communityName) {
    return _stringTemplateService
        .parse(SEARCH_COMMUNITY_MEMBERS_PATH, {'communityName': communityName});
  }

  String _makeGetCommunityBannedUsersPath(String communityName) {
    return _stringTemplateService.parse(
        GET_COMMUNITY_BANNED_USERS_PATH, {'communityName': communityName});
  }

  String _makeGetCommunityAdministratorsPath(String communityName) {
    return _stringTemplateService.parse(
        GET_COMMUNITY_ADMINISTRATORS_PATH, {'communityName': communityName});
  }

  String _makeSearchCommunityAdministratorsPath(String communityName) {
    return _stringTemplateService.parse(
        SEARCH_COMMUNITY_ADMINISTRATORS_PATH, {'communityName': communityName});
  }

  String _makeGetCommunityModeratorsPath(String communityName) {
    return _stringTemplateService
        .parse(GET_COMMUNITY_MODERATORS_PATH, {'communityName': communityName});
  }

  String _makeSearchCommunityModeratorsPath(String communityName) {
    return _stringTemplateService.parse(
        SEARCH_COMMUNITY_MODERATORS_PATH, {'communityName': communityName});
  }

  String _makeApiUrl(String string) {
    return '$apiURL$string';
  }
}
