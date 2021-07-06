import 'package:Okuna/models/community.dart';
import 'package:Okuna/models/theme.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/theme.dart';
import 'package:Okuna/services/theme_value_parser.dart';
import 'package:Okuna/widgets/avatars/letter_avatar.dart';
import 'package:Okuna/widgets/avatars/avatar.dart';
import 'package:flutter/material.dart';
import 'package:Okuna/libs/pretty_count.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:tinycolor/tinycolor.dart';

class OBCommunityTile extends StatelessWidget {
  static const COVER_PLACEHOLDER = 'assets/images/fallbacks/cover-fallback.jpg';

  static const double smallSizeHeight = 60;
  static const double normalSizeHeight = 80;

  final Community community;
  final ValueChanged<Community>? onCommunityTilePressed;
  final ValueChanged<Community>? onCommunityTileDeleted;
  final OBCommunityTileSize size;
  final Widget? trailing;

  const OBCommunityTile(this.community,
      {this.onCommunityTilePressed,
      this.onCommunityTileDeleted,
      Key? key,
      this.size = OBCommunityTileSize.normal,
      this.trailing})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String communityHexColor = community.color!;
    LocalizationService localizationService =
        OpenbookProvider.of(context).localizationService;
    ThemeService themeService = OpenbookProvider.of(context).themeService;
    ThemeValueParserService themeValueParserService =
        OpenbookProvider.of(context).themeValueParserService;
    Color communityColor =
        themeValueParserService.parseColor(communityHexColor);
    OBTheme theme = themeService.getActiveTheme();
    Color textColor;

    BoxDecoration containerDecoration;
    BorderRadius containerBorderRadius = BorderRadius.circular(10);
    bool isCommunityColorDark =
        themeValueParserService.isDarkColor(communityColor);
    bool communityHasCover = community.hasCover();

    if (communityHasCover) {
      textColor = Colors.white;
      containerDecoration = BoxDecoration(
          borderRadius: containerBorderRadius,
          image: DecorationImage(
              fit: BoxFit.cover,
              colorFilter: new ColorFilter.mode(
                  Colors.black.withOpacity(0.60), BlendMode.darken),
              image: AdvancedNetworkImage(community.cover!,
                  useDiskCache: true,
                  fallbackAssetImage: COVER_PLACEHOLDER,
                  retryLimit: 0)));
    } else {
      textColor = isCommunityColorDark ? Colors.white : Colors.black;
      bool communityColorIsNearWhite = communityColor.computeLuminance() > 0.9;

      containerDecoration = BoxDecoration(
        color: communityColorIsNearWhite
            ? TinyColor(communityColor).darken(5).color
            : TinyColor(communityColor).lighten(10).color,
        borderRadius: containerBorderRadius,
      );
    }

    bool isNormalSize = size == OBCommunityTileSize.normal;

    Widget communityAvatar;
    if (community.hasAvatar()) {
      communityAvatar = OBAvatar(
        avatarUrl: community.avatar,
        size: isNormalSize ? OBAvatarSize.medium : OBAvatarSize.small,
      );
    } else {
      Color avatarColor = communityHasCover
          ? communityColor
          : (isCommunityColorDark
              ? TinyColor(communityColor).lighten(5).color
              : communityColor);
      communityAvatar = OBLetterAvatar(
        letter: community.name![0],
        color: avatarColor,
        labelColor: textColor,
        size: isNormalSize ? OBAvatarSize.medium : OBAvatarSize.small,
      );
    }

    String userAdjective = community.userAdjective ??
        localizationService.community__member_capitalized;
    String usersAdjective = community.usersAdjective ??
        localizationService.community__members_capitalized;
    String? membersPrettyCount = community.membersCount != null
        ? getPrettyCount(community.membersCount!, localizationService)
        : null;
    String finalAdjective =
        community.membersCount == 1 ? userAdjective : usersAdjective;

    Widget communityTile = Container(
      height: isNormalSize ? normalSizeHeight : smallSizeHeight,
      decoration: containerDecoration,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: communityAvatar,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('c/' + community.name!,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis),
                Text(
                  community.title!,
                  style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                isNormalSize && membersPrettyCount != null
                    ? Text(
                        '$membersPrettyCount $finalAdjective',
                        style: TextStyle(color: textColor, fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      )
                    : SizedBox()
              ],
            ),
          ),
          trailing == null
              ? SizedBox(
                  width: 20,
                )
              : Padding(
                  child: trailing,
                  padding: const EdgeInsets.all(20),
                )
        ],
      ),
    );

    if (onCommunityTileDeleted != null && onCommunityTilePressed != null) {
      communityTile = Slidable(
        actionPane: SlidableDrawerActionPane(),
        actionExtentRatio: 0.25,
        child: GestureDetector(
          onTap: () {
            onCommunityTilePressed!(community);
          },
          child: communityTile,
        ),
        secondaryActions: <Widget>[
          new IconSlideAction(
              caption: localizationService.community__tile_delete,
              foregroundColor:
                  themeValueParserService.parseColor(theme.primaryTextColor),
              color: Colors.transparent,
              icon: Icons.delete,
              onTap: () {
                onCommunityTileDeleted!(community);
              }),
        ],
      );
    } else if (onCommunityTilePressed != null) {
      communityTile = GestureDetector(
        onTap: () {
          onCommunityTilePressed!(community);
        },
        child: communityTile,
      );
    }

    return communityTile;
  }
}

enum OBCommunityTileSize { normal, small }
