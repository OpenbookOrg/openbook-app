import 'dart:io';
import 'package:Okuna/services/auth_api.dart';
import 'package:Okuna/services/communities_api.dart';
import 'package:Okuna/services/connections_circles_api.dart';
import 'package:Okuna/services/follows_lists_api.dart';
import 'package:Okuna/services/httpie.dart';
import 'package:Okuna/services/media/media.dart';
import 'package:Okuna/services/utils_service.dart';
import 'package:validators/validators.dart' as validators;

import 'localization.dart';

class ValidationService {
  late AuthApiService _authApiService;
  late CommunitiesApiService _communitiesApiService;
  late FollowsListsApiService _followsListsApiService;
  late ConnectionsCirclesApiService _connectionsCirclesApiService;
  late LocalizationService _localizationService;
  late UtilsService _utilsService;

  static const int USERNAME_MAX_LENGTH = 30;
  static const int COMMUNITY_NAME_MAX_LENGTH = 32;
  static const int COMMUNITY_TITLE_MAX_LENGTH = 32;
  static const int COMMUNITY_DESCRIPTION_MAX_LENGTH = 500;
  static const int COMMUNITY_USER_ADJECTIVE_MAX_LENGTH = 16;
  static const int COMMUNITY_RULES_MAX_LENGTH = 1500;
  static const int POST_MAX_LENGTH = 5000;
  static const int POST_MAX_HASHTAGS = 3;
  static const int HASHTAG_MAX_LENGTH = 32;
  static const int POST_COMMENT_MAX_HASHTAGS = 3;
  static const int POST_COMMENT_MAX_LENGTH = 1500;
  static const int PASSWORD_MIN_LENGTH = 10;
  static const int PASSWORD_MAX_LENGTH = 100;
  static const int CIRCLE_MAX_LENGTH = 100;
  static const int COLOR_ATTR_MAX_LENGTH = 7;
  static const int LIST_MAX_LENGTH = 100;
  static const int PROFILE_NAME_MAX_LENGTH = 192;
  static const int MODERATED_OBJECT_DESCRIPTION_MAX_LENGTH = 1000;
  static const int MODERATED_OBJECT_DESCRIPTION_MIN_LENGTH = 1;
  static const int PROFILE_NAME_MIN_LENGTH = 1;
  static const int PROFILE_LOCATION_MAX_LENGTH = 64;
  static const int PROFILE_BIO_MAX_LENGTH = 1000;
  static const int POST_IMAGE_MAX_SIZE = 20971520;
  static const int AVATAR_IMAGE_MAX_SIZE = 20971520;
  static const int COVER_IMAGE_MAX_SIZE = 20971520;
  static const int VIDEO_MAX_SIZE = 20971520;

  void setAuthApiService(AuthApiService authApiService) {
    _authApiService = authApiService;
  }

  void setUtilsService(UtilsService utilsService) {
    _utilsService = utilsService;
  }

  void setCommunitiesApiService(CommunitiesApiService communitiesApiService) {
    _communitiesApiService = communitiesApiService;
  }

  void setFollowsListsApiService(
      FollowsListsApiService followsListsApiService) {
    _followsListsApiService = followsListsApiService;
  }

  void setLocalizationService(LocalizationService localizationService) {
    _localizationService = localizationService;
  }

  void setConnectionsCirclesApiService(
      ConnectionsCirclesApiService connectionsCirclesApiService) {
    _connectionsCirclesApiService = connectionsCirclesApiService;
  }

  bool isQualifiedEmail(String email) {
    return validators.isEmail(email);
  }

  bool isQualifiedLink(String link) {
    final uri = Uri.decodeFull(link);
    return isUrl(uri) && validators.contains(uri, '?token=');
  }

  bool isUrl(String url) {
    return validators.isURL(url);
  }

  bool isAlphanumericWithSpaces(String str) {
    String p = r'^[a-z0-9\s]+$';

    RegExp regExp = new RegExp(p, caseSensitive: false);

    return regExp.hasMatch(str);
  }

  bool isAlphanumericWithUnderscores(String str) {
    String p = r'^[a-zA-Z0-9_]+$';

    RegExp regExp = new RegExp(p, caseSensitive: false);

    return regExp.hasMatch(str);
  }

  bool isPasswordAllowedLength(String password) {
    return password.length >= PASSWORD_MIN_LENGTH &&
        password.length <= PASSWORD_MAX_LENGTH;
  }

