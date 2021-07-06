import 'package:Okuna/libs/str_utils.dart';
import 'package:Okuna/models/moderation/moderated_object.dart';
import 'package:Okuna/models/moderation/moderation_category.dart';
import 'package:Okuna/models/user.dart';

class ModerationPenalty {
  static String moderationPenaltyTypeSuspension = 'S';

  final int? id;
  final User? user;
  final DateTime? expiration;
  final ModeratedObject? moderatedObject;
  final ModerationPenaltyType? type;

  ModerationPenalty({
    this.user,
    this.expiration,
    this.moderatedObject,
    this.id,
    this.type,
  });

  factory ModerationPenalty.fromJson(Map<String, dynamic> parsedJson) {
    return ModerationPenalty(
        id: parsedJson['id'],
        user: parseUser(
          parsedJson['user'],
        ),
        type: parseType(
          parsedJson['type'],
        ),
        moderatedObject: parseModeratedObject(
          parsedJson['moderated_object'],
        ),
        expiration: parseExpiration(parsedJson['expiration']));
  }

  static User? parseUser(Map<String, dynamic>? rawActor) {
    if (rawActor == null) return null;
    return User.fromJson(rawActor);
  }

  static ModerationCategory? parseCategory(Map<String, dynamic>? rawModerationCategory) {
    if (rawModerationCategory == null) return null;
    return ModerationCategory.fromJson(rawModerationCategory);
  }

  static DateTime? parseExpiration(String? expiration) {
    if (expiration == null) return null;
    return DateTime.parse(expiration).toLocal();
  }

  static ModeratedObject? parseModeratedObject(Map<String, dynamic>? rawModeratedObject) {
    if (rawModeratedObject == null) return null;
    return ModeratedObject.fromJSON(rawModeratedObject);
  }

  static ModerationPenaltyType? parseType(String? moderationPenaltyTypeStr) {
    if (moderationPenaltyTypeStr == null) return null;

    ModerationPenaltyType? moderationPenaltyType;
    if (moderationPenaltyTypeStr ==
        ModerationPenalty.moderationPenaltyTypeSuspension) {
      moderationPenaltyType = ModerationPenaltyType.suspension;
    } else {
      // Don't throw as we might introduce new moderation penalties on the API which might not be yet in code
      print('Unsupported moderation penalty type');
    }

    return moderationPenaltyType;
  }

  static String convertModerationPenaltyTypeToHumanReadableString(
      ModerationPenaltyType type,
      {bool capitalize = false}) {
    String result;
    switch (type) {
      case ModerationPenaltyType.suspension:
        result = 'Account suspension';
        break;
      default:
        result = 'unknown';
    }
    return capitalize ? toCapital(result) : result;
  }
}

enum ModerationPenaltyType { suspension }
