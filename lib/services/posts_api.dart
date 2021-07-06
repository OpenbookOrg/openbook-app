import 'dart:io';

import 'package:Okuna/services/httpie.dart';
import 'package:Okuna/services/string_template.dart';
import 'package:meta/meta.dart';

class PostsApiService {
  late HttpieService _httpService;
  late StringTemplateService _stringTemplateService;

  late String apiURL;

  static const GET_POSTS_PATH = 'api/posts/';
  static const GET_TOP_POSTS_PATH = 'api/posts/top/';
  static const EXCLUDED_TOP_POSTS_COMMUNITIES_PATH =
      'api/posts/top/excluded-communities/';
  static const EXCLUDED_TOP_POSTS_COMMUNITY_PATH =
      'api/posts/top/excluded-communities/{communityName}/';
  static const EXCLUDED_TOP_POSTS_COMMUNITIES_SEARCH_PATH =
      'api/posts/top/excluded-communities/search/';
  static const EXCLUDED_PROFILE_POSTS_COMMUNITIES_PATH =
      'api/posts/profile/excluded-communities/';
  static const EXCLUDED_PROFILE_POSTS_COMMUNITY_PATH =
      'api/posts/profile/excluded-communities/{communityName}/';
  static const EXCLUDED_PROFILE_POSTS_COMMUNITIES_SEARCH_PATH =
      'api/posts/profile/excluded-communities/search/';
  static const GET_TRENDING_POSTS_PATH = 'api/posts/trending/new/';
  static const CREATE_POST_PATH = 'api/posts/';
  static const POST_MEDIA_PATH = 'api/posts/{postUuid}/media/';
  static const EDIT_POST_PATH = 'api/posts/{postUuid}/';
  static const PUBLISH_POST_PATH = 'api/posts/{postUuid}/publish/';
  static const POST_PATH = 'api/posts/{postUuid}/';
  static const GET_POST_STATUS_PATH = 'api/posts/{postUuid}/status/';
  static const OPEN_POST_PATH = 'api/posts/{postUuid}/open/';
  static const CLOSE_POST_PATH = 'api/posts/{postUuid}/close/';
  static const COMMENT_POST_PATH = 'api/posts/{postUuid}/comments/';
  static const EDIT_COMMENT_POST_PATH =
      'api/posts/{postUuid}/comments/{postCommentId}/';
  static const GET_COMMENT_POST_PATH =
      'api/posts/{postUuid}/comments/{postCommentId}/';
  static const REPLY_COMMENT_POST_PATH =
      'api/posts/{postUuid}/comments/{postCommentId}/replies/';
  static const MUTE_POST_PATH = 'api/posts/{postUuid}/notifications/mute/';
  static const UNMUTE_POST_PATH = 'api/posts/{postUuid}/notifications/unmute/';
  static const REPORT_POST_PATH = 'api/posts/{postUuid}/report/';
  static const PREVIEW_POST_DATA_PATH = 'api/posts/{postUuid}/link-preview/';
  static const TRANSLATE_POST_PATH = 'api/posts/{postUuid}/translate/';
  static const TRANSLATE_POST_COMMENT_PATH =
      'api/posts/{postUuid}/comments/{postCommentId}/translate/';
  static const DELETE_POST_COMMENT_PATH =
      'api/posts/{postUuid}/comments/{postCommentId}/';
  static const REPORT_POST_COMMENT_PATH =
      'api/posts/{postUuid}/comments/{postCommentId}/report/';
  static const GET_POST_COMMENTS_PATH = 'api/posts/{postUuid}/comments/';
  static const DISABLE_POST_COMMENTS_PATH =
      'api/posts/{postUuid}/comments/disable/';
  static const ENABLE_POST_COMMENTS_PATH =
      'api/posts/{postUuid}/comments/enable/';
  static const REACT_TO_POST_PATH = 'api/posts/{postUuid}/reactions/';
  static const DELETE_POST_REACTION_PATH =
      'api/posts/{postUuid}/reactions/{postReactionId}/';
  static const GET_POST_REACTIONS_PATH = 'api/posts/{postUuid}/reactions/';
  static const GET_POST_REACTIONS_EMOJI_COUNT_PATH =
      'api/posts/{postUuid}/reactions/emoji-count/';
  static const GET_REACTION_EMOJI_GROUPS = 'api/posts/emojis/groups/';

