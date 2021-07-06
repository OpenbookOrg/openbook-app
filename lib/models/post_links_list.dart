import 'package:Okuna/models/post_link.dart';

class PostLinksList {
  final List<PostLink>? postLinks;

  PostLinksList({
    this.postLinks,
  });

  factory PostLinksList.fromJson(List<dynamic> parsedJson) {
    List<PostLink> postLinks =
        parsedJson.map((postJson) => PostLink.fromJSON(postJson)).toList();

    return new PostLinksList(
      postLinks: postLinks,
    );
  }
}
