import 'package:Okuna/models/badge.dart';

class BadgesList {
  final List<Badge>? badges;

  BadgesList({
    this.badges,
  });

  factory BadgesList.fromJson(List<dynamic> parsedJson) {
    List<Badge> badges =
        parsedJson.map((badgeJson) => Badge.fromJson(badgeJson)).toList();

    return new BadgesList(
      badges: badges,
    );
  }
}