  static const REACT_TO_POST_COMMENT_PATH =
      'api/posts/{postUuid}/comments/{postCommentId}/reactions/';
  static const DELETE_POST_COMMENT_REACTION_PATH =
      'api/posts/{postUuid}/comments/{postCommentId}/reactions/{postCommentReactionId}/';
  static const GET_POST_COMMENT_REACTIONS_PATH =
      'api/posts/{postUuid}/comments/{postCommentId}/reactions/';
  static const GET_POST_COMMENT_REACTIONS_EMOJI_COUNT_PATH =
      'api/posts/{postUuid}/comments/{postCommentId}/reactions/emoji-count/';

  static const MUTE_POST_COMMENT_PATH =
      'api/posts/{postUuid}/comments/{postCommentId}/notifications/mute/';
  static const UNMUTE_POST_COMMENT_PATH =
      'api/posts/{postUuid}/comments/{postCommentId}/notifications/unmute/';
  static const GET_POST_PARTICIPANTS_PATH =
      'api/posts/{postUuid}/participants/';
  static const SEARCH_POST_PARTICIPANTS_PATH =
      'api/posts/{postUuid}/participants/search/';

  static const PREVIEW_LINK_PATH = 'api/posts/links/preview/';
  static const LINK_IS_PREVIEWABLE_PATH = 'api/posts/links/is-previewable/';

  void setHttpieService(HttpieService httpService) {
    _httpService = httpService;
  }

  void setStringTemplateService(StringTemplateService stringTemplateService) {
    _stringTemplateService = stringTemplateService;
  }

  void setApiURL(String newApiURL) {
    apiURL = newApiURL;
  }

  Future<HttpieResponse> getTopPosts(
      {int? maxId,
      int? minId,
      int? count,
      bool? excludeJoinedCommunities,
      bool authenticatedRequest = true}) {
    Map<String, dynamic> queryParams = {};
    if (count != null) queryParams['count'] = count;

    if (maxId != null) queryParams['max_id'] = maxId;

    if (minId != null) queryParams['min_id'] = minId;

    if (excludeJoinedCommunities != null)
      queryParams['exclude_joined_communities'] = excludeJoinedCommunities;

    return _httpService.get('$apiURL$GET_TOP_POSTS_PATH',
        queryParameters: queryParams,
        appendAuthorizationToken: authenticatedRequest);
  }

  Future<HttpieResponse> getTrendingPosts(
      {int? maxId, int? minId, int? count, bool authenticatedRequest = true}) {
    Map<String, dynamic> queryParams = {};
    if (count != null) queryParams['count'] = count;

    if (maxId != null) queryParams['max_id'] = maxId;

    if (minId != null) queryParams['min_id'] = minId;

    return _httpService.get('$apiURL$GET_TRENDING_POSTS_PATH',
        queryParameters: queryParams,
        appendAuthorizationToken: authenticatedRequest);
  }

  Future<HttpieResponse> getTimelinePosts(
      {List<int>? listIds,
      List<int>? circleIds,
      int? maxId,
      int? count,
      String? username,
      bool authenticatedRequest = true}) {
    Map<String, dynamic> queryParams = {};

    if (listIds != null && listIds.isNotEmpty) queryParams['list_id'] = listIds;

    if (circleIds != null && circleIds.isNotEmpty)
      queryParams['circle_id'] = circleIds;

    if (count != null) queryParams['count'] = count;

    if (maxId != null) queryParams['max_id'] = maxId;

    if (username != null) queryParams['username'] = username;

    return _httpService.get(_makeApiUrl(GET_POSTS_PATH),
        queryParameters: queryParams,
        appendAuthorizationToken: authenticatedRequest);
  }

