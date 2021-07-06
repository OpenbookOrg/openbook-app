import 'package:Okuna/models/community.dart';
import 'package:Okuna/models/hashtag.dart';
import 'package:Okuna/models/moderation/moderated_object.dart';
import 'package:Okuna/models/post_comment.dart';
import 'package:Okuna/pages/home/pages/post_comments/widgets/post_comment/post_comment.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/widgets/post/widgets/post-body/post_body.dart';
import 'package:Okuna/widgets/post/widgets/post_header/post_header.dart';
import 'package:Okuna/widgets/tiles/community_tile.dart';
import 'package:Okuna/widgets/tiles/hashtag_tile.dart';
import 'package:Okuna/widgets/tiles/user_tile.dart';
import 'package:flutter/material.dart';

class OBModeratedObjectPreview extends StatelessWidget {
  final ModeratedObject moderatedObject;

  const OBModeratedObjectPreview({Key? key, required this.moderatedObject})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget widget;

    switch (moderatedObject.type) {
      case ModeratedObjectType.post:
        widget = Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            OBPostHeader(
              post: moderatedObject.contentObject,
              hasActions: false,
            ),
            OBPostBody(moderatedObject.contentObject),
          ],
        );
        break;
      case ModeratedObjectType.community:
        widget = Padding(
          padding: EdgeInsets.all(10),
          child: OBCommunityTile(
            moderatedObject.contentObject,
            onCommunityTilePressed: (Community community) {
              OpenbookProviderState openbookProvider =
                  OpenbookProvider.of(context);
              openbookProvider.navigationService
                  .navigateToCommunity(community: community, context: context);
            },
          ),
        );
        break;
      case ModeratedObjectType.hashtag:
        widget = Padding(
          padding: EdgeInsets.all(10),
          child: OBHashtagTile(
            moderatedObject.contentObject,
            onHashtagTilePressed: (Hashtag hashtag) {
              OpenbookProviderState openbookProvider =
                  OpenbookProvider.of(context);
              openbookProvider.navigationService
                  .navigateToHashtag(hashtag: hashtag, context: context);
            },
          ),
        );
        break;
      case ModeratedObjectType.postComment:
        PostComment postComment = moderatedObject.contentObject;
        widget = Column(
          children: <Widget>[
            OBPostComment(
              post: postComment.post,
              postComment: moderatedObject.contentObject,
            ),
          ],
        );
        break;
      case ModeratedObjectType.user:
        widget = Column(
          children: <Widget>[
            OBUserTile(moderatedObject.contentObject),
          ],
        );
        break;
      default:
        widget = const SizedBox();
    }
    return widget;
  }
}
