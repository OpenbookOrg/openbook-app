import 'package:Okuna/models/post.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/widgets/post/widgets/post-actions/widgets/post_action_comment.dart';
import 'package:Okuna/widgets/post/widgets/post-actions/widgets/post_action_react.dart';
import 'package:flutter/material.dart';

class OBPostActions extends StatelessWidget {
  final Post _post;
  final VoidCallback? onWantsToCommentPost;

  OBPostActions(this._post, {this.onWantsToCommentPost});

  @override
  Widget build(BuildContext context) {
    List<Widget> postActions = [
      Expanded(child: OBPostActionReact(_post)),
    ];

    bool commentsEnabled = _post.areCommentsEnabled ?? true;

    bool canDisableOrEnableCommentsForPost = false;

    if (!commentsEnabled) {
      OpenbookProviderState openbookProvider = OpenbookProvider.of(context);
      canDisableOrEnableCommentsForPost = openbookProvider.userService
          .getLoggedInUser()
          ?.canDisableOrEnableCommentsForPost(_post) ?? false;
    }

    if (commentsEnabled || canDisableOrEnableCommentsForPost) {
      postActions.addAll([
        const SizedBox(
          width: 20.0,
        ),
        Expanded(
          child: OBPostActionComment(
            _post,
            onWantsToCommentPost: onWantsToCommentPost,
          ),
        ),
      ]);
    }

    return Padding(
        padding: EdgeInsets.only(left: 20.0, top: 10.0, right: 20.0),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.max,
              children: postActions,
            )
          ],
        ));
  }
}
