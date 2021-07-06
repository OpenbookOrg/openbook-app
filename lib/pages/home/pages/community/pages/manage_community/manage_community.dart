import 'package:Okuna/models/community.dart';
import 'package:Okuna/models/user.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/modal_service.dart';
import 'package:Okuna/services/navigation_service.dart';
import 'package:Okuna/services/user.dart';
import 'package:Okuna/widgets/icon.dart';
import 'package:Okuna/widgets/nav_bars/themed_nav_bar.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/widgets/theming/primary_color_container.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:Okuna/widgets/tiles/actions/favorite_community_tile.dart';
import 'package:Okuna/widgets/tiles/actions/new_post_notifications_for_community_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OBManageCommunityPage extends StatelessWidget {
  final Community community;

  const OBManageCommunityPage({required this.community});

  @override
  Widget build(BuildContext context) {
    var openbookProvider = OpenbookProvider.of(context);
    NavigationService navigationService = openbookProvider.navigationService;
    ModalService modalService = openbookProvider.modalService;
    UserService userService = openbookProvider.userService;
    LocalizationService _localizationService = openbookProvider.localizationService;

    User loggedInUser = userService.getLoggedInUser()!;
    List<Widget> menuListTiles = [];

    const TextStyle listItemSubtitleStyle = TextStyle(fontSize: 14);

    if (loggedInUser.canChangeDetailsOfCommunity(community)) {
      menuListTiles.add(ListTile(
        leading: const OBIcon(OBIcons.communities),
        title: OBText(_localizationService.trans('community__manage_details_title')),
        subtitle: OBText(
          _localizationService.trans('community__manage_details_desc'),
          style: listItemSubtitleStyle,
        ),
        onTap: () {
          modalService.openEditCommunity(
              context: context, community: community);
        },
      ));
    }

    if (loggedInUser.canAddOrRemoveAdministratorsInCommunity(community)) {
      menuListTiles.add(ListTile(
        leading: const OBIcon(OBIcons.communityAdministrators),
        title: OBText(_localizationService.trans('community__manage_admins_title')),
        subtitle: OBText(
          _localizationService.trans('community__manage_admins_desc'),
          style: listItemSubtitleStyle,
        ),
        onTap: () {
          navigationService.navigateToCommunityAdministrators(
              context: context, community: community);
        },
      ));
    }

    if (loggedInUser.canAddOrRemoveModeratorsInCommunity(community)) {
      menuListTiles.add(ListTile(
        leading: const OBIcon(OBIcons.communityModerators),
        title: OBText(_localizationService.trans('community__manage_mods_title')),
        subtitle: OBText(
          _localizationService.trans('community__manage_mods_desc'),
          style: listItemSubtitleStyle,
        ),
        onTap: () {
          navigationService.navigateToCommunityModerators(
              context: context, community: community);
        },
      ));
    }

    if (loggedInUser.canBanOrUnbanUsersInCommunity(community)) {
      menuListTiles.add(ListTile(
        leading: const OBIcon(OBIcons.communityBannedUsers),
        title: OBText(_localizationService.trans('community__manage_banned_title')),
        subtitle: OBText(
          _localizationService.trans('community__manage_banned_desc'),
          style: listItemSubtitleStyle,
        ),
        onTap: () {
          navigationService.navigateToCommunityBannedUsers(
              context: context, community: community);
        },
      ));
    }

    if (loggedInUser.canBanOrUnbanUsersInCommunity(community)) {
      menuListTiles.add(ListTile(
        leading: const OBIcon(OBIcons.communityModerators),
        title: OBText(_localizationService.trans('community__manage_mod_reports_title')),
        subtitle: OBText(
          _localizationService.trans('community__manage_mod_reports_desc'),
          style: listItemSubtitleStyle,
        ),
        onTap: () {
          navigationService.navigateToCommunityModeratedObjects(
              context: context, community: community);
        },
      ));
    }

    if (loggedInUser.canCloseOrOpenPostsInCommunity(community)) {
      menuListTiles.add(ListTile(
        leading: const OBIcon(OBIcons.closePost),
        title: OBText(_localizationService.trans('community__manage_closed_posts_title')),
        subtitle: OBText(
          _localizationService.trans('community__manage_closed_posts_desc'),
          style: listItemSubtitleStyle,
        ),
        onTap: () {
          navigationService.navigateToCommunityClosedPosts(
              context: context, community: community);
        },
      ));
    }


    menuListTiles.add(OBNewPostNotificationsForCommunityTile(
        community: community,
        title: OBText(_localizationService.community__manage_enable_new_post_notifications,
          style: listItemSubtitleStyle,
        ),
        subtitle: OBText(_localizationService.community__manage_disable_new_post_notifications,
          style: listItemSubtitleStyle,
        )));

    menuListTiles.add(ListTile(
      leading: const OBIcon(OBIcons.communityInvites),
      title: OBText(_localizationService.trans('community__manage_invite_title')),
      subtitle: OBText(_localizationService.trans('community__manage_invite_desc'),
        style: listItemSubtitleStyle,
      ),
      onTap: () {
        modalService.openInviteToCommunity(
            context: context, community: community);
      },
    ));

    menuListTiles.add(OBFavoriteCommunityTile(
        community: community,
        favoriteSubtitle: OBText(_localizationService.trans('community__manage_add_favourite'),
          style: listItemSubtitleStyle,
        ),
        unfavoriteSubtitle: OBText(_localizationService.trans('community__manage_remove_favourite'),
          style: listItemSubtitleStyle,
        )));

    if (loggedInUser.isCreatorOfCommunity(community)) {
      menuListTiles.add(ListTile(
        leading: const OBIcon(OBIcons.deleteCommunity),
        title: OBText(_localizationService.trans('community__manage_delete_title')),
        subtitle: OBText(
          _localizationService.trans('community__manage_delete_desc'),
          style: listItemSubtitleStyle,
        ),
        onTap: () {
          navigationService.navigateToDeleteCommunity(
              context: context, community: community);
        },
      ));
    } else {
      menuListTiles.add(ListTile(
        leading: const OBIcon(OBIcons.leaveCommunity),
        title: OBText(_localizationService.trans('community__manage_leave_title')),
        subtitle: OBText(
          _localizationService.trans('community__manage_leave_desc'),
          style: listItemSubtitleStyle,
        ),
        onTap: () {
          navigationService.navigateToLeaveCommunity(
              context: context, community: community);
        },
      ));
    }

    return CupertinoPageScaffold(
      navigationBar: OBThemedNavigationBar(
        title: _localizationService.trans('community__manage_title'),
      ),
      child: OBPrimaryColorContainer(
        child: Column(
          children: <Widget>[
            Expanded(
                child: ListView(
                    padding: EdgeInsets.zero,
                    children: menuListTiles)),
          ],
        ),
      ),
    );
  }
}