  Future<HttpieStreamedResponse> createPost(
      {String? text, List<int>? circleIds, bool isDraft = false}) {
    Map<String, dynamic> body = {};

    if (text != null && text.length > 0) {
      body['text'] = text;
    }

    if (isDraft != null) {
      body['is_draft'] = isDraft;
    }

    if (circleIds != null && circleIds.length > 0) {
      body['circle_id'] = circleIds.join(',');
    }

    return _httpService.putMultiform(_makeApiUrl(CREATE_POST_PATH),
        body: body, appendAuthorizationToken: true);
  }

  Future<HttpieStreamedResponse> addMediaToPost(
      {required File file, required String postUuid}) {
    Map<String, dynamic> body = {'file': file};

    String path = _makeAddPostMediaPath(postUuid: postUuid);

    return _httpService.putMultiform(_makeApiUrl(path),
        body: body, appendAuthorizationToken: true);
  }

  Future<HttpieResponse> getPostMedia({required String postUuid}) {
    String path = _makeGetPostMediaPath(postUuid: postUuid);

    return _httpService.get(_makeApiUrl(path), appendAuthorizationToken: true);
  }

  Future<HttpieResponse> publishPost({required String postUuid}) {
    String path = _makePublishPostPath(postUuid: postUuid);

    return _httpService.post(_makeApiUrl(path), appendAuthorizationToken: true);
  }


  Future<HttpieResponse> getPostWithUuidStatus(String postUuid) {
    String path = _makeGetPostStatusPath(postUuid: postUuid);

    return _httpService.get(_makeApiUrl(path), appendAuthorizationToken: true);
  }

  Future<HttpieStreamedResponse> editPost(
      {required String postUuid, String? text}) {
    Map<String, dynamic> body = {};

    body['post_uuid'] = postUuid;

    if (text != null && text.length > 0) {
      body['text'] = text;
    }

    String path = _makePostPath(postUuid);

    return _httpService.patchMultiform(_makeApiUrl(path),
        body: body, appendAuthorizationToken: true);
  }

  Future<HttpieResponse> getPostWithUuid(String postUuid) {
    String path = _makePostPath(postUuid);

    return _httpService.get(_makeApiUrl(path), appendAuthorizationToken: true);
  }

  Future<HttpieResponse> deletePostWithUuid(String postUuid) {
    String path = _makePostPath(postUuid);

    return _httpService.delete(_makeApiUrl(path),
        appendAuthorizationToken: true);
  }

  Future<HttpieResponse> getCommentsForPostWithUuid(String postUuid,
      {int? countMax, int? maxId, int? countMin, int? minId, String? sort}) {
    Map<String, dynamic> queryParams = {};
    if (countMax != null) queryParams['count_max'] = countMax;
    if (countMin != null) queryParams['count_min'] = countMin;

    if (maxId != null) queryParams['max_id'] = maxId;
    if (minId != null) queryParams['min_id'] = minId;
    if (sort != null) queryParams['sort'] = sort;

    String path = _makeGetPostCommentsPath(postUuid);

    return _httpService.get(_makeApiUrl(path),
        queryParameters: queryParams, appendAuthorizationToken: true);
  }

  Future<HttpieResponse> getRepliesForCommentWithIdForPostWithUuid(
      String postUuid, int postCommentId,
      {int? countMax, int? maxId, int? countMin, int? minId, String? sort}) {
    Map<String, dynamic> queryParams = {};
    if (countMax != null) queryParams['count_max'] = countMax;
    if (countMin != null) queryParams['count_min'] = countMin;

    if (maxId != null) queryParams['max_id'] = maxId;
    if (minId != null) queryParams['min_id'] = minId;
    if (sort != null) queryParams['sort'] = sort;

    String path = _makeGetReplyCommentsPostPath(postUuid, postCommentId);

    return _httpService.get(_makeApiUrl(path),
        queryParameters: queryParams, appendAuthorizationToken: true);
  }

  Future<HttpieResponse> commentPost(
      {required String postUuid, required String text}) {
    Map<String, dynamic> body = {'text': text};

    String path = _makeCommentPostPath(postUuid);
    return _httpService.putJSON(_makeApiUrl(path),
        body: body, appendAuthorizationToken: true);
  }

