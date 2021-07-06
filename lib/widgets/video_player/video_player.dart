import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:retry/retry.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/user_preferences.dart';
import 'package:Okuna/widgets/video_player/widgets/chewie/chewie_player.dart';
import 'package:Okuna/widgets/video_player/widgets/video_player_controls.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../progress_indicator.dart';

var rng = new Random();

class OBVideoPlayer extends StatefulWidget {
  final File? video;
  final String? videoUrl;
  final String? thumbnailUrl;
  final Key? visibilityKey;
  final ChewieController? chewieController;
  final VideoPlayerController? videoPlayerController;
  final bool? isInDialog;
  final bool autoPlay;
  final OBVideoPlayerController? controller;
  final double? height;
  final double? width;
  final bool? isConstrained;

  const OBVideoPlayer(
      {Key? key,
      this.video,
      this.videoUrl,
      this.thumbnailUrl,
      this.chewieController,
      this.videoPlayerController,
      this.isInDialog = false,
      this.autoPlay = false,
      this.visibilityKey,
      this.height,
      this.width,
      this.controller,
      this.isConstrained})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return OBVideoPlayerState();
  }
}

class OBVideoPlayerState extends State<OBVideoPlayer> {
  VideoPlayerController? _playerController;
  ChewieController? _chewieController;
  late OBVideoPlayerControlsController _obVideoPlayerControlsController;
  late UserPreferencesService _userPreferencesService;
  late OBVideoPlayerController _controller;

  late bool _videoInitialized;
  late bool _needsChewieBootstrap;

  late bool _isVideoHandover;
  late bool _hasVideoOpenedInDialog;
  late bool _isPausedDueToInvisibility;
  late bool _isPausedByUser;
  late bool _needsBootstrap;

  late Key _visibilityKey;

  StreamSubscription? _videosSoundSettingsChangeSubscription;

  late Future _videoPreparationFuture;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller == null
        ? OBVideoPlayerController()
        : widget.controller!;
    _controller.attach(this);
    _obVideoPlayerControlsController = OBVideoPlayerControlsController();
    _hasVideoOpenedInDialog = widget.isInDialog ?? false;
    _needsChewieBootstrap = true;
    _isPausedDueToInvisibility = false;
    _isPausedByUser = false;
    _needsBootstrap = true;
    _videoInitialized = false;

    _isVideoHandover =
        widget.videoPlayerController != null && widget.chewieController != null;

    String visibilityKeyFallback;

    if (widget.videoUrl != null) {
      visibilityKeyFallback = widget.videoUrl!;
    } else if (widget.video != null) {
      visibilityKeyFallback = widget.video!.path;
    } else if (widget.videoPlayerController != null) {
      visibilityKeyFallback = widget.videoPlayerController!.dataSource!;
    } else {
      throw Exception(
          'Video dialog requires video, videoUrl or videoPlayerController.');
    }

    visibilityKeyFallback += '-${rng.nextInt(1000)}';

    _visibilityKey = widget.visibilityKey != null
        ? widget.visibilityKey!
        : Key(visibilityKeyFallback);

