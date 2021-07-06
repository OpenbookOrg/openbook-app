import 'package:Okuna/models/moderation/moderation_report.dart';

class ModerationReportsList {
  final List<ModerationReport>? moderationReports;

  ModerationReportsList({
    this.moderationReports,
  });

  factory ModerationReportsList.fromJson(List<dynamic> parsedJson) {
    List<ModerationReport> moderationReports = parsedJson
        .map((moderationReportJson) =>
            ModerationReport.fromJson(moderationReportJson))
        .toList();

    return new ModerationReportsList(
      moderationReports: moderationReports,
    );
  }
}
