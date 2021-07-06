import 'dart:math';

import 'package:Okuna/models/post.dart';
import 'package:Okuna/models/post_image.dart';
import 'package:Okuna/models/post_media.dart';
import 'package:Okuna/models/post_media_list.dart';
import 'package:Okuna/models/post_video.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/user.dart';
import 'package:Okuna/widgets/post/widgets/post-body/widgets/post_body_media/widgets/post_body_image.dart';
import 'package:Okuna/widgets/post/widgets/post-body/widgets/post_body_media/widgets/post_body_video.dart';
import 'package:Okuna/widgets/progress_indicator.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:flutter/material.dart';
import 'package:async/async.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_advanced_networkimage/transition.dart';

class OBPostBodyMedia extends StatefulWidget {
  final Post? post;
  final String? inViewId;

  const OBPostBodyMedia({Key? key, this.post, this.inViewId}) : super(key: key);

  @override
  OBPostBodyMediaState createState() {
    return OBPostBodyMediaState();
  }
}

class OBPostBodyMediaState extends State<OBPostBodyMedia> {
  late UserService _userService;
  late LocalizationService _localizationService;
  late bool _needsBootstrap;
  late String _errorMessage;

  CancelableOperation? _retrievePostMediaOperation;
  late bool _retrievePostMediaInProgress;

  double? _mediaHeight;
  double? _mediaWidth;
  late bool _mediaIsConstrained;

  @override
  void initState() {
    super.initState();
    _needsBootstrap = true;
    _retrievePostMediaInProgress = true;
    _errorMessage = '';
    _mediaIsConstrained = false;
  }

  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    _retrievePostMediaInProgress = true;
    _needsBootstrap = true;
    _errorMessage = '';
  }

  @override
  void dispose() {
    super.dispose();
    _retrievePostMediaOperation?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    if (_needsBootstrap) {
      OpenbookProviderState openbookProvider = OpenbookProvider.of(context);
      _userService = openbookProvider.userService;
      _localizationService = openbookProvider.localizationService;
      _bootstrap();
      _needsBootstrap = false;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SizedBox(
          width: _mediaWidth,
          height: _mediaHeight,
          child: Stack(
            children: <Widget>[
              Positioned(
                child: _buildPostMediaItemsThumbnail(),
              ),
              _errorMessage.isEmpty
                  ? _retrievePostMediaInProgress
                      ? const SizedBox()
                      : _buildMediaItems()
                  : Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: _buildErrorMessage(),
                    )
            ],
          )),
    );
  }

  Widget _buildErrorMessage() {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
            color: Colors.black87, borderRadius: BorderRadius.circular(3)),
        child: Text(
          _errorMessage,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildMediaItems() {
    return StreamBuilder(
      stream: widget.post!.updateSubject,
      initialData: widget.post,
      builder: (BuildContext context, AsyncSnapshot<Post> snapshot) {
        List<PostMedia> postMediaItems = widget.post!.getMedia() ?? [];
        return _buildPostMediaItems(postMediaItems);
      },
    );
  }

  Widget _buildPostMediaItemsThumbnail() {
    String? thumbnailUrl = widget.post?.mediaThumbnail;

    return TransitionToImage(
      height: _mediaHeight,
      width: _mediaWidth,
      loadingWidget: const Center(
        child: const OBProgressIndicator(),
      ),
      fit: BoxFit.cover,
      alignment: Alignment.center,
      image: AdvancedNetworkImage(thumbnailUrl ?? '',
          useDiskCache: true,
          fallbackAssetImage: 'assets/images/fallbacks/post-fallback.png',
          retryLimit: 3,
          timeoutDuration: const Duration(seconds: 5)),
      duration: Duration(milliseconds: 100),
    );
  }

  Widget _buildPostMediaItems(List<PostMedia> postMediaItems) {
    // We support only one atm
    PostMedia postMediaItem = postMediaItems.first;
    return _buildPostMediaItem(postMediaItem);
  }

  Widget _buildPostMediaItem(PostMedia postMediaItem) {
    Widget postMediaItemWidget;

    dynamic postMediaItemContentObject = postMediaItem.contentObject;

    switch (postMediaItemContentObject.runtimeType) {
      case PostImage:
        postMediaItemWidget = OBPostBodyImage(
            postImage: postMediaItemContentObject,
            hasExpandButton: _mediaIsConstrained,
            height: _mediaHeight,
            width: _mediaWidth);
        break;
      case PostVideo:
        postMediaItemWidget = OBPostBodyVideo(
          postVideo: postMediaItemContentObject,
          post: widget.post,
          inViewId: widget.inViewId,
          height: _mediaHeight,
          width: _mediaWidth,
          isConstrained: _mediaIsConstrained,
        );
        break;
      default:
        postMediaItemWidget = Center(
          child: OBText(_localizationService.post_body_media__unsupported),
        );
    }

    return postMediaItemWidget;
  }

  void _bootstrap() {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double maxBoxHeight = screenHeight * .70;

    double imageAspectRatio = widget.post!.mediaWidth! / widget.post!.mediaHeight!;
    double imageHeight = (screenWidth / imageAspectRatio);
    _mediaHeight = min(imageHeight, maxBoxHeight);
    if (_mediaHeight == maxBoxHeight) _mediaIsConstrained = true;
    _mediaWidth = screenWidth;

    if (widget.post?.media != null) {
      _retrievePostMediaInProgress = false;
      return;
    }

    _retrievePostMedia();
  }

  void _retrievePostMedia() async {
    _setRetrievePostMediaInProgress(true);
    try {
      _retrievePostMediaOperation = CancelableOperation.fromFuture(
          _userService.getMediaForPost(post: widget.post!), onCancel: _onRetrievePostMediaOperationCancelled);
      PostMediaList mediaList = await _retrievePostMediaOperation!.value;
      widget.post!.setMedia(mediaList);
    } catch (error) {
      _onError(error);
    } finally {
      _setRetrievePostMediaInProgress(false);
    }
  }

  void _onRetrievePostMediaOperationCancelled() {
    debugPrint('Cancelled retrievePostMediaOperation');
    _setRetrievePostMediaInProgress(false);
  }

  void _onError(error) async {
    if (error is HttpieConnectionRefusedError) {
      _setErrorMessage(error.toHumanReadableMessage());
    } else if (error is HttpieRequestError) {
      String? errorMessage = await error.toHumanReadableMessage();
      _setErrorMessage(errorMessage ?? _localizationService.error__unknown_error);
    } else {
      _setErrorMessage(_localizationService.error__unknown_error);
      throw error;
    }
  }

  void _setErrorMessage(String errorMessage) {
    setState(() {
      _errorMessage = errorMessage;
    });
  }

  void _setRetrievePostMediaInProgress(bool retrievePostMediaInProgress) {
    if (!mounted) return;
    setState(() {
      _retrievePostMediaInProgress = retrievePostMediaInProgress;
    });
  }
}
