import 'dart:ui';

import 'package:Okuna/widgets/video_player/widgets/chewie/chewie_player.dart';
import 'package:Okuna/widgets/video_player/widgets/chewie/cupertino_controls.dart';
import 'package:Okuna/widgets/video_player/widgets/chewie/material_controls.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class PlayerWithControls extends StatelessWidget {
  final height;
  final width;
  final bool isConstrained;

  const PlayerWithControls(
      {Key? key, this.height, this.width, this.isConstrained = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ChewieController chewieController = ChewieController.of(context);

    return Center(
      child: Container(
          width: MediaQuery.of(context).size.width,
          child: _buildPlayerWithControls(chewieController, context)),
    );
  }

  Container _buildPlayerWithControls(
      ChewieController chewieController, BuildContext context) {
    double containerWidth = width ?? MediaQuery.of(context).size.width;
    bool hasHeight = height != null;

    double aspectRatio =
        chewieController.aspectRatio ?? _calculateAspectRatio(context);

    double containerHeight = (containerWidth / aspectRatio);

    Widget videoWidget = Hero(
        tag: chewieController.videoPlayerController,
        child: AspectRatio(
            aspectRatio: aspectRatio,
            child: VideoPlayer(chewieController.videoPlayerController)));

    return Container(
      height: height ?? null,
      child: Stack(
        children: <Widget>[
          chewieController.placeholder ?? const SizedBox(),
          hasHeight && isConstrained
              ? Positioned(
                  top: -((containerHeight - height) / 2),
                  height: containerHeight,
                  width: containerWidth,
                  child: videoWidget,
                )
              : Center(
                  child: videoWidget,
                ),
          chewieController.overlay ?? Container(),
          _buildControls(context, chewieController),
        ],
      ),
    );
  }

  Widget _buildControls(
    BuildContext context,
    ChewieController chewieController,
  ) {
    return chewieController.showControls
        ? chewieController.customControls != null
            ? chewieController.customControls!
            : Theme.of(context).platform == TargetPlatform.android
                ? MaterialControls()
                : CupertinoControls(
                    backgroundColor: Color.fromRGBO(41, 41, 41, 0.7),
                    iconColor: Color.fromARGB(255, 200, 200, 200),
                  )
        : Container();
  }

  double _calculateAspectRatio(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return width > height ? width / height : height / width;
  }
}
