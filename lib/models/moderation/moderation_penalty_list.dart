import 'package:Okuna/models/moderation/moderation_penalty.dart';

class ModerationPenaltiesList {
  final List<ModerationPenalty>? moderationPenalties;

  ModerationPenaltiesList({
    this.moderationPenalties,
  });

  factory ModerationPenaltiesList.fromJson(List<dynamic> parsedJson) {
    List<ModerationPenalty> moderationPenalties = parsedJson
        .map((moderationPenaltyJson) =>
            ModerationPenalty.fromJson(moderationPenaltyJson))
        .toList();

    return new ModerationPenaltiesList(
      moderationPenalties: moderationPenalties,
    );
  }
}