  Future<HttpieResponse> editPostComment(
      {required String postUuid,
      required int postCommentId,
      required String text}) {
    Map<String, dynamic> body = {'text': text};

    String path = _makeEditCommentPostPath(postUuid, postCommentId);
    return _httpService.patchJSON(_makeApiUrl(path),
        body: body, appendAuthorizationToken: true);
  }

  Future<HttpieResponse> getPostComment(
      {required String postUuid, required int postCommentId}) {
    String path = _makeGetCommentPostPath(postUuid, postCommentId);
    return _httpService.get(_makeApiUrl(path), appendAuthorizationToken: true);
  }

  Future<HttpieResponse> replyPostComment(
      {required String postUuid,
      required int postCommentId,
      required String text}) {
    Map<String, dynamic> body = {'text': text};

    String path = _makeReplyCommentPostPath(postUuid, postCommentId);
    return _httpService.putJSON(_makeApiUrl(path),
        body: body, appendAuthorizationToken: true);
  }

  Future<HttpieResponse> deletePostComment(
      {required postCommentId, required postUuid}) {
    String path = _makeDeletePostCommentPath(
        postCommentId: postCommentId, postUuid: postUuid);

    return _httpService.delete(_makeApiUrl(path),
        appendAuthorizationToken: true);
  }

  Future<HttpieResponse> getReactionsForPostWithUuid(String postUuid,
      {int? count, int? maxId, int? emojiId}) {
    Map<String, dynamic> queryParams = {};
    if (count != null) queryParams['count'] = count;

    if (maxId != null) queryParams['max_id'] = maxId;

    if (emojiId != null) queryParams['emoji_id'] = emojiId;

    String path = _makeGetPostReactionsPath(postUuid);

    return _httpService.get(_makeApiUrl(path),
        queryParameters: queryParams, appendAuthorizationToken: true);
  }

  Future<HttpieResponse> getReactionsEmojiCountForPostWithUuid(
      String postUuid) {
    String path = _makeGetPostReactionsEmojiCountPath(postUuid);

    return _httpService.get(_makeApiUrl(path), appendAuthorizationToken: true);
  }

  Future<HttpieResponse> reactToPost(
      {required String postUuid, required int emojiId}) {
    Map<String, dynamic> body = {'emoji_id': emojiId};

    String path = _makeReactToPostPath(postUuid);
    return _httpService.putJSON(_makeApiUrl(path),
        body: body, appendAuthorizationToken: true);
  }

  Future<HttpieResponse> deletePostReaction(
      {required postReactionId, required postUuid}) {
    String path = _makeDeletePostReactionPath(
        postReactionId: postReactionId, postUuid: postUuid);

    return _httpService.delete(_makeApiUrl(path),
        appendAuthorizationToken: true);
  }

  Future<HttpieResponse> getReactionsForPostComment(
      {required int postCommentId,
      required String postUuid,
      int? count,
      int? maxId,
      int? emojiId}) {
    Map<String, dynamic> queryParams = {};
    if (count != null) queryParams['count'] = count;

    if (maxId != null) queryParams['max_id'] = maxId;

    if (emojiId != null) queryParams['emoji_id'] = emojiId;

    String path = _makeGetPostCommentReactionsPath(
        postUuid: postUuid, postCommentId: postCommentId);

    return _httpService.get(_makeApiUrl(path),
        queryParameters: queryParams, appendAuthorizationToken: true);
  }

  Future<HttpieResponse> getReactionsEmojiCountForPostComment({
    required int postCommentId,
    required String postUuid,
  }) {
    String path = _makeGetPostCommentReactionsEmojiCountPath(
        postCommentId: postCommentId, postUuid: postUuid);

    return _httpService.get(_makeApiUrl(path), appendAuthorizationToken: true);
  }

  Future<HttpieResponse> reactToPostComment(
      {required int postCommentId,
      required String postUuid,
      required int emojiId}) {
    Map<String, dynamic> body = {'emoji_id': emojiId};

    String path = _makeReactToPostCommentPath(
        postUuid: postUuid, postCommentId: postCommentId);

    return _httpService.putJSON(_makeApiUrl(path),
        body: body, appendAuthorizationToken: true);
  }