    _videoPreparationFuture = _prepareVideo();
  }

  @override
  void dispose() {
    super.dispose();
    if (!_isVideoHandover && mounted && !_hasVideoOpenedInDialog) {
      _videosSoundSettingsChangeSubscription?.cancel();
      if (_playerController != null) _playerController!.dispose();
      if (_chewieController != null) _chewieController!.dispose();
    }
  }

  void _onUserPreferencesVideosSoundSettingsChange(
      VideosSoundSetting? newVideosSoundSettings) {
    if (newVideosSoundSettings == VideosSoundSetting.enabled) {
      _playerController?.setVolume(100);
    } else {
      _playerController?.setVolume(0);
    }
  }

  Future _prepareVideo() async {
    if (_isVideoHandover) {
      _playerController = widget.videoPlayerController;
      _chewieController = widget.chewieController;
      debugLog('Not initializing video player as it is handover');
      _videoInitialized = true;
      return;
    }

    await retry(
      () => _initializeVideo(),
      retryIf: (e) {
        debugLog('Checking retry condition');
        bool willRetry = e is SocketException ||
            e is TimeoutException ||
            e is OBVideoPlayerInitializationException;
        if (willRetry) debugLog('Retrying video initializing');
        return willRetry;
      },
    );
  }

  Future _initializeVideo() async {
    if (widget.videoUrl != null) {
      _playerController = VideoPlayerController.network(widget.videoUrl);
    } else if (widget.video != null) {
      _playerController = VideoPlayerController.file(widget.video!);
    } else if (widget.videoPlayerController != null) {
      _playerController = widget.videoPlayerController;
    } else {
      throw Exception(
          'Failed to initialize video. Video dialog requires video, videoUrl or videoPlayerController.');
    }

    _playerController?.setVolume(0);

    debugLog('Initializing video player');
    await _playerController?.initialize().timeout(Duration(seconds: 2));
    if (_playerController?.value.hasError == true) {
      debugLog('Player controller has error');
      throw OBVideoPlayerInitializationException('Player controller had error');
    }

    if (_controller._attemptedToPlayWhileNotReady) _playerController?.play();

    if (mounted) {
      setState(() {
        _videoInitialized = true;
      });
    }
  }

  void _bootstrap() async {
    await _videoPreparationFuture;
    VideosSoundSetting? videosSoundSetting =
        await _userPreferencesService.getVideosSoundSetting();
    _onUserPreferencesVideosSoundSettingsChange(videosSoundSetting);

    _videosSoundSettingsChangeSubscription = _userPreferencesService
        .videosSoundSettingChange
        .listen(_onUserPreferencesVideosSoundSettingsChange);
  }

  @override
  Widget build(BuildContext context) {
    if (_needsBootstrap) {
      OpenbookProviderState openbookProvider = OpenbookProvider.of(context);
      _userPreferencesService = openbookProvider.userPreferencesService;
      _bootstrap();
      _needsBootstrap = false;
    }

    return _videoInitialized ? _buildVideoPlayer() : _buildLoadingIndicator();
  }

  Widget _buildVideoPlayer() {
    if (_needsChewieBootstrap) {
      _chewieController = _getChewieController();
      _needsChewieBootstrap = false;
    }

    return VisibilityDetector(
      key: _visibilityKey,
      onVisibilityChanged: _onVisibilityChanged,
      child: Chewie(
          height: widget.height,
          width: widget.width,
          controller: _chewieController,
          isConstrained: widget.isConstrained ?? false),
    );
  }

  Widget _buildLoadingIndicator() {
    return Stack(
      children: <Widget>[
        widget.thumbnailUrl != null
            ? Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AdvancedNetworkImage(widget.thumbnailUrl!,
                      useDiskCache: true),
                )),
              )
            : const SizedBox(),
        Positioned(
          top: 0,
          bottom: 0,
          right: 0,
          left: 0,
          child: Center(
              child: OBProgressIndicator(
            color: Colors.white,
          )),
        )
      ],
    );
  }

  void _onControlsPlay(Function originalPlayFunction) {
    debugLog('User is playing');
    _isPausedByUser = false;
    originalPlayFunction();
  }

  void _onControlsPause(Function originalPauseFunction) {
    debugLog('User is pausing');
    _isPausedByUser = true;
    originalPauseFunction();
  }

  void _onControlsMute(Function originalMuteFunction) {
    _userPreferencesService.setVideosSoundSetting(VideosSoundSetting.disabled);
  }

  void _onControlsUnmute(Function originalUnmuteFunction) {
    _userPreferencesService.setVideosSoundSetting(VideosSoundSetting.enabled);
  }

  void _onExpandCollapse(Function originalExpandFunction) async {
    if (_hasVideoOpenedInDialog) {
      _obVideoPlayerControlsController.pop();
      _hasVideoOpenedInDialog = false;
      return;
    }

    _hasVideoOpenedInDialog = true;
    OpenbookProviderState openbookProvider = OpenbookProvider.of(context);
    await openbookProvider.dialogService.showVideo(
        context: context,
        video: widget.video,
        videoUrl: widget.videoUrl,
        videoPlayerController: _playerController,
        chewieController: _chewieController);
    _hasVideoOpenedInDialog = false;
  }

  // Return back to config

  ChewieController _getChewieController() {
    if (widget.chewieController != null) return widget.chewieController!;
    double aspectRatio = _playerController!.value.aspectRatio;
    return ChewieController(
        autoInitialize: false,
        videoPlayerController: _playerController!,
        showControlsOnInitialize: false,
        customControls: OBVideoPlayerControls(
          controller: _obVideoPlayerControlsController,
          onExpandCollapse: _onExpandCollapse,
          onPause: _onControlsPause,
          onPlay: _onControlsPlay,
          onMute: _onControlsMute,
          onUnmute: _onControlsUnmute,
        ),
        aspectRatio: aspectRatio,
        autoPlay: widget.autoPlay,
        looping: true);
  }

  void _onVisibilityChanged(VisibilityInfo visibilityInfo) {
    if (_hasVideoOpenedInDialog) return;
    bool isVisible = visibilityInfo.visibleFraction != 0;

    debugLog(
        'isVisible: ${isVisible.toString()} with fraction ${visibilityInfo.visibleFraction}');

    if (!isVisible && _playerController!.value.isPlaying && mounted) {
      debugLog('Its not visible and the video is playing. Now pausing. .');
      _isPausedDueToInvisibility = true;
      _playerController!.pause();
    }
  }

  void _pause() {
    _playerController!.pause();
    _isPausedByUser = false;
    _isPausedDueToInvisibility = false;
  }

  void _play() {
    _isPausedDueToInvisibility = false;
    _isPausedByUser = false;
    _playerController!.play();
  }

  void debugLog(String log) {
    // ValueKey<String> key = _visibilityKey;
    Key key = _visibilityKey;
    debugPrint('OBVideoPlayer:$key: $log');
  }
}

