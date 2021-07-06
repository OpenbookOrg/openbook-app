import 'package:Okuna/models/post.dart';
import 'package:Okuna/models/user.dart';
import 'package:Okuna/pages/home/bottom_sheets/post_actions.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/widgets/avatars/avatar.dart';
import 'package:Okuna/widgets/icon.dart';
import 'package:Okuna/widgets/post/post.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:Okuna/widgets/theming/secondary_text.dart';
import 'package:Okuna/widgets/user_badge.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OBUserPostHeader extends StatelessWidget {
  final Post _post;
  final OnPostDeleted onPostDeleted;
  final ValueChanged<Post>? onPostReported;
  final OBPostDisplayContext? displayContext;
  final bool hasActions;

  const OBUserPostHeader(this._post,
      {Key? key,
      required this.onPostDeleted,
      this.onPostReported,
      this.hasActions = true,
      this.displayContext})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var openbookProvider = OpenbookProvider.of(context);
    var navigationService = openbookProvider.navigationService;
    var bottomSheetService = openbookProvider.bottomSheetService;
    var utilsService = openbookProvider.utilsService;
    var localizationService = openbookProvider.localizationService;

    if (_post.creator == null) return const SizedBox();

    String subtitle = '@${_post.creator!.username}';

    if (_post.created != null)
      subtitle =
          '$subtitle · ${utilsService.timeAgo(_post.created!, localizationService)}';

    VoidCallback navigateToUserProfile = () {
      navigationService.navigateToUserProfile(
          user: _post.creator!, context: context);
    };

    return ListTile(
        onTap: navigateToUserProfile,
        leading: StreamBuilder(
            stream: _post.creator!.updateSubject,
            initialData: _post.creator,
            builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
              User postCreator = snapshot.data!;

              return OBAvatar(
                size: OBAvatarSize.medium,
                avatarUrl: postCreator.getProfileAvatar(),
              );
            }),
        trailing: hasActions
            ? IconButton(
                icon: const OBIcon(OBIcons.moreVertical),
                onPressed: () {
                  bottomSheetService.showPostActions(
                      context: context,
                      post: _post,
                      onPostDeleted: onPostDeleted,
                      displayContext: displayContext!,
                      onPostReported: onPostReported);
                })
            : null,
        title: Row(
          children: <Widget>[
            Flexible(
              child: OBText(
                _post.creator!.getProfileName()!,
                style: TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(
              width: 3,
            ),
            _buildBadge()
          ],
        ),
        subtitle: OBSecondaryText(
          subtitle,
          style: TextStyle(fontSize: 12.0),
        ));
  }

  Widget _buildBadge() {
    User postCommenter = _post.creator!;

    if (postCommenter.hasProfileBadges())
      return OBUserBadge(
          badge: _post.creator!.getDisplayedProfileBadge(),
          size: OBUserBadgeSize.small);

    return const SizedBox();
  }
}