  Future<HttpieResponse> deletePostCommentReaction({
    required postCommentReactionId,
    required int postCommentId,
    required String postUuid,
  }) {
    String path = _makeDeletePostCommentReactionPath(
      postCommentReactionId: postCommentReactionId,
      postUuid: postUuid,
      postCommentId: postCommentId,
    );

    return _httpService.delete(_makeApiUrl(path),
        appendAuthorizationToken: true);
  }

  Future<HttpieResponse> mutePostComment({
    required int postCommentId,
    required String postUuid,
  }) {
    String path = _makeMutePostCommentPath(
        postCommentId: postCommentId, postUuid: postUuid);
    return _httpService.post(_makeApiUrl(path), appendAuthorizationToken: true);
  }

  Future<HttpieResponse> unmutePostComment({
    required int postCommentId,
    required String postUuid,
  }) {
    String path = _makeUnmutePostCommentPath(
        postCommentId: postCommentId, postUuid: postUuid);
    return _httpService.post(_makeApiUrl(path), appendAuthorizationToken: true);
  }

  Future<HttpieResponse> mutePostWithUuid(String postUuid) {
    String path = _makeMutePostPath(postUuid);
    return _httpService.post(_makeApiUrl(path), appendAuthorizationToken: true);
  }

  Future<HttpieResponse> unmutePostWithUuid(String postUuid) {
    String path = _makeUnmutePostPath(postUuid);
    return _httpService.post(_makeApiUrl(path), appendAuthorizationToken: true);
  }

  Future<HttpieResponse> disableCommentsForPostWithUuidPost(String postUuid) {
    String path = _makeDisableCommentsForPostPath(postUuid);
    return _httpService.post(_makeApiUrl(path), appendAuthorizationToken: true);
  }

  Future<HttpieResponse> enableCommentsForPostWithUuidPost(String postUuid) {
    String path = _makeEnableCommentsForPostPath(postUuid);
    return _httpService.post(_makeApiUrl(path), appendAuthorizationToken: true);
  }

  Future<HttpieResponse> openPostWithUuid(String postUuid) {
    String path = _makeOpenPostPath(postUuid);
    return _httpService.post(_makeApiUrl(path), appendAuthorizationToken: true);
  }

  Future<HttpieResponse> closePostWithUuid(String postUuid) {
    String path = _makeClosePostPath(postUuid);
    return _httpService.post(_makeApiUrl(path), appendAuthorizationToken: true);
  }

  Future<HttpieResponse> getReactionEmojiGroups() {
    String url = _makeApiUrl(GET_REACTION_EMOJI_GROUPS);
    return _httpService.get(url, appendAuthorizationToken: true);
  }

  Future<HttpieResponse> reportPostComment(
      {required int postCommentId,
      required String postUuid,
      required int moderationCategoryId,
      String? description}) {
    String path = _makeReportPostCommentPath(
        postCommentId: postCommentId, postUuid: postUuid);

    Map<String, dynamic> body = {
      'category_id': moderationCategoryId.toString()
    };

    if (description != null && description.isNotEmpty) {
      body['description'] = description;
    }

    return _httpService.post(_makeApiUrl(path),
        body: body, appendAuthorizationToken: true);
  }

  Future<HttpieResponse> reportPost(
      {required String postUuid,
      required int moderationCategoryId,
      String? description}) {
    String path = _makeReportPostPath(postUuid: postUuid);

    Map<String, dynamic> body = {
      'category_id': moderationCategoryId.toString()
    };

    if (description != null && description.isNotEmpty) {
      body['description'] = description;
    }

    return _httpService.post(_makeApiUrl(path),
        body: body, appendAuthorizationToken: true);
  }

  Future<HttpieResponse> translatePost({required String postUuid}) {
    String path = _makeTranslatePostPath(postUuid: postUuid);

    return _httpService.post(_makeApiUrl(path), appendAuthorizationToken: true);
  }

  Future<HttpieResponse> getPreviewDataForPostUuid(
      {required String postUuid}) {
    String path = _makePreviewPostDataPath(postUuid: postUuid);

    return _httpService.get(_makeApiUrl(path), appendAuthorizationToken: true);
  }

