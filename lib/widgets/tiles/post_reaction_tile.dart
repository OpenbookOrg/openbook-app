import 'package:Okuna/models/post_reaction.dart';
import 'package:Okuna/widgets/avatars/avatar.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:flutter/material.dart';

class OBPostReactionTile extends StatelessWidget {
  final PostReaction? postReaction;
  final ValueChanged<PostReaction?>? onPostReactionTilePressed;

  const OBPostReactionTile(
      {Key? key, this.postReaction, this.onPostReactionTilePressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var reactor = postReaction?.reactor;

    return ListTile(
      onTap: () {
        if (onPostReactionTilePressed != null)
          onPostReactionTilePressed!(postReaction);
      },
      leading: OBAvatar(
        size: OBAvatarSize.medium,
        avatarUrl: reactor?.getProfileAvatar(),
      ),
      title: OBText(
        reactor?.username ?? '',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
