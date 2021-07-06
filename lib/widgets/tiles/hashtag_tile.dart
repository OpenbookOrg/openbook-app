import 'package:Okuna/models/hashtag.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/widgets/avatars/hashtag_avatar.dart';
import 'package:Okuna/widgets/hashtag.dart';
import 'package:Okuna/widgets/posts_count.dart';
import 'package:flutter/material.dart';


class OBHashtagTile extends StatelessWidget {
  final Hashtag hashtag;
  final ValueChanged<Hashtag>? onHashtagTilePressed;
  final ValueChanged<Hashtag>? onHashtagTileDeleted;

  const OBHashtagTile(this.hashtag,
      {Key? key,
      this.onHashtagTilePressed,
      this.onHashtagTileDeleted})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget tile = ListTile(
      onTap: () {
        if (onHashtagTilePressed != null) onHashtagTilePressed!(hashtag);
      },
      leading: OBHashtagAvatar(
        key: Key('Avatar-${hashtag.name}'),
        hashtag: hashtag,
        size: OBAvatarSize.medium,
      ),
      title: Row(children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 15),
          child: OBHashtag(
            hashtag: hashtag,
          ),
        )
      ]),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: OBPostsCount(
              hashtag.postsCount,
              showZero: true,
            ),
          )
        ],
      )
    );
    return tile;
  }

}
