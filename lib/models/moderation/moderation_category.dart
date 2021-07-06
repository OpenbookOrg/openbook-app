class ModerationCategory {
  static final severityCritical = 'C';
  static final severityHigh = 'H';
  static final severityMedium = 'M';
  static final severityLow = 'L';

  static ModerationCategorySeverity? parseType(String? notificationTypeStr) {
    if (notificationTypeStr == null) return null;

    ModerationCategorySeverity? notificationType;
    if (notificationTypeStr == ModerationCategory.severityCritical) {
      notificationType = ModerationCategorySeverity.critical;
    } else if (notificationTypeStr == ModerationCategory.severityHigh) {
      notificationType = ModerationCategorySeverity.high;
    } else if (notificationTypeStr == ModerationCategory.severityMedium) {
      notificationType = ModerationCategorySeverity.medium;
    } else if (notificationTypeStr == ModerationCategory.severityLow) {
      notificationType = ModerationCategorySeverity.low;
    } else {
      // Don't throw as we might introduce new notifications on the API which might not be yet in code
      print('Unsupported notification type');
    }

    return notificationType;
  }

  final int? id;
  final ModerationCategorySeverity? severity;
  final String? name;
  final String? title;
  final String? description;

  ModerationCategory(
      {this.id, this.severity, this.name, this.title, this.description});

  factory ModerationCategory.fromJson(Map<String, dynamic> parsedJson) {
    return ModerationCategory(
        id: parsedJson['id'],
        name: parsedJson['name'],
        title: parsedJson['title'],
        description: parsedJson['description'],
        severity: parseType(parsedJson['type']));
  }
}

enum ModerationCategorySeverity {
  critical,
  high,
  medium,
  low,
}
