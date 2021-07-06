import 'package:Okuna/models/moderation/moderated_object.dart';
import 'package:Okuna/models/moderation/moderation_category.dart';
import 'package:Okuna/models/user.dart';

class ModerationReport {
  final ModerationCategory? category;
  final String? description;
  final User? reporter;
  final DateTime? created;

  ModerationReport(
      {this.description, this.reporter, this.category, this.created});

  factory ModerationReport.fromJson(Map<String, dynamic> parsedJson) {
    return ModerationReport(
        description: parsedJson['description'],
        reporter: parseReporter(
          parsedJson['reporter'],
        ),
        category: parseCategory(
          parsedJson['category'],
        ),
        created: parseCreated(parsedJson['created']));
  }

  static User? parseReporter(Map<String, dynamic>? rawActor) {
    if (rawActor == null) return null;
    return User.fromJson(rawActor);
  }

  static ModerationCategory? parseCategory(Map<String, dynamic>? rawModerationCategory) {
    if (rawModerationCategory == null) return null;
    return ModerationCategory.fromJson(rawModerationCategory);
  }

  static DateTime? parseCreated(String? created) {
    if (created == null) return null;
    return DateTime.parse(created).toLocal();
  }
}
