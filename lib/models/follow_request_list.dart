
import 'follow_request.dart';

class FollowRequestList {
  final List<FollowRequest>? followRequests;

  FollowRequestList({
    this.followRequests,
  });

  factory FollowRequestList.fromJson(List<dynamic> parsedJson) {

    List<FollowRequest> followRequests =
    parsedJson.map((postJson) => FollowRequest.fromJson(postJson)).toList();

    return new FollowRequestList(
      followRequests: followRequests,
    );
  }
}
