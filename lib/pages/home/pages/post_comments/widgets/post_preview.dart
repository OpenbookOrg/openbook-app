import 'package:Okuna/models/post.dart';
import 'package:Okuna/widgets/post/widgets/post-actions/post_actions.dart';
import 'package:Okuna/widgets/post/widgets/post-actions/post_actions.dart';
import 'package:Okuna/widgets/post/widgets/post-body/post_body.dart';
import 'package:Okuna/widgets/post/widgets/post_circles.dart';
import 'package:Okuna/widgets/post/widgets/post_comments/post_comments.dart';
import 'package:Okuna/widgets/post/widgets/post_header/post_header.dart';
import 'package:Okuna/widgets/post/widgets/post_reactions.dart';
import 'package:Okuna/widgets/theming/post_divider.dart';
import 'package:flutter/material.dart';

class OBPostPreview extends StatelessWidget {
  final Post post;
  final Function(Post)? onPostDeleted;
  final VoidCallback? focusCommentInput;
  final bool showViewAllCommentsAction;

  OBPostPreview(
      {required this.post,
      this.onPostDeleted,
      this.focusCommentInput,
      this.showViewAllCommentsAction = true});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        OBPostHeader(
          post: this.post,
          onPostDeleted: this.onPostDeleted,
        ),
        OBPostBody(this.post),
        const SizedBox(
          height: 20,
        ),
        OBPostReactions(this.post),
        const SizedBox(
          height: 10,
        ),
        OBPostCircles(this.post),
        showViewAllCommentsAction == true
            ? OBPostComments(
                this.post,
              )
            : SizedBox(),
        OBPostActions(
          this.post,
          onWantsToCommentPost: this.focusCommentInput,
        ),
        const SizedBox(
          height: 16,
        ),
        OBPostDivider()
      ],
    );
  }
}