  bool isPostTextAllowedLength(String postText) {
    return postText.length <= POST_MAX_LENGTH;
  }

  bool isPostTextContainingValidHashtags(String postText) {
    List<String?> hashtags = _utilsService.extractHashtagsInString(postText);
    bool hashtagsHaveAllowedMaxCharacters = true;

    hashtags
        .takeWhile((hashtag) => hashtagsHaveAllowedMaxCharacters)
        .forEach((hashtag) {
      if (hashtag != null && hashtag.length > HASHTAG_MAX_LENGTH) {
        hashtagsHaveAllowedMaxCharacters = false;
      }
    });

    return hashtags.length <= POST_MAX_HASHTAGS &&
        hashtagsHaveAllowedMaxCharacters;
  }

  bool isBioAllowedLength(String bio) {
    return bio.length > 0 && bio.length <= PROFILE_BIO_MAX_LENGTH;
  }

  bool isLocationAllowedLength(String location) {
    return location.length > 0 &&
        location.length <= PROFILE_LOCATION_MAX_LENGTH;
  }

  bool isUsernameAllowedLength(String username) {
    return username.length > 0 && username.length <= USERNAME_MAX_LENGTH;
  }

  bool isPostCommentAllowedLength(String postComment) {
    return postComment.length > 0 &&
        postComment.length <= POST_COMMENT_MAX_LENGTH;
  }

  bool isCommunityNameAllowedLength(String name) {
    return name.length > 0 && name.length <= COMMUNITY_NAME_MAX_LENGTH;
  }

  bool isCommunityDescriptionAllowedLength(String description) {
    return description.length > 0 &&
        description.length <= COMMUNITY_DESCRIPTION_MAX_LENGTH;
  }

  bool isCommunityTitleAllowedLength(String title) {
    return title.length > 0 && title.length <= COMMUNITY_TITLE_MAX_LENGTH;
  }

  bool isCommunityRulesAllowedLength(String rules) {
    return rules.length > 0 && rules.length <= COMMUNITY_RULES_MAX_LENGTH;
  }

  bool isCommunityUserAdjectiveAllowedLength(String userAdjective) {
    return userAdjective.length > 0 &&
        userAdjective.length <= COMMUNITY_USER_ADJECTIVE_MAX_LENGTH;
  }

  bool isFollowsListNameAllowedLength(String followsList) {
    return followsList.length > 0 && followsList.length <= LIST_MAX_LENGTH;
  }

  bool isConnectionsCircleNameAllowedLength(String connectionsCircle) {
    return connectionsCircle.length > 0 &&
        connectionsCircle.length <= CIRCLE_MAX_LENGTH;
  }

  bool isUsernameAllowedCharacters(String username) {
    String p = r'^[a-zA-Z0-9](?:[._]?[a-z-A-Z0-9])*$';

    RegExp regExp = new RegExp(p, caseSensitive: false);

    return regExp.hasMatch(username);
  }

  bool isCommunityNameAllowedCharacters(String name) {
    String p = r'^[a-zA-Z0-9_]+$';

    RegExp regExp = new RegExp(p, caseSensitive: false);

    return regExp.hasMatch(name);
  }

  Future<bool> isUsernameTaken(String username) async {
    HttpieResponse response =
        await _authApiService.checkUsernameIsAvailable(username: username);
    if (response.isAccepted()) {
      return false;
    } else if (response.isBadRequest()) {
      return true;
    } else {
      throw HttpieRequestError(response);
    }
  }

  Future<bool> isInviteTokenValid(String inviteToken) async {
    HttpieResponse response =
        await _authApiService.verifyRegisterToken(token: inviteToken);

    if (response.isAccepted()) {
      return true;
    } else if (response.isBadRequest()) {
      return false;
    } else {
      throw HttpieRequestError(response);
    }
  }

  Future<bool> isCommunityNameTaken(String name) async {
    HttpieResponse response =
        await _communitiesApiService.checkNameIsAvailable(name: name);
    if (response.isAccepted()) {
      return false;
    } else if (response.isBadRequest()) {
      return true;
    } else {
      throw HttpieRequestError(response);
    }
  }

  Future<bool> isEmailTaken(String email) async {
    HttpieResponse response =
        await _authApiService.checkEmailIsAvailable(email: email);
    if (response.isAccepted()) {
      return false;
    } else if (response.isBadRequest()) {
      return true;
    } else {
      throw HttpieRequestError(response);
    }
  }

