import 'package:Okuna/models/post_comment_reaction.dart';
import 'package:Okuna/widgets/avatars/avatar.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:flutter/material.dart';

class OBPostCommentReactionTile extends StatelessWidget {
  final PostCommentReaction postCommentReaction;
  final ValueChanged<PostCommentReaction>? onPostCommentReactionTilePressed;

  const OBPostCommentReactionTile(
      {Key? key,
      required this.postCommentReaction,
      required this.onPostCommentReactionTilePressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var reactor = postCommentReaction.reactor!;

    return ListTile(
      onTap: () {
        if (onPostCommentReactionTilePressed != null)
          onPostCommentReactionTilePressed!(postCommentReaction);
      },
      leading: OBAvatar(
        size: OBAvatarSize.medium,
        avatarUrl: reactor.getProfileAvatar(),
      ),
      title: OBText(
        reactor.username!,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
