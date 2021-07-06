import 'package:Okuna/widgets/tiles/actions/exclude_joined_communities_from_top_posts_tile.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/navigation_service.dart';
import 'package:Okuna/widgets/icon.dart';
import 'package:Okuna/widgets/nav_bars/themed_nav_bar.dart';
import 'package:Okuna/widgets/page_scaffold.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/widgets/theming/divider.dart';
import 'package:Okuna/widgets/theming/primary_color_container.dart';
import 'package:Okuna/widgets/theming/secondary_text.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OBTopPostsSettingsPage extends StatefulWidget {
  @override
  State<OBTopPostsSettingsPage> createState() {
    return OBTopPostsSettingsState();
  }
}

class OBTopPostsSettingsState extends State<OBTopPostsSettingsPage> {
  late NavigationService _navigationService;
  late LocalizationService _localizationService;

  late bool _needsBootstrap;

  @override
  void initState() {
    super.initState();
    _needsBootstrap = true;
  }

  @override
  Widget build(BuildContext context) {
    if (_needsBootstrap) {
      var provider = OpenbookProvider.of(context);
      _navigationService = provider.navigationService;
      _localizationService = provider.localizationService;
      _needsBootstrap = false;
    }

    return OBCupertinoPageScaffold(
        navigationBar: OBThemedNavigationBar(
          title: _localizationService.community__top_posts_settings,
        ),
        child: OBPrimaryColorContainer(
          child: Column(
            children: <Widget>[
              ListView(
                // Important: Remove any padding from the ListView.
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                children: <Widget>[
                  ListTile(
                    leading: const OBIcon(OBIcons.excludePostCommunity),
                    subtitle: OBSecondaryText(
                        _localizationService
                            .community__top_posts_excluded_communities_desc),
                    title:
                    OBText(_localizationService
                        .community__top_posts_excluded_communities),
                    onTap: () {
                      _navigationService
                          .navigateToTopPostsExcludedCommunities(
                          context: context);
                    },
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(left: 20.0, right: 20.0, bottom: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    OBDivider(),
                    OBExcludeJoinedCommunitiesTile()
                  ]
                )
              ),
            ],
          )
        )
    );
  }
}