class OBVideoPlayerController {
  late OBVideoPlayerState _state;
  bool _attemptedToPlayWhileNotReady = false;

  void attach(state) {
    _state = state;
  }

  void pause() {
    if (!isReady()) {
      _attemptedToPlayWhileNotReady = false;
      debugLog('State is not ready. Wont pause.');
      return;
    }
    _state._pause();
  }

  void play() {
    if (!isReady()) {
      _attemptedToPlayWhileNotReady = true;
      debugLog('State is not ready. Wont play.');
      return;
    }
    _state._play();
  }

  bool isPlaying() {
    if (!isReady()) return false;
    return _state._playerController!.value.isPlaying;
  }

  bool isReady() {
    return _state != null && _state.mounted && _state._videoInitialized;
  }

  bool hasVideoOpenedInDialog() {
    if (!isReady()) return false;

    return _state._hasVideoOpenedInDialog;
  }

  bool isPausedByUser() {
    if (!isReady()) return false;
    return _state._isPausedByUser;
  }

  bool isPausedDueToInvisibility() {
    if (!isReady()) return false;
    return _state._isPausedDueToInvisibility;
  }

  String getIdentifier() {
    if (!isReady()) {
      debugLog('State is not ready. Can not get identifier.');
      return 'unknown';
    }

    return _state._playerController!.dataSource!;
  }

  void debugLog(String log) {
    debugPrint('OBVideoPlayerController: $log');
  }
}

class OBVideoPlayerInitializationException implements Exception {
  String cause;

  OBVideoPlayerInitializationException(this.cause);
}