  Future<HttpieResponse> translatePostComment(
      {required String postUuid, required int postCommentId}) {
    String path = _makeTranslatePostCommentPath(
        postUuid: postUuid, postCommentId: postCommentId);

    return _httpService.post(_makeApiUrl(path), appendAuthorizationToken: true);
  }

  Future<HttpieResponse> getPostParticipants(
      {required String postUuid, int? count}) {
    String path = _makeGetPostParticipantsPath(postUuid);

    Map<String, dynamic> queryParams = {};

    if (count != null) queryParams['count'] = count;

    return _httpService.get(_makeApiUrl(path), appendAuthorizationToken: true);
  }

  Future<HttpieResponse> searchPostParticipants(
      {required String postUuid, required String query, int? count}) {
    String path = _makeSearchPostParticipantsPath(postUuid);

    Map<String, dynamic> body = {'query': query};

    if (count != null) body['count'] = count;

    return _httpService.post(_makeApiUrl(path),
        body: body, appendAuthorizationToken: true);
  }

  Future<HttpieResponse> getTopPostsExcludedCommunities(
      {bool authenticatedRequest = true, int? offset, int? count}) {
    return _httpService.get('$apiURL$EXCLUDED_TOP_POSTS_COMMUNITIES_PATH',
        appendAuthorizationToken: authenticatedRequest,
        queryParameters: {'offset': offset, 'count': count});
  }

  Future<HttpieResponse> searchTopPostsExcludedCommunities(
      {required String query, int? count}) {
    Map<String, dynamic> queryParams = {'query': query};

    if (count != null) queryParams['count'] = count;

    return _httpService.get('$apiURL$EXCLUDED_TOP_POSTS_COMMUNITIES_PATH',
        queryParameters: queryParams, appendAuthorizationToken: true);
  }

  Future<HttpieResponse> excludeCommunityFromTopPosts(
      {required String communityName}) {
    return _httpService.putJSON('$apiURL$EXCLUDED_TOP_POSTS_COMMUNITIES_PATH',
        body: {'community_name': communityName},
        appendAuthorizationToken: true);
  }

  Future<HttpieResponse> undoExcludeCommunityFromTopPosts(
      {required String communityName}) {
    String path = _makeExcludedCommunityFromTopPostsPath(communityName);
    return _httpService.delete(_makeApiUrl(path),
        appendAuthorizationToken: true);
  }

  String _makeExcludedCommunityFromTopPostsPath(String communityName) {
    return _stringTemplateService.parse(
        EXCLUDED_TOP_POSTS_COMMUNITY_PATH, {'communityName': communityName});
  }

  Future<HttpieResponse> getProfilePostsExcludedCommunities(
      {bool authenticatedRequest = true, int? offset, int? count}) {
    return _httpService.get('$apiURL$EXCLUDED_PROFILE_POSTS_COMMUNITIES_PATH',
        appendAuthorizationToken: authenticatedRequest,
        queryParameters: {'offset': offset, 'count': count});
  }

  Future<HttpieResponse> searchProfilePostsExcludedCommunities(
      {required String query, int? count}) {
    Map<String, dynamic> queryParams = {'query': query};

    if (count != null) queryParams['count'] = count;

    return _httpService.get('$apiURL$EXCLUDED_PROFILE_POSTS_COMMUNITIES_PATH',
        queryParameters: queryParams, appendAuthorizationToken: true);
  }

  Future<HttpieResponse> excludeCommunityFromProfilePosts(
      {required String communityName}) {
    return _httpService.putJSON(
        '$apiURL$EXCLUDED_PROFILE_POSTS_COMMUNITIES_PATH',
        body: {'community_name': communityName},
        appendAuthorizationToken: true);
  }

  Future<HttpieResponse> undoExcludeCommunityFromProfilePosts(
      {required String communityName}) {
    String path = _makeExcludedCommunityFromProfilePostsPath(communityName);
    return _httpService.delete(_makeApiUrl(path),
        appendAuthorizationToken: true);
  }

