import 'package:Okuna/models/emoji.dart';
import 'package:Okuna/models/post.dart';
import 'package:Okuna/models/post_reaction.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/navigation_service.dart';
import 'package:Okuna/services/toast.dart';
import 'package:Okuna/services/user.dart';
import 'package:Okuna/widgets/progress_indicator.dart';
import 'package:Okuna/widgets/tiles/post_reaction_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Okuna/widgets/load_more.dart';

class OBPostReactionList extends StatefulWidget {
  // The emoji to show reactions of
  final Emoji? emoji;

  // The post to show reactions of
  final Post? post;

  const OBPostReactionList({Key? key, this.emoji, this.post}) : super(key: key);

  @override
  OBPostReactionListState createState() {
    return OBPostReactionListState();
  }
}

class OBPostReactionListState extends State<OBPostReactionList> {
  late UserService _userService;
  late ToastService _toastService;
  late NavigationService _navigationService;
  late LocalizationService _localizationService;

  late List<PostReaction> _postReactions;

  late bool _needsBootstrap;
  late bool _loadMoreFinished;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _needsBootstrap = true;
    _loadMoreFinished = false;
    _postReactions = [];
  }

  @override
  Widget build(BuildContext context) {
    if (_needsBootstrap) {
      var openbookProvider = OpenbookProvider.of(context);
      _userService = openbookProvider.userService;
      _toastService = openbookProvider.toastService;
      _navigationService = openbookProvider.navigationService;
      _localizationService = openbookProvider.localizationService;
      _bootstrap();
      _needsBootstrap = false;
    }

    return RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _onRefresh,
        child: LoadMore(
            whenEmptyLoad: false,
            isFinish: _loadMoreFinished,
            delegate: OBPostReactionListLoadMoreDelegate(_localizationService),
            child: ListView.builder(
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.all(0),
                itemCount: _postReactions.length,
                itemBuilder: (context, index) {
                  var postReaction = _postReactions[index];
                  return OBPostReactionTile(
                    postReaction: postReaction,
                    key: Key(
                      postReaction.id.toString(),
                    ),
                    onPostReactionTilePressed: _onPostReactionTilePressed,
                  );
                }),
            onLoadMore: _loadMorePostReactions));
  }

  Future<void> _onRefresh() {
    return _refreshPostReactions();
  }

  Future<void> _refreshPostReactions() async {
    var reactionsList = await _userService.getReactionsForPost(widget.post!,
        emoji: widget.emoji);

    _setPostReactions(reactionsList.reactions);
  }

  Future<bool> _loadMorePostReactions() async {
    var lastReaction = _postReactions.last;
    var lastReactionId = lastReaction.id;
    try {
      var moreReactions = (await _userService.getReactionsForPost(widget.post!,
              maxId: lastReactionId, emoji: widget.emoji))
          .reactions;

      if (moreReactions != null && moreReactions.length == 0) {
        _setLoadMoreFinished(true);
      } else {
        _addPostReactions(moreReactions ?? []);
      }
      return true;
    } catch (error) {
      _onError(error);
    }

    return false;
  }

  void _onError(error) async {
    if (error is HttpieConnectionRefusedError) {
      _toastService.error(
          message: error.toHumanReadableMessage(), context: context);
    } else if (error is HttpieRequestError) {
      String? errorMessage = await error.toHumanReadableMessage();
      _toastService.error(message: errorMessage ?? _localizationService.trans('error__unknown_error'), context: context);
    } else {
      _toastService.error(message: _localizationService.trans('error__unknown_error'), context: context);
      throw error;
    }
  }

  void _onPostReactionTilePressed(PostReaction? postReaction) {
    if (postReaction == null) {
      return;
    }

    _navigationService.navigateToUserProfile(
        user: postReaction.reactor!, context: context);
  }

  void _setPostReactions(List<PostReaction>? reactions) {
    if (reactions == null) {
      return;
    }

    setState(() {
      _postReactions = reactions;
    });
  }

  void _addPostReactions(List<PostReaction> reactions) {
    setState(() {
      _postReactions.addAll(reactions);
    });
  }

  void _setLoadMoreFinished(bool loadMoreFinished) {
    setState(() {
      _loadMoreFinished = loadMoreFinished;
    });
  }

  void _bootstrap() {
    _refreshPostReactions();
  }
}

class OBPostReactionListLoadMoreDelegate extends LoadMoreDelegate {
  LocalizationService localizationService;
  OBPostReactionListLoadMoreDelegate(this.localizationService);

  @override
  Widget buildChild(LoadMoreStatus status,
      {LoadMoreTextBuilder builder = DefaultLoadMoreTextBuilder.chinese}){
    String text = builder(status);

    if (status == LoadMoreStatus.fail) {
      return SizedBox(
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.refresh),
            const SizedBox(
              width: 10.0,
            ),
            Text(localizationService.trans('post__reaction_list_tap_retry'))
          ],
        ),
      );
    }
    if (status == LoadMoreStatus.idle) {
      // No clue why is this even a state.
      return const SizedBox();
    }
    if (status == LoadMoreStatus.loading) {
      return SizedBox(
          child: Center(
        child: OBProgressIndicator(),
      ));
    }
    if (status == LoadMoreStatus.nomore) {
      return const SizedBox();
    }

    return Text(text);
  }
}
