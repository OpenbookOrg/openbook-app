import 'package:Okuna/widgets/load_more.dart';
import 'package:Okuna/widgets/tiles/loading_indicator_tile.dart';
import 'package:Okuna/widgets/tiles/retry_tile.dart';
import 'package:flutter/material.dart';

class OBHomePostsLoadMoreDelegate extends LoadMoreDelegate {
  const OBHomePostsLoadMoreDelegate();

  @override
  Widget buildChild(LoadMoreStatus status,
      {LoadMoreTextBuilder builder = DefaultLoadMoreTextBuilder.chinese}) {
    String text = builder(status);

    if (status == LoadMoreStatus.fail) {
      return OBRetryTile(text: 'Tap to retry loading posts', onWantsToRetry: () {},);
    }
    if (status == LoadMoreStatus.idle) {
      // No clue why is this even a state.
      return const SizedBox();
    }
    if (status == LoadMoreStatus.loading) {
      return OBLoadingIndicatorTile();
    }
    if (status == LoadMoreStatus.nomore) {
      return const SizedBox();
    }

    return Text(text);
  }
}
