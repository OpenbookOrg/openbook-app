import 'package:Okuna/models/moderation/moderated_object.dart';
import 'package:Okuna/models/moderation/moderation_category.dart';
import 'package:Okuna/models/user.dart';
import 'package:meta/meta.dart';

class ModeratedObjectLog {
  static String descriptionChangedLogType = 'DC';
  static String statusChangedLogType = 'AC';
  static String verifiedChangedLogType = 'VC';
  static String categoryChangedLogType = 'CC';

  final int? id;
  final String? description;
  final bool? verified;
  final User? actor;
  final DateTime? created;
  ModeratedObjectLogType? logType;

  dynamic contentObject;

  ModeratedObjectLog(
      {this.verified,
      this.id,
      this.description,
      this.contentObject,
      this.actor,
      this.created,
      this.logType});

  factory ModeratedObjectLog.fromJson(Map<String, dynamic> parsedJson) {
    ModeratedObjectLogType? logType = parseType(parsedJson['log_type']);

    return ModeratedObjectLog(
        verified: parsedJson['verified'],
        id: parsedJson['id'],
        description: parsedJson['description'],
        actor: parseActor(
          parsedJson['actor'],
        ),
        logType: logType,
        created: parseCreated(parsedJson['created']),
        contentObject: parseContentObject(
            contentObjectData: parsedJson['content_object'], logType: logType));
  }

  static User? parseActor(Map<String, dynamic>? rawActor) {
    if (rawActor == null) return null;
    return User.fromJson(rawActor);
  }

  static DateTime? parseCreated(String? created) {
    if (created == null) return null;
    return DateTime.parse(created).toLocal();
  }

  static dynamic parseContentObject(
      {required Map<String, dynamic>? contentObjectData,
      required ModeratedObjectLogType? logType}) {
    if (contentObjectData == null) return null;

    dynamic contentObject;
    switch (logType) {
      case ModeratedObjectLogType.categoryChanged:
        contentObject =
            ModeratedObjectCategoryChangedLog.fromJson(contentObjectData);
        break;
      case ModeratedObjectLogType.descriptionChanged:
        contentObject =
            ModeratedObjectDescriptionChangedLog.fromJson(contentObjectData);
        break;
      case ModeratedObjectLogType.verifiedChanged:
        contentObject =
            ModeratedObjectVerifiedChangedLog.fromJson(contentObjectData);
        break;
      case ModeratedObjectLogType.statusChanged:
        contentObject =
            ModeratedObjectStatusChangedLog.fromJson(contentObjectData);
        break;
      default:
    }

    return contentObject;
  }

  static ModeratedObjectLogType? parseType(String? moderatedObjectTypeStr) {
    if (moderatedObjectTypeStr == null) return null;

    ModeratedObjectLogType? moderatedObjectLogType;
    if (moderatedObjectTypeStr ==
        ModeratedObjectLog.descriptionChangedLogType) {
      moderatedObjectLogType = ModeratedObjectLogType.descriptionChanged;
    } else if (moderatedObjectTypeStr ==
        ModeratedObjectLog.statusChangedLogType) {
      moderatedObjectLogType = ModeratedObjectLogType.statusChanged;
    } else if (moderatedObjectTypeStr ==
        ModeratedObjectLog.verifiedChangedLogType) {
      moderatedObjectLogType = ModeratedObjectLogType.verifiedChanged;
    } else if (moderatedObjectTypeStr ==
        ModeratedObjectLog.categoryChangedLogType) {
      moderatedObjectLogType = ModeratedObjectLogType.categoryChanged;
    } else {
      print('Unsupported moderatedObjectLog type');
    }

    return moderatedObjectLogType;
  }
}

enum ModeratedObjectLogType {
  descriptionChanged,
  verifiedChanged,
  statusChanged,
  categoryChanged,
}

class ModeratedObjectCategoryChangedLog {
  final ModerationCategory? changedFrom;
  final ModerationCategory? changedTo;

  ModeratedObjectCategoryChangedLog({this.changedFrom, this.changedTo});

  factory ModeratedObjectCategoryChangedLog.fromJson(
      Map<String, dynamic> parsedJson) {
    return ModeratedObjectCategoryChangedLog(
      changedFrom: parseCategory(parsedJson['changed_from']),
      changedTo: parseCategory(parsedJson['changed_to']),
    );
  }

  static ModerationCategory? parseCategory(Map<String, dynamic>? rawModerationCategory) {
    if (rawModerationCategory == null) return null;
    return ModerationCategory.fromJson(rawModerationCategory);
  }
}

class ModeratedObjectDescriptionChangedLog {
  final String? changedFrom;
  final String? changedTo;

  ModeratedObjectDescriptionChangedLog({this.changedFrom, this.changedTo});

  factory ModeratedObjectDescriptionChangedLog.fromJson(
      Map<String, dynamic> parsedJson) {
    return ModeratedObjectDescriptionChangedLog(
      changedFrom: parsedJson['changed_from'],
      changedTo: parsedJson['changed_to'],
    );
  }
}

class ModeratedObjectVerifiedChangedLog {
  final bool? changedFrom;
  final bool? changedTo;

  ModeratedObjectVerifiedChangedLog({this.changedFrom, this.changedTo});

  factory ModeratedObjectVerifiedChangedLog.fromJson(
      Map<String, dynamic> parsedJson) {
    return ModeratedObjectVerifiedChangedLog(
      changedFrom: parsedJson['changed_from'],
      changedTo: parsedJson['changed_to'],
    );
  }
}

class ModeratedObjectStatusChangedLog {
  final ModeratedObjectStatus? changedFrom;
  final ModeratedObjectStatus? changedTo;

  ModeratedObjectStatusChangedLog({this.changedFrom, this.changedTo});

  factory ModeratedObjectStatusChangedLog.fromJson(
      Map<String, dynamic> parsedJson) {
    return ModeratedObjectStatusChangedLog(
      changedFrom: parseStatus(parsedJson['changed_from']),
      changedTo: parseStatus(parsedJson['changed_to']),
    );
  }

  static ModeratedObjectStatus? parseStatus(String? rawModerationStatus) {
    if (rawModerationStatus == null) return null;
    return ModeratedObject.factory.parseStatus(rawModerationStatus);
  }
}
