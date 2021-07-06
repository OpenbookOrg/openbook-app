import 'dart:io';

import 'package:Okuna/widgets/video_player/video_player.dart';
import 'package:Okuna/widgets/video_player/widgets/chewie/chewie_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class OBVideoDialog extends StatelessWidget {
  final File? video;
  final String? videoUrl;
  final ChewieController? chewieController;
  final VideoPlayerController? videoPlayerController;
  final bool autoPlay;

  const OBVideoDialog(
      {Key? key,
      this.video,
      this.videoUrl,
      this.autoPlay = false,
      this.chewieController,
      this.videoPlayerController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        backgroundColor: Colors.black,
        child: SafeArea(
            child: Center(
                child: OBVideoPlayer(
          autoPlay: autoPlay,
          video: video,
          videoUrl: videoUrl,
          videoPlayerController: videoPlayerController,
          chewieController: chewieController,
          isInDialog: true,
        ))));
  }
}
