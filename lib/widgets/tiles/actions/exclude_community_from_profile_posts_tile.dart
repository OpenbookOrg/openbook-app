import 'package:Okuna/models/community.dart';
import 'package:Okuna/models/post.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/bottom_sheet.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/toast.dart';
import 'package:Okuna/services/user.dart';
import 'package:Okuna/widgets/icon.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:flutter/material.dart';

class OBExcludeCommunityFromProfilePostsTile extends StatefulWidget {
  final Post post;
  final ValueChanged<Community> onPostCommunityExcludedFromProfilePosts;

  const OBExcludeCommunityFromProfilePostsTile({
    Key? key,
    required this.post,
    required this.onPostCommunityExcludedFromProfilePosts,
  }) : super(key: key);

  @override
  OBExcludeCommunityFromProfilePostsTileState createState() {
    return OBExcludeCommunityFromProfilePostsTileState();
  }
}

class OBExcludeCommunityFromProfilePostsTileState
    extends State<OBExcludeCommunityFromProfilePostsTile> {
  late UserService _userService;
  late ToastService _toastService;
  late LocalizationService _localizationService;
  late BottomSheetService _bottomSheetService;

  @override
  Widget build(BuildContext context) {
    var openbookProvider = OpenbookProvider.of(context);
    _userService = openbookProvider.userService;
    _toastService = openbookProvider.toastService;
    _localizationService = openbookProvider.localizationService;
    _bottomSheetService = openbookProvider.bottomSheetService;

    return ListTile(
      leading: OBIcon(OBIcons.excludePostCommunity),
      title: OBText(
          _localizationService.post__exclude_community_from_profile_posts),
      onTap: _onWantsToExcludeCommunity,
    );
  }

  void _onWantsToExcludeCommunity() {
    _bottomSheetService.showConfirmAction(
        context: context,
        subtitle: _localizationService
            .post__exclude_community_from_profile_posts_confirmation,
        actionCompleter: (BuildContext context) async {
          await _excludePostCommunity();

          widget.onPostCommunityExcludedFromProfilePosts(widget.post.community!);
          _toastService.success(
              message: _localizationService.post__exclude_community_from_profile_posts_success,
              context: context);
        });
  }

  Future _excludePostCommunity() async {
    return _userService.excludeCommunityFromProfilePosts(widget.post.community!);
  }
}
