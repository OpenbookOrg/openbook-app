import 'package:Okuna/models/community.dart';
import 'package:Okuna/models/post.dart';
import 'package:Okuna/widgets/post/widgets/post-actions/post_actions.dart';
import 'package:Okuna/widgets/post/widgets/post-body/post_body.dart';
import 'package:Okuna/widgets/post/widgets/post-body/widgets/post_body_text.dart';
import 'package:Okuna/widgets/post/widgets/post_circles.dart';
import 'package:Okuna/widgets/post/widgets/post_comments/post_comments.dart';
import 'package:Okuna/widgets/post/widgets/post_header/post_header.dart';
import 'package:Okuna/widgets/post/widgets/post_reactions.dart';
import 'package:Okuna/widgets/theming/post_divider.dart';
import 'package:flutter/material.dart';
import 'package:inview_notifier_list/inview_notifier_list.dart';

class OBPost extends StatelessWidget {
  final Post post;
  final ValueChanged<Post> onPostDeleted;
  final ValueChanged<Post>? onPostIsInView;
  final OnTextExpandedChange? onTextExpandedChange;
  final String? inViewId;
  final Function? onCommunityExcluded;
  final Function? onUndoCommunityExcluded;
  final ValueChanged<Community>? onPostCommunityExcludedFromProfilePosts;
  final OBPostDisplayContext displayContext;

  const OBPost(this.post,
      {Key? key,
      required this.onPostDeleted,
      this.onPostIsInView,
      this.onCommunityExcluded,
      this.onUndoCommunityExcluded,
      this.onTextExpandedChange,
      this.inViewId,
      this.displayContext = OBPostDisplayContext.timelinePosts,
      this.onPostCommunityExcludedFromProfilePosts})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String? postInViewId;
    if (this.displayContext == OBPostDisplayContext.topPosts)
      postInViewId = (inViewId ?? '') + '_' + post.id.toString();

    _bootstrap(context, postInViewId);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        OBPostHeader(
          post: post,
          onPostDeleted: onPostDeleted,
          onPostReported: onPostDeleted,
          displayContext: displayContext,
          onCommunityExcluded: onCommunityExcluded,
          onUndoCommunityExcluded: onUndoCommunityExcluded,
          onPostCommunityExcludedFromProfilePosts:
              onPostCommunityExcludedFromProfilePosts,
        ),
        OBPostBody(post,
            onTextExpandedChange: onTextExpandedChange, inViewId: inViewId),
        OBPostReactions(post),
        OBPostCircles(post),
        OBPostComments(
          post,
        ),
        OBPostActions(
          post,
        ),
        const SizedBox(
          height: 16,
        ),
        OBPostDivider(),
      ],
    );
  }

  void _bootstrap(BuildContext context, String? postInViewId) {
    InViewState? _inViewState;
    if (postInViewId != null) {
      _inViewState = InViewNotifierList.of(context);
      _inViewState!.addContext(context: context, id: postInViewId);

      if (this.displayContext == OBPostDisplayContext.topPosts) {
        _inViewState.addListener(
            () => _onInViewStateChanged(_inViewState!, postInViewId));
      }
    }
  }

  void _onInViewStateChanged(InViewState _inViewState, String postInViewId) {
    final bool isInView = _inViewState.inView(postInViewId);
    if (isInView) {
      if (onPostIsInView != null) onPostIsInView!(post);
    }
  }
}

enum OBPostDisplayContext {
  timelinePosts,
  topPosts,
  communityPosts,
  foreignProfilePosts,
  ownProfilePosts
}