  Future<HttpieResponse> previewLink(
      {required String link}) {
    Map<String, dynamic> body = {'link': link};

    return _httpService.postJSON(_makeApiUrl(PREVIEW_LINK_PATH),
        body: body, appendAuthorizationToken: true);
  }

  Future<HttpieResponse> linkIsPreviewable(
      {required String link}) {
    Map<String, dynamic> body = {'link': link};

    return _httpService.postJSON(_makeApiUrl(LINK_IS_PREVIEWABLE_PATH),
        body: body, appendAuthorizationToken: true);
  }

  String _makeExcludedCommunityFromProfilePostsPath(String communityName) {
    return _stringTemplateService.parse(EXCLUDED_PROFILE_POSTS_COMMUNITY_PATH,
        {'communityName': communityName});
  }

  String _makePostPath(String postUuid) {
    return _stringTemplateService.parse(POST_PATH, {'postUuid': postUuid});
  }

  String _makeMutePostPath(String postUuid) {
    return _stringTemplateService.parse(MUTE_POST_PATH, {'postUuid': postUuid});
  }

  String _makeUnmutePostPath(String postUuid) {
    return _stringTemplateService
        .parse(UNMUTE_POST_PATH, {'postUuid': postUuid});
  }

  String _makeMutePostCommentPath({
    required int postCommentId,
    required String postUuid,
  }) {
    return _stringTemplateService.parse(MUTE_POST_COMMENT_PATH,
        {'postCommentId': postCommentId, 'postUuid': postUuid});
  }

  String _makeUnmutePostCommentPath({
    required int postCommentId,
    required String postUuid,
  }) {
    return _stringTemplateService.parse(UNMUTE_POST_COMMENT_PATH,
        {'postCommentId': postCommentId, 'postUuid': postUuid});
  }

  String _makeDisableCommentsForPostPath(String postUuid) {
    return _stringTemplateService
        .parse(DISABLE_POST_COMMENTS_PATH, {'postUuid': postUuid});
  }

  String _makeEnableCommentsForPostPath(String postUuid) {
    return _stringTemplateService
        .parse(ENABLE_POST_COMMENTS_PATH, {'postUuid': postUuid});
  }

  String _makeOpenPostPath(String postUuid) {
    return _stringTemplateService.parse(OPEN_POST_PATH, {'postUuid': postUuid});
  }

  String _makeClosePostPath(String postUuid) {
    return _stringTemplateService
        .parse(CLOSE_POST_PATH, {'postUuid': postUuid});
  }

  String _makeCommentPostPath(String postUuid) {
    return _stringTemplateService
        .parse(COMMENT_POST_PATH, {'postUuid': postUuid});
  }

  String _makeEditCommentPostPath(String postUuid, int postCommentId) {
    return _stringTemplateService.parse(EDIT_COMMENT_POST_PATH,
        {'postUuid': postUuid, 'postCommentId': postCommentId});
  }

  String _makeGetCommentPostPath(String postUuid, int postCommentId) {
    return _stringTemplateService.parse(GET_COMMENT_POST_PATH,
        {'postUuid': postUuid, 'postCommentId': postCommentId});
  }

  String _makeReplyCommentPostPath(String postUuid, int postCommentId) {
    return _stringTemplateService.parse(REPLY_COMMENT_POST_PATH,
        {'postUuid': postUuid, 'postCommentId': postCommentId});
  }

  String _makeGetReplyCommentsPostPath(String postUuid, int postCommentId) {
    return _stringTemplateService.parse(REPLY_COMMENT_POST_PATH,
        {'postUuid': postUuid, 'postCommentId': postCommentId});
  }

  String _makeGetPostCommentsPath(String postUuid) {
    return _stringTemplateService
        .parse(GET_POST_COMMENTS_PATH, {'postUuid': postUuid});
  }

  String _makeDeletePostCommentPath(
      {required postCommentId, required postUuid}) {
    return _stringTemplateService.parse(DELETE_POST_COMMENT_PATH,
        {'postCommentId': postCommentId, 'postUuid': postUuid});
  }

  String _makeReactToPostPath(String postUuid) {
    return _stringTemplateService
        .parse(REACT_TO_POST_PATH, {'postUuid': postUuid});
  }

