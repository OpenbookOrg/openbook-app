import 'package:Okuna/models/user.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/user.dart';
import 'package:Okuna/widgets/alerts/button_alert.dart';
import 'package:Okuna/widgets/icon.dart';
import 'package:Okuna/widgets/posts_stream/posts_stream.dart';
import 'package:Okuna/widgets/tiles/loading_indicator_tile.dart';
import 'package:Okuna/widgets/tiles/retry_tile.dart';
import 'package:flutter/material.dart';

class OBCommunityPostsStreamStatusIndicator extends StatelessWidget {
  final VoidCallback streamRefresher;
  final OBPostsStreamStatus? streamStatus;
  final List<Widget>? streamPrependedItems;

  OBCommunityPostsStreamStatusIndicator({
    required this.streamRefresher,
    this.streamStatus,
    this.streamPrependedItems,
  });

  @override
  Widget build(BuildContext context) {
    Widget statusIndicator;

    switch (streamStatus) {
      case OBPostsStreamStatus.loadingMore:
      case OBPostsStreamStatus.refreshing:
        statusIndicator = const Padding(
          padding: const EdgeInsets.all(20),
          child: const OBLoadingIndicatorTile(),
        );
        break;
      case OBPostsStreamStatus.empty:
        statusIndicator = _buildEmptyIndicator(context);
        break;
      case OBPostsStreamStatus.loadingMoreFailed:
        var provider = OpenbookProvider.of(context);
        statusIndicator = OBRetryTile(
          text: provider.localizationService.community__retry_loading_posts,
          onWantsToRetry: streamRefresher,
        );
        break;
      default:
        statusIndicator = const SizedBox();
    }

    return statusIndicator;
  }

  Widget _buildEmptyIndicator(BuildContext context) {
    var provider = OpenbookProvider.of(context);

    LocalizationService localizationService = provider.localizationService;

    return OBButtonAlert(
      text: localizationService.posts_stream__status_tile_empty,
      onPressed: streamRefresher,
      buttonText: localizationService.post__trending_posts_refresh,
      buttonIcon: OBIcons.refresh,
      assetImage: 'assets/images/stickers/perplexed-owl.png',
    );
  }
}
