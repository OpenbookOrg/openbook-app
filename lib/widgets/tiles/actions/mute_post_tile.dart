import 'package:Okuna/models/post.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/httpie.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/toast.dart';
import 'package:Okuna/services/user.dart';
import 'package:Okuna/widgets/icon.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:Okuna/widgets/tiles/loading_tile.dart';
import 'package:flutter/material.dart';

class OBMutePostTile extends StatefulWidget {
  final Post post;
  final VoidCallback? onMutedPost;
  final VoidCallback? onUnmutedPost;

  const OBMutePostTile({
    Key? key,
    required this.post,
    this.onMutedPost,
    this.onUnmutedPost,
  }) : super(key: key);

  @override
  OBMutePostTileState createState() {
    return OBMutePostTileState();
  }
}

class OBMutePostTileState extends State<OBMutePostTile> {
  late UserService _userService;
  late ToastService _toastService;
  late LocalizationService _localizationService;

  late bool _requestInProgress;

  @override
  void initState() {
    super.initState();
    _requestInProgress = false;
  }

  @override
  Widget build(BuildContext context) {
    var openbookProvider = OpenbookProvider.of(context);
    _userService = openbookProvider.userService;
    _toastService = openbookProvider.toastService;
    _localizationService = openbookProvider.localizationService;

    return StreamBuilder(
      stream: widget.post.updateSubject,
      initialData: widget.post,
      builder: (BuildContext context, AsyncSnapshot<Post> snapshot) {
        var post = snapshot.data;

        bool isMuted = post?.isMuted ?? false;

        return OBLoadingTile(
          isLoading: _requestInProgress,
          leading: OBIcon(isMuted ? OBIcons.unmutePost : OBIcons.mutePost),
          title: OBText(isMuted
              ? _localizationService.notifications__mute_post_turn_on_post_notifications
              : _localizationService.notifications__mute_post_turn_off_post_notifications),
          onTap: isMuted ? _unmutePost : _mutePost,
        );
      },
    );
  }

  void _mutePost() async {
    _setRequestInProgress(true);
    try {
      await _userService.mutePost(widget.post);
      if (widget.onMutedPost != null) widget.onMutedPost!();
    } catch (e) {
      _onError(e);
    } finally {
      _setRequestInProgress(false);
    }
  }

  void _unmutePost() async {
    _setRequestInProgress(true);
    try {
      await _userService.unmutePost(widget.post);
      if (widget.onUnmutedPost != null) widget.onUnmutedPost!();
    } catch (e) {
      _onError(e);
    } finally {
      _setRequestInProgress(false);
    }
  }

  void _onError(error) async {
    if (error is HttpieConnectionRefusedError) {
      _toastService.error(
          message: error.toHumanReadableMessage(), context: context);
    } else if (error is HttpieRequestError) {
      String? errorMessage = await error.toHumanReadableMessage();
      _toastService.error(message: errorMessage ?? _localizationService.error__unknown_error, context: context);
    } else {
      _toastService.error(message: _localizationService.error__unknown_error, context: context);
      throw error;
    }
  }

  void _setRequestInProgress(bool requestInProgress) {
    setState(() {
      _requestInProgress = requestInProgress;
    });
  }
}
