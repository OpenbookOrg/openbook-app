import 'dart:async';
import 'dart:io';

import 'package:Okuna/models/circle.dart';
import 'package:Okuna/models/community.dart';
import 'package:Okuna/models/post.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/media/media.dart';
import 'package:Okuna/services/user.dart';
import 'package:Okuna/widgets/theming/highlighted_box.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:async/async.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

import 'icon.dart';
import 'linear_progress_indicator.dart';

class OBNewPostDataUploader extends StatefulWidget {
  final OBNewPostData data;
  final Function(Post, OBNewPostData) onPostPublished;
  final ValueChanged<OBNewPostData> onCancelled;

  const OBNewPostDataUploader(
      {Key? key,
      required this.data,
      required this.onPostPublished,
      required this.onCancelled})
      : super(key: key);

  @override
  OBNewPostDataUploaderState createState() {
    return OBNewPostDataUploaderState();
  }
}

class OBNewPostDataUploaderState extends State<OBNewPostDataUploader>
    with AutomaticKeepAliveClientMixin {
  late UserService _userService;
  late LocalizationService _localizationService;
  late MediaService _mediaPickerService;

  late bool _needsBootstrap;
  late OBPostUploaderStatus _status;

  String _statusMessage = '';

  static double mediaPreviewSize = 40;

  Timer? _checkPostStatusTimer;

  CancelableOperation? _getPostStatusOperation;
  CancelableOperation? _uploadPostOperation;
  late OBNewPostData _data;

  @override
  void initState() {
    super.initState();
    _needsBootstrap = true;
    _data = widget.data;
    _status = OBPostUploaderStatus.idle;
  }

  @override
  void dispose() {
    super.dispose();
    _ensurePostStatusTimerIsCancelled();
    _getPostStatusOperation?.cancel();
    _uploadPostOperation?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    if (_needsBootstrap) {
      OpenbookProviderState openbookProvider = OpenbookProvider.of(context);
      _userService = openbookProvider.userService;
      _localizationService = openbookProvider.localizationService;
      _mediaPickerService = openbookProvider.mediaService;
      _bootstrap();
      _needsBootstrap = false;
    }

    List<Widget> rowItems = [];

    if (_data.hasMedia()) {
      rowItems.addAll([
        _buildMediaPreview(),
        const SizedBox(
          width: 15,
        ),
      ]);
    }

    rowItems.addAll([_buildStatusText(), _buildActionButtons()]);

    return OBHighlightedBox(
      child: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    children: <Widget>[
                      Row(children: rowItems),
                    ],
                  ),
                )
              ],
            ),
          ),
          Positioned(
            bottom: -3,
            left: 0,
            right: 0,
            child: _status == OBPostUploaderStatus.creatingPost ||
                    _status == OBPostUploaderStatus.compressingPostMedia ||
                    _status == OBPostUploaderStatus.addingPostMedia ||
                    _status == OBPostUploaderStatus.processing
                ? _buildProgressBar()
                : const SizedBox(),
          )
        ],
      ),
    );
  }

  void _bootstrap() {
    _startUpload();
  }

  void _startUpload() {
    _uploadPostOperation = CancelableOperation.fromFuture(_uploadPost());
  }

  Future _uploadPost() async {
    try {
      if (_data.createdDraftPost == null) {
        _setStatus(OBPostUploaderStatus.creatingPost);
        _setStatusMessage(_localizationService.post_uploader__creating_post);
        _data.createdDraftPost = await _createPost();
      }

      if (_data.remainingMediaToCompress != null && _data.remainingMediaToCompress!.isNotEmpty) {
        _setStatusMessage(
            _localizationService.post_uploader__compressing_media);
        _setStatus(OBPostUploaderStatus.compressingPostMedia);
        await _compressPostMedia();
      }

      if (_data.remainingCompressedMediaToUpload.isNotEmpty) {
        _setStatusMessage(_localizationService.post_uploader__uploading_media);
        _setStatus(OBPostUploaderStatus.addingPostMedia);
        await _addPostMedia();
      }

      if (!_data.postPublishRequested) {
        _setStatusMessage(_localizationService.post_uploader__publishing);
        _setStatus(OBPostUploaderStatus.publishing);
        await _publishPost();
        _data.postPublishRequested = true;
      }

      _setStatusMessage(_localizationService.post_uploader__processing);
      _setStatus(OBPostUploaderStatus.processing);
      _ensurePostStatusTimerIsCancelled();

      if (_data.createdDraftPostStatus == null ||
          _data.createdDraftPostStatus != OBPostStatus.published) {
        _checkPostStatusTimer =
            Timer.periodic(new Duration(seconds: 1), (timer) async {
          if (_getPostStatusOperation != null) return;
          _getPostStatusOperation = CancelableOperation.fromFuture(
              _userService.getPostStatus(post: _data.createdDraftPost!));
          OBPostStatus status = await _getPostStatusOperation?.value;
          debugLog(
              'Polling for post published status, got status: ${status.toString()}');
          _data.createdDraftPostStatus = status;
          if (_data.createdDraftPostStatus == OBPostStatus.published) {
            debugLog('Received post status is published');
            _checkPostStatusTimer?.cancel();
            _getPublishedPost();
          }
          _getPostStatusOperation = null;
        });
      } else {
        _getPublishedPost();
      }
    } catch (error) {
      if (error is HttpieConnectionRefusedError) {
        _setStatusMessage(error.toHumanReadableMessage());
      } else if (error is HttpieRequestError) {
        String? errorMessage = await error.toHumanReadableMessage();
        _setStatusMessage(errorMessage ?? _localizationService.error__unknown_error);
      } else {
        _setStatusMessage(
            _localizationService.post_uploader__generic_upload_failed);
        // only throw error if its not one of the above handled errors
        throw error;
      }
      _setStatus(OBPostUploaderStatus.failed);
    }
  }

  Future _createPost() async {
    Post draftPost;

    if (_data.community != null) {
      debugLog('Creating community post');

      draftPost = await _userService.createPostForCommunity(_data.community!,
          text: _data.text, isDraft: true);
    } else {
      debugLog('Creating circles post');

      draftPost = await _userService.createPost(
          text: _data.text, circles: _data.getCircles(), isDraft: true);
    }

    debugLog('Post created successfully');

    return draftPost;
  }

  Future _getPublishedPost() async {
    debugLog('Retrieving the published post');

    Post publishedPost =
        await _userService.getPostWithUuid(_data.createdDraftPost!.uuid!);
    widget.onPostPublished(publishedPost, widget.data);
    _removeMediaFromCache();
  }

  Future _compressPostMedia() {
    debugLog('Compressing post media');

    return Future.wait(
        _data.remainingMediaToCompress!.map(_compressPostMediaItem).toList());
  }

  Future _compressPostMediaItem(File postMediaItem) async {
    String? mediaMime = lookupMimeType(postMediaItem.path);
    String? mediaMimeType = mediaMime?.split('/')[0];

    if (mediaMimeType == 'image') {
      File compressedImage =
          await _mediaPickerService.compressImage(postMediaItem);
      _data.remainingCompressedMediaToUpload.add(compressedImage);
      if (compressedImage.path.indexOf('compressed') > -1) {
        _data.compressedMedia.add(compressedImage);
      }
      debugLog(
          'Compressed image from ${postMediaItem.lengthSync()} to ${compressedImage.lengthSync()}');
    } else if (mediaMimeType == 'video') {
      File compressedVideo =
          await _mediaPickerService.compressVideo(postMediaItem);
      if (compressedVideo.path.indexOf('compressed') > -1) {
        _data.compressedMedia.add(compressedVideo);
      }
      _data.remainingCompressedMediaToUpload.add(compressedVideo);
      debugLog(
          'Compressed video from ${postMediaItem.lengthSync()} to ${compressedVideo.lengthSync()}');
    } else {
      debugLog('Unsupported media type for compression');
    }
    _data.remainingMediaToCompress!.remove(postMediaItem);
  }

  Future _addPostMedia() {
    debugLog('Adding post media');

    return Future.wait(_data.remainingCompressedMediaToUpload
        .map(_uploadPostMediaItem)
        .toList());
  }

  Future _uploadPostMediaItem(File file) async {
    await _userService.addMediaToPost(file: file, post: _data.createdDraftPost!);
    _data.remainingCompressedMediaToUpload.remove(file);
  }

  Widget _buildProgressBar() {
    return OBLinearProgressIndicator();
  }

  Widget _buildMediaPreview() {
    return FutureBuilder(
      future: _getMediaThumbnail(),
      builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
        if (snapshot.data == null) return const SizedBox();

        File mediaThumbnail = snapshot.data!;
        return ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image(
            image: FileImage(mediaThumbnail),
            height: mediaPreviewSize,
            width: mediaPreviewSize,
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }

  Future<File> _getMediaThumbnail() async {
    if (_data.mediaThumbnail != null) return _data.mediaThumbnail!;

    File mediaToPreview = _data.media!.first;
    late File mediaThumbnail;

    String? mediaMime = lookupMimeType(mediaToPreview.path);
    String? mediaMimeType = mediaMime?.split('/')[0];

    if (mediaMimeType == 'image') {
      mediaThumbnail = mediaToPreview;
    } else if (mediaMimeType == 'video') {
      mediaThumbnail =
          await _mediaPickerService.getVideoThumbnail(mediaToPreview);
    } else {
      debugLog('Unsupported media type for preview thumbnail');
    }

    _data.mediaThumbnail = mediaThumbnail;

    return mediaThumbnail;
  }

  Widget _buildStatusText() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            OBText(
              _statusMessage,
              textAlign: TextAlign.left,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    List<Widget> activeActions = [];

    switch (_status) {
      case OBPostUploaderStatus.creatingPost:
      case OBPostUploaderStatus.addingPostMedia:
        activeActions.add(_buildCancelButton());
        break;
      case OBPostUploaderStatus.failed:
        activeActions.add(_buildCancelButton());
        activeActions.add(_buildRetryButton());
        break;
      default:
    }

    return Row(
      children: activeActions,
    );
  }

  Widget _buildCancelButton() {
    return GestureDetector(
      onTap: _onWantsToCancel,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: OBIcon(OBIcons.cancel),
      ),
    );
  }

  Widget _buildRetryButton() {
    return GestureDetector(
      onTap: _onWantsToRetry,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: OBIcon(OBIcons.retry),
      ),
    );
  }

  void _onWantsToRetry() async {
    if (_status == OBPostUploaderStatus.creatingPost ||
        _status == OBPostUploaderStatus.addingPostMedia) return;

    debugLog('Retrying');
    _startUpload();
  }

  void _onWantsToCancel() async {
    if (_status == OBPostUploaderStatus.cancelling) return;
    _setStatus(OBPostUploaderStatus.cancelling);

    debugLog('Cancelling');

    // Delete post
    if (_data.createdDraftPost != null) {
      debugLog('Deleting post');
      try {
        await _userService.deletePost(_data.createdDraftPost!);
        debugLog('Successfully deleted post');
      } catch (error) {
        // If it doesnt work, will get cleaned up by a scheduled job
        debugLog('Failed to delete post wit error: ${error.toString()}');
      }
    }

    _setStatus(OBPostUploaderStatus.cancelled);
    widget.onCancelled(widget.data);
    _removeMediaFromCache();
  }

  void _removeMediaFromCache() async {
    debugLog('Clearing local cached media for post');
    _data.media?.forEach((File mediaObject) {
      if (mediaObject.existsSync()) mediaObject.delete();
    });
    _data.compressedMedia.forEach((File mediaObject) => mediaObject.delete());
    if (_data.mediaThumbnail != _data.media?.first) {
      _data.mediaThumbnail?.delete();
    }
  }

  Future _publishPost() async {
    debugLog('Publishing post');
    return _userService.publishPost(post: _data.createdDraftPost!);
  }

  void _setStatus(OBPostUploaderStatus status) {
    if (mounted) {
      setState(() {
        _status = status;
      });
    }
  }

  void _setStatusMessage(String statusMessage) {
    if (mounted) {
      setState(() {
        _statusMessage = statusMessage;
      });
    }
  }

  void _ensurePostStatusTimerIsCancelled() {
    if (_checkPostStatusTimer != null && _checkPostStatusTimer!.isActive)
      _checkPostStatusTimer?.cancel();
  }

  void debugLog(String log) {
    debugPrint('OBNewPostDataUploader:$log');
  }

  @override
  bool get wantKeepAlive => true;
}