  Future<bool> isFollowsListNameTaken(String name) async {
    HttpieResponse response =
        await _followsListsApiService.checkNameIsAvailable(name: name);
    if (response.isAccepted()) {
      return false;
    } else if (response.isBadRequest()) {
      return true;
    } else {
      throw HttpieRequestError(response);
    }
  }

  Future<bool> isConnectionsCircleNameTaken(String name) async {
    HttpieResponse response =
        await _connectionsCirclesApiService.checkNameIsAvailable(name: name);
    if (response.isAccepted()) {
      return false;
    } else if (response.isBadRequest()) {
      return true;
    } else {
      throw HttpieRequestError(response);
    }
  }

  bool isNameAllowedLength(String name) {
    return name.length >= PROFILE_NAME_MIN_LENGTH &&
        name.length <= PROFILE_NAME_MAX_LENGTH;
  }

  bool isModeratedObjectDescriptionAllowedLength(
      String moderatedObjectDescription) {
    return moderatedObjectDescription.length <= PROFILE_NAME_MAX_LENGTH;
  }

  Future<bool> isImageAllowedSize(File image, OBImageType type) async {
    int size = await image.length();
    return size <= getAllowedImageSize(type);
  }

  Future<bool> isVideoAllowedSize(File video) async {
    int size = await video.length();
    return size <= VIDEO_MAX_SIZE;
  }

  int getAllowedVideoSize() {
    return VIDEO_MAX_SIZE;
  }

  int getAllowedImageSize(OBImageType type) {
    if (type == OBImageType.avatar) {
      return AVATAR_IMAGE_MAX_SIZE;
    } else if (type == OBImageType.cover) {
      return COVER_IMAGE_MAX_SIZE;
    } else {
      return POST_IMAGE_MAX_SIZE;
    }
  }

  String? validateUserUsername(String? username) {
    assert(username != null);

    String? errorMsg;

    if (username!.length == 0) {
      errorMsg = _localizationService.auth__username_empty_error;
    } else if (!isUsernameAllowedLength(username)) {
      errorMsg = _localizationService
          .auth__username_maxlength_error(USERNAME_MAX_LENGTH);
    } else if (!isUsernameAllowedCharacters(username)) {
      errorMsg = _localizationService.auth__username_characters_error;
    }

    return errorMsg;
  }

  String? validatePostComment(String? postComment) {
    assert(postComment != null);

    String? errorMsg;

    if (postComment!.length == 0) {
      errorMsg = _localizationService.post__comment_required_error;
    } else if (!isPostCommentAllowedLength(postComment)) {
      errorMsg = _localizationService
          .post__comment_maxlength_error(POST_COMMENT_MAX_LENGTH);
    }

    return errorMsg;
  }

  String? validateUserEmail(String? email) {
    assert(email != null);

    String? errorMsg;

    if (email!.length == 0) {
      errorMsg = _localizationService.auth__email_empty_error;
    } else if (!isQualifiedEmail(email)) {
      errorMsg = _localizationService.auth__email_invalid_error;
    }

    return errorMsg;
  }

  String? validateUserRegistrationLink(String? link) {
    assert(link != null);

    String? errorMsg;

    if (link!.length == 0) {
      errorMsg = _localizationService.auth__create_acc__link_empty_error;
    } else if (!isQualifiedLink(link)) {
      errorMsg = _localizationService.auth__create_acc__link_invalid_error;
    }

    return errorMsg;
  }

  String? validateUserPassword(String? password) {
    assert(password != null);

    String? errorMsg;

    if (password!.length == 0) {
      errorMsg = _localizationService.auth__password_empty_error;
    } else if (!isPasswordAllowedLength(password)) {
      errorMsg = _localizationService.auth__password_range_error(
          PASSWORD_MIN_LENGTH, PASSWORD_MAX_LENGTH);
    }

    return errorMsg;
  }

  String? validateUserProfileName(String? name) {
    assert(name != null);

    String? errorMsg;

    if (name!.isEmpty) {
      errorMsg = _localizationService.auth__name_empty_error;
    } else if (!isNameAllowedLength(name)) {
      errorMsg = _localizationService.auth__name_range_error(
          PROFILE_NAME_MIN_LENGTH, PROFILE_NAME_MAX_LENGTH);
    }
    return errorMsg;
  }

