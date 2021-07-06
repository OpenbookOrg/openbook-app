import 'package:Okuna/models/emoji.dart';
import 'package:Okuna/models/post.dart';
import 'package:Okuna/models/post_comment.dart';
import 'package:Okuna/models/post_comment_reaction.dart';
import 'package:Okuna/models/post_comment_reaction_list.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/navigation_service.dart';
import 'package:Okuna/services/user.dart';
import 'package:Okuna/widgets/http_list.dart';
import 'package:Okuna/widgets/tiles/post_comment_reaction_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OBPostCommentReactionList extends StatefulWidget {
  // The emoji to show reactions of
  final Emoji emoji;

  // The postComment to show reactions of
  final PostComment postComment;

  final Post post;

  const OBPostCommentReactionList(
      {Key? key,
      required this.emoji,
      required this.postComment,
      required this.post})
      : super(key: key);

  @override
  OBPostCommentReactionListState createState() {
    return OBPostCommentReactionListState();
  }
}

class OBPostCommentReactionListState extends State<OBPostCommentReactionList> {
  late UserService _userService;
  late NavigationService _navigationService;

  late bool _needsBootstrap;

  late OBHttpListController _httpListController;

  @override
  void initState() {
    super.initState();
    _needsBootstrap = true;
    _httpListController = OBHttpListController();
  }

  @override
  Widget build(BuildContext context) {
    if (_needsBootstrap) {
      var provider = OpenbookProvider.of(context);
      _userService = provider.userService;
      _navigationService = provider.navigationService;
      _needsBootstrap = false;
    }

    return OBHttpList<PostCommentReaction>(
      controller: _httpListController,
      listItemBuilder: _buildPostCommentReactionListItem,
      searchResultListItemBuilder: _buildPostCommentReactionListItem,
      listRefresher: _refreshPostCommentReactions,
      listOnScrollLoader: _loadMorePostCommentReactions,
      resourceSingularName: 'comment reaction',
      resourcePluralName: 'comment reactions',
    );
  }

  Widget _buildPostCommentReactionListItem(
      BuildContext context, PostCommentReaction postCommentReaction) {
    return OBPostCommentReactionTile(
      postCommentReaction: postCommentReaction,
      onPostCommentReactionTilePressed: _onPostCommentReactionListItemPressed,
    );
  }

  void _onPostCommentReactionListItemPressed(
      PostCommentReaction postCommentReaction) {
    _navigationService.navigateToUserProfile(
        user: postCommentReaction.reactor!, context: context);
  }

  Future<List<PostCommentReaction>> _refreshPostCommentReactions() async {
    PostCommentReactionList postCommentReactions =
        await _userService.getReactionsForPostComment(
            post: widget.post,
            postComment: widget.postComment,
            emoji: widget.emoji);
    return postCommentReactions.reactions!;
  }

  Future<List<PostCommentReaction>> _loadMorePostCommentReactions(
      List<PostCommentReaction> postCommentReactionsList) async {
    PostCommentReaction lastPostCommentReaction = postCommentReactionsList.last;
    int? lastPostCommentReactionId = lastPostCommentReaction.id;
    List<PostCommentReaction> morePostCommentReactions =
        (await _userService.getReactionsForPostComment(
      post: widget.post,
      postComment: widget.postComment,
      maxId: lastPostCommentReactionId,
      emoji: widget.emoji,
      count: 20,
    ))
            .reactions!;
    return morePostCommentReactions;
  }
}
