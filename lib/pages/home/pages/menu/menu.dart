import 'package:Okuna/models/user.dart';
import 'package:Okuna/pages/home/lib/poppable_page_controller.dart';
import 'package:Okuna/widgets/badges/badge.dart';
import 'package:Okuna/widgets/icon.dart';
import 'package:Okuna/widgets/nav_bars/themed_nav_bar.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/widgets/theming/primary_color_container.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:Okuna/widgets/tile_group_title.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OBMainMenuPage extends StatelessWidget {
  final OBMainMenuPageController? controller;

  const OBMainMenuPage({this.controller});

  @override
  Widget build(BuildContext context) {
    controller?.attach(context: context);
    var openbookProvider = OpenbookProvider.of(context);
    var localizationService = openbookProvider.localizationService;
    var intercomService = openbookProvider.intercomService;
    var userService = openbookProvider.userService;
    var navigationService = openbookProvider.navigationService;

    return CupertinoPageScaffold(
      navigationBar: OBThemedNavigationBar(
        title: localizationService.drawer__menu_title,
      ),
      child: OBPrimaryColorContainer(
        child: Column(
          children: <Widget>[
            StreamBuilder(
              stream: userService.loggedInUserChange,
              initialData: userService.getLoggedInUser(),
              builder: (BuildContext context,
                  AsyncSnapshot<User?> loggedInUserSnapshot) {
                User? loggedInUser = loggedInUserSnapshot.data;

                if (loggedInUser == null) return const SizedBox();

                return StreamBuilder(
                  stream: loggedInUserSnapshot.data!.updateSubject,
                  initialData: loggedInUserSnapshot.data,
                  builder:
                      (BuildContext context, AsyncSnapshot<User> userSnapshot) {
                    User user = userSnapshot.data!;

                    return Expanded(
                        child: ListView(
                      // Important: Remove any padding from the ListView.
                      padding: EdgeInsets.zero,
                      children: <Widget>[
                        OBTileGroupTitle(
                          title: localizationService.drawer__main_title,
                        ),
                        ListTile(
                          leading: const OBIcon(OBIcons.circles),
                          title: OBText(localizationService.drawer__my_circles),
                          onTap: () {
                            navigationService.navigateToConnectionsCircles(
                                context: context);
                          },
                        ),
                        ListTile(
                          leading: const OBIcon(OBIcons.lists),
                          title: OBText(localizationService.drawer__my_lists),
                          onTap: () {
                            navigationService.navigateToFollowsLists(
                                context: context);
                          },
                        ),
                        ListTile(
                          leading: const OBIcon(OBIcons.followers),
                          title: OBText(localizationService.drawer__my_followers),
                          onTap: () {
                            navigationService.navigateToFollowersPage(
                                context: context);
                          },
                        ),
                        ListTile(
                          leading: const OBIcon(OBIcons.following),
                          title: OBText(localizationService.drawer__my_following),
                          onTap: () {
                            navigationService.navigateToFollowingPage(
                                context: context);
                          },
                        ),
                        ListTile(
                          leading: const OBIcon(OBIcons.invite),
                          title: OBText(localizationService.drawer__my_invites),
                          onTap: () {
                            navigationService.navigateToUserInvites(
                                context: context);
                          },
                        ),
                        ListTile(
                          leading: const OBIcon(OBIcons.communityModerators),
                          title: OBText(localizationService.drawer__my_pending_mod_tasks),
                          onTap: () async {
                            await navigationService
                                .navigateToMyModerationTasksPage(
                                    context: context);
                            userService.refreshUser();
                          },
                          trailing: OBBadge(
                            size: 25,
                            count: user.pendingCommunitiesModeratedObjectsCount,
                          ),
                        ),
                        ListTile(
                          leading: const OBIcon(OBIcons.moderationPenalties),
                          title: OBText(localizationService.drawer__my_mod_penalties),
                          onTap: () async {
                            await navigationService
                                .navigateToMyModerationPenaltiesPage(
                                    context: context);
                            userService.refreshUser();
                          },
                          trailing: OBBadge(
                            size: 25,
                            count: user.activeModerationPenaltiesCount,
                          ),
                        ),
                        OBTileGroupTitle(
                          title: localizationService.drawer__app_account_text,
                        ),
                        ListTile(
                          leading: const OBIcon(OBIcons.settings),
                          title: OBText(localizationService.drawer__settings),
                          onTap: () {
                            navigationService.navigateToSettingsPage(
                                context: context);
                          },
                        ),
                        ListTile(
                          leading: const OBIcon(OBIcons.themes),
                          title: OBText(localizationService.drawer__themes),
                          onTap: () {
                            navigationService.navigateToThemesPage(
                                context: context);
                          },
                        ),
                        StreamBuilder(
                          stream: userService.loggedInUserChange,
                          initialData: userService.getLoggedInUser(),
                          builder: (BuildContext context,
                              AsyncSnapshot<User?> snapshot) {
                            User? loggedInUser = snapshot.data;

                            if (loggedInUser == null) return const SizedBox();

                            return ListTile(
                              leading: const OBIcon(OBIcons.help),
                              title: OBText(
                                  localizationService.trans('drawer__help')),
                              onTap: () async {
                                intercomService.displayMessenger();
                              },
                            );
                          },
                        ),
                        StreamBuilder(
                          stream: userService.loggedInUserChange,
                          initialData: userService.getLoggedInUser(),
                          builder: (BuildContext context,
                              AsyncSnapshot<User?> snapshot) {
                            User? loggedInUser = snapshot.data;

                            if (loggedInUser == null ||
                                !(loggedInUser.isGlobalModerator ?? false))
                              return const SizedBox();

                            return ListTile(
                              leading: const OBIcon(OBIcons.globalModerator),
                              title: OBText(localizationService.drawer__global_moderation),
                              onTap: () async {
                                navigationService
                                    .navigateToGlobalModeratedObjects(
                                        context: context);
                              },
                            );
                          },
                        ),
                        ListTile(
                          leading: const OBIcon(OBIcons.link),
                          title: OBText(localizationService.drawer__useful_links_title),
                          onTap: () {
                            navigationService.navigateToUsefulLinksPage(
                                context: context);
                          },
                        ),
                        ListTile(
                          leading: const OBIcon(OBIcons.logout),
                          title: OBText(
                              localizationService.trans('drawer__logout')),
                          onTap: () {
                            userService.logout();
                          },
                        )
                      ],
                    ));
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class OBMainMenuPageController extends PoppablePageController {}