  String _makeGetPostParticipantsPath(String postUuid) {
    return _stringTemplateService
        .parse(GET_POST_PARTICIPANTS_PATH, {'postUuid': postUuid});
  }

  String _makeSearchPostParticipantsPath(String postUuid) {
    return _stringTemplateService
        .parse(SEARCH_POST_PARTICIPANTS_PATH, {'postUuid': postUuid});
  }

  String _makeGetPostReactionsPath(String postUuid) {
    return _stringTemplateService
        .parse(GET_POST_REACTIONS_PATH, {'postUuid': postUuid});
  }

  String _makeReactToPostCommentPath(
      {required int postCommentId, required String postUuid}) {
    return _stringTemplateService.parse(REACT_TO_POST_COMMENT_PATH,
        {'postUuid': postUuid, 'postCommentId': postCommentId});
  }

  String _makeGetPostCommentReactionsPath(
      {required int postCommentId, required String postUuid}) {
    return _stringTemplateService.parse(GET_POST_COMMENT_REACTIONS_PATH,
        {'postCommentId': postCommentId, 'postUuid': postUuid});
  }

  String _makeDeletePostCommentReactionPath(
      {required int postCommentReactionId,
      required String postUuid,
      required int postCommentId}) {
    return _stringTemplateService.parse(DELETE_POST_COMMENT_REACTION_PATH, {
      'postCommentReactionId': postCommentReactionId,
      'postUuid': postUuid,
      'postCommentId': postCommentId
    });
  }

  String _makeGetPostCommentReactionsEmojiCountPath(
      {required postUuid, required int postCommentId}) {
    return _stringTemplateService.parse(
        GET_POST_COMMENT_REACTIONS_EMOJI_COUNT_PATH,
        {'postUuid': postUuid, 'postCommentId': postCommentId});
  }

  String _makeDeletePostReactionPath(
      {required postReactionId, required postUuid}) {
    return _stringTemplateService.parse(DELETE_POST_REACTION_PATH,
        {'postReactionId': postReactionId, 'postUuid': postUuid});
  }

  String _makeGetPostReactionsEmojiCountPath(String postUuid) {
    return _stringTemplateService
        .parse(GET_POST_REACTIONS_EMOJI_COUNT_PATH, {'postUuid': postUuid});
  }

  String _makeReportPostCommentPath(
      {required int postCommentId, required String postUuid}) {
    return _stringTemplateService.parse(REPORT_POST_COMMENT_PATH,
        {'postCommentId': postCommentId, 'postUuid': postUuid});
  }

  String _makeReportPostPath({required postUuid}) {
    return _stringTemplateService
        .parse(REPORT_POST_PATH, {'postUuid': postUuid});
  }

  String _makeTranslatePostPath({required postUuid}) {
    return _stringTemplateService
        .parse(TRANSLATE_POST_PATH, {'postUuid': postUuid});
  }

  String _makePreviewPostDataPath({required postUuid}) {
    return _stringTemplateService
        .parse(PREVIEW_POST_DATA_PATH, {'postUuid': postUuid});
  }

  String _makeAddPostMediaPath({required postUuid}) {
    return _stringTemplateService
        .parse(POST_MEDIA_PATH, {'postUuid': postUuid});
  }

  String _makeGetPostMediaPath({required postUuid}) {
    return _stringTemplateService
        .parse(POST_MEDIA_PATH, {'postUuid': postUuid});
  }

  String _makePublishPostPath({required postUuid}) {
    return _stringTemplateService
        .parse(PUBLISH_POST_PATH, {'postUuid': postUuid});
  }

  String _makeGetPostStatusPath({required postUuid}) {
    return _stringTemplateService
        .parse(GET_POST_STATUS_PATH, {'postUuid': postUuid});
  }

  String _makeTranslatePostCommentPath(
      {required postUuid, required postCommentId}) {
    return _stringTemplateService.parse(TRANSLATE_POST_COMMENT_PATH,
        {'postUuid': postUuid, 'postCommentId': postCommentId});
  }

  String _makeApiUrl(String string) {
    return '$apiURL$string';
  }
}
