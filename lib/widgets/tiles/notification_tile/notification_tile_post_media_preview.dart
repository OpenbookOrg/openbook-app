import 'package:Okuna/models/post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_advanced_networkimage/transition.dart';

class OBNotificationTilePostMediaPreview extends StatelessWidget {
  static final double postMediaPreviewSize = 40;
  final Post post;

  const OBNotificationTilePostMediaPreview({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: SizedBox(
          height: postMediaPreviewSize,
          width: postMediaPreviewSize,
          child: TransitionToImage(
            loadingWidget: const SizedBox(),
            fit: BoxFit.cover,
            alignment: Alignment.center,
            image: AdvancedNetworkImage(post.mediaThumbnail ?? '',
                useDiskCache: true,
                fallbackAssetImage: 'assets/images/fallbacks/post-fallback.png',
                retryLimit: 3,
                timeoutDuration: const Duration(seconds: 5)),
            duration: Duration(milliseconds: 300),
          ),
        ));
  }
}