  String? validateModeratedObjectDescription(String? description) {
    assert(description != null);

    String? errorMsg;

    if (description!.isEmpty) {
      errorMsg = _localizationService.auth__description_empty_error;
    } else if (!isModeratedObjectDescriptionAllowedLength(description)) {
      errorMsg = _localizationService.auth__description_range_error(
          MODERATED_OBJECT_DESCRIPTION_MIN_LENGTH,
          MODERATED_OBJECT_DESCRIPTION_MAX_LENGTH);
    }
    return errorMsg;
  }

  String? validateUserProfileUrl(String? url) {
    assert(url != null);

    if (url!.isEmpty) return null;

    String? errorMsg;

    if (!isUrl(url)) {
      errorMsg = _localizationService.user__profile_url_invalid_error;
    }

    return errorMsg;
  }

  String? validateUserProfileLocation(String? location) {
    assert(location != null);

    if (location!.isEmpty) return null;

    String? errorMsg;

    if (!isLocationAllowedLength(location)) {
      errorMsg = _localizationService
          .user__profile_location_length_error(PROFILE_LOCATION_MAX_LENGTH);
    }

    return errorMsg;
  }

  String? validateUserProfileBio(String? bio) {
    assert(bio != null);

    if (bio!.isEmpty) return null;

    String? errorMsg;

    if (!isBioAllowedLength(bio)) {
      errorMsg = _localizationService
          .user__profile_bio_length_error(PROFILE_BIO_MAX_LENGTH);
    }

    return errorMsg;
  }

  String? validateFollowsListName(String? name) {
    assert(name != null);

    String? errorMsg;

    if (name!.length == 0) {
      errorMsg = _localizationService.user__list_name_empty_error;
    } else if (!isFollowsListNameAllowedLength(name)) {
      errorMsg =
          _localizationService.user__list_name_range_error(LIST_MAX_LENGTH);
    }

    return errorMsg;
  }

  String? validateConnectionsCircleName(String? name) {
    assert(name != null);

    String? errorMsg;

    if (name!.length == 0) {
      errorMsg = _localizationService.user__circle_name_empty_error;
    } else if (!isConnectionsCircleNameAllowedLength(name)) {
      errorMsg =
          _localizationService.user__circle_name_range_error(CIRCLE_MAX_LENGTH);
    }

    return errorMsg;
  }

  String? validateCommunityName(String? name) {
    assert(name != null);

    String? errorMsg;

    if (name!.length == 0) {
      errorMsg = _localizationService.community__name_empty_error;
    } else if (!isCommunityNameAllowedLength(name)) {
      errorMsg = _localizationService
          .community__name_range_error(COMMUNITY_NAME_MAX_LENGTH);
    } else if (!isCommunityNameAllowedCharacters(name)) {
      errorMsg = _localizationService.community__name_characters_error;
    }

    return errorMsg;
  }

  String? validateCommunityTitle(String? title) {
    assert(title != null);

    String? errorMsg;

    if (title!.length == 0) {
      errorMsg = _localizationService.community__title_empty_error;
    } else if (!isCommunityTitleAllowedLength(title)) {
      errorMsg = _localizationService
          .community__title_range_error(COMMUNITY_TITLE_MAX_LENGTH);
    }
    return errorMsg;
  }

  String? validateCommunityRules(String? rules) {
    assert(rules != null);

    if (rules?.isEmpty ?? false) return null;

    String? errorMsg;

    if (rules!.length == 0) {
      errorMsg = _localizationService.community__rules_empty_error;
    } else if (!isCommunityRulesAllowedLength(rules)) {
      errorMsg = _localizationService
          .community__rules_range_error(COMMUNITY_RULES_MAX_LENGTH);
    }
    return errorMsg;
  }

  String? validateCommunityDescription(String? description) {
    assert(description != null);

    if (description!.isEmpty) return null;

    String? errorMsg;

    if (!isCommunityDescriptionAllowedLength(description)) {
      errorMsg = _localizationService
          .community__description_range_error(COMMUNITY_DESCRIPTION_MAX_LENGTH);
    }
    return errorMsg;
  }

  String? validateCommunityUserAdjective(String? userAdjective) {
    assert(userAdjective != null);

    if (userAdjective!.isEmpty) return null;

    String? errorMsg;

    if (!isCommunityUserAdjectiveAllowedLength(userAdjective)) {
      errorMsg = _localizationService.community__adjectives_range_error(
          COMMUNITY_USER_ADJECTIVE_MAX_LENGTH);
    }

    return errorMsg;
  }
}
