import 'package:Okuna/models/community.dart';

class CommunitiesList {
  final List<Community>? communities;

  CommunitiesList({
    this.communities,
  });

  factory CommunitiesList.fromJson(List<dynamic> parsedJson) {
    List<Community> communities = parsedJson
        .map((communityJson) => Community.fromJSON(communityJson))
        .toList();

    return new CommunitiesList(
      communities: communities,
    );
  }
}
