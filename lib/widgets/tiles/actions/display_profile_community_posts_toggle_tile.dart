import 'package:Okuna/models/user.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/httpie.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/toast.dart';
import 'package:Okuna/services/user.dart';
import 'package:Okuna/widgets/fields/toggle_field.dart';
import 'package:Okuna/widgets/icon.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OBDisplayProfileCommunityPostsToggleTile extends StatefulWidget {
  final User user;
  final ValueChanged<bool>? onChanged;
  final bool hasDivider;

  const OBDisplayProfileCommunityPostsToggleTile(
      {Key? key, this.onChanged, required this.user, this.hasDivider = false})
      : super(key: key);

  @override
  OBDisplayProfileCommunityPostsToggleTileState createState() {
    return OBDisplayProfileCommunityPostsToggleTileState();
  }
}

class OBDisplayProfileCommunityPostsToggleTileState
    extends State<OBDisplayProfileCommunityPostsToggleTile> {
  static const double inputIconsSize = 16;
  static EdgeInsetsGeometry inputContentPadding =
      EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0);

  late UserService _userService;
  late ToastService _toastService;
  late LocalizationService _localizationService;

  late bool _requestInProgress;

  late bool _communityPostsVisible;

  @override
  void initState() {
    super.initState();

    _requestInProgress = false;

    _communityPostsVisible = widget.user.getProfileCommunityPostsVisible();
  }

  @override
  Widget build(BuildContext context) {
    var openbookProvider = OpenbookProvider.of(context);
    _userService = openbookProvider.userService;
    _toastService = openbookProvider.toastService;
    _localizationService = openbookProvider.localizationService;

    return OBToggleField(
      hasDivider: widget.hasDivider,
      value: _communityPostsVisible,
      title: _localizationService.user__manage_profile_community_posts_toggle,
      subtitle: OBText(_localizationService
          .user__manage_profile_community_posts_toggle__descr, size: OBTextSize.mediumSecondary,),
      leading: const OBIcon(OBIcons.communities),
      isLoading: _requestInProgress,
      onTap: () {
        setState(() {
          _communityPostsVisible = !_communityPostsVisible;
          _saveCommunityPosts();
        });
        },
    );
  }

  void _saveCommunityPosts() async {
    _setRequestInProgress(true);
    try {
      await _userService.updateUser(
        communityPostsVisible: _communityPostsVisible,
      );
      if (widget.onChanged != null) widget.onChanged!(_communityPostsVisible);
    } catch (error) {
      _onError(error);
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
      _toastService.error(
          message: _localizationService.error__unknown_error, context: context);
      throw error;
    }
  }

  void _setRequestInProgress(bool requestInProgress) {
    setState(() {
      _requestInProgress = requestInProgress;
    });
  }
}
