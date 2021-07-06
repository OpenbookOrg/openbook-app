import 'package:Okuna/models/community.dart';
import 'package:Okuna/models/post.dart';
import 'package:Okuna/pages/home/bottom_sheets/post_actions.dart';
import 'package:Okuna/widgets/post/post.dart';
import 'package:Okuna/widgets/post/widgets/post_header/widgets/community_post_header/community_post_header.dart';
import 'package:Okuna/widgets/post/widgets/post_header/widgets/user_post_header/user_post_header.dart';
import 'package:flutter/material.dart';

class OBPostHeader extends StatelessWidget {
  final Post post;
  final OnPostDeleted? onPostDeleted;
  final ValueChanged<Post>? onPostReported;
  final bool hasActions;
  final OBPostDisplayContext? displayContext;
  final Function? onCommunityExcluded;
  final Function? onUndoCommunityExcluded;
  final ValueChanged<Community>? onPostCommunityExcludedFromProfilePosts;

  const OBPostHeader({
    Key? key,
    this.onPostDeleted,
    required this.post,
    this.onPostReported,
    this.onCommunityExcluded,
    this.onUndoCommunityExcluded,
    this.hasActions = true,
    this.displayContext = OBPostDisplayContext.timelinePosts,
    this.onPostCommunityExcludedFromProfilePosts,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return post.isCommunityPost() &&
            displayContext != OBPostDisplayContext.communityPosts
        ? OBCommunityPostHeader(post,
            onPostDeleted: onPostDeleted,
            onPostReported: onPostReported,
            hasActions: hasActions,
            onCommunityExcluded: onCommunityExcluded,
            onUndoCommunityExcluded: onUndoCommunityExcluded,
            onPostCommunityExcludedFromProfilePosts:
                onPostCommunityExcludedFromProfilePosts,
            displayContext: displayContext)
        : OBUserPostHeader(post,
            onPostDeleted: onPostDeleted!,
            onPostReported: onPostReported,
            displayContext: displayContext,
            hasActions: hasActions);
  }
}