class OBNewPostData {
  String? text;
  List<File>? media;
  Community? community;
  List<Circle>? circles;

  // State persistence variables
  Post? createdDraftPost;
  OBPostStatus? createdDraftPostStatus;
  List<File>? remainingMediaToCompress;
  List<File> compressedMedia = [];
  List<File> remainingCompressedMediaToUpload = [];
  bool postPublishRequested = false;
  File? mediaThumbnail;

  String? _cachedKey;

  OBNewPostData({this.text, this.media, this.community, this.circles}) {
    remainingMediaToCompress = media?.toList();
  }

  bool hasMedia() {
    return media != null && media!.isNotEmpty;
  }

  List<File> getMedia() {
    return hasMedia() ? media!.toList() : [];
  }

  void setCircles(List<Circle> circles) {
    this.circles = circles;
  }

  void setCommunity(Community community) {
    this.community = community;
  }

  List<Circle> getCircles() {
    return circles!.toList();
  }

  String getUniqueKey() {
    if (_cachedKey != null) return _cachedKey!;

    String key = '';
    if (text != null) key += text!;
    if (hasMedia()) {
      media!.forEach((File mediaItem) {
        key += mediaItem.path;
      });
    }

    var bytes = utf8.encode(key);
    var digest = sha256.convert(bytes);

    _cachedKey = digest.toString();

    return _cachedKey!;
  }
}

enum OBPostUploaderStatus {
  idle,
  creatingPost,
  compressingPostMedia,
  addingPostMedia,
  publishing,
  processing,
  success,
  failed,
  cancelling,
  cancelled,
}
