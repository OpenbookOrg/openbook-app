import 'package:Okuna/models/theme.dart';
import 'package:Okuna/provider.dart';
import 'package:flutter/material.dart';

enum OBIconSize { small, medium, large, extraLarge }

class OBIcon extends StatelessWidget {
  final OBIconData iconData;
  final OBIconSize? size;
  final double? customSize;
  final Color? color;
  final OBIconThemeColor? themeColor;
  final String? semanticLabel;

  static const double EXTRA_LARGE = 45.0;
  static const double LARGE_SIZE = 30.0;
  static const double MEDIUM_SIZE = 25.0;
  static const double SMALL_SIZE = 15.0;

  const OBIcon(this.iconData,
      {Key? key,
      this.size,
      this.customSize,
      this.color,
      this.themeColor,
      this.semanticLabel})
      : assert(!(color != null && themeColor != null)),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    late double iconSize;

    if (this.customSize != null) {
      iconSize = this.customSize!;
    } else {
      var finalSize = size ?? OBIconSize.medium;
      switch (finalSize) {
        case OBIconSize.extraLarge:
          iconSize = EXTRA_LARGE;
          break;
        case OBIconSize.large:
          iconSize = LARGE_SIZE;
          break;
        case OBIconSize.medium:
          iconSize = MEDIUM_SIZE;
          break;
        case OBIconSize.small:
          iconSize = SMALL_SIZE;
          break;
        default:
          throw 'Unsupported OBIconSize';
      }
    }

    var themeService = OpenbookProvider.of(context).themeService;
    var themeValueParser = OpenbookProvider.of(context).themeValueParserService;

    return StreamBuilder(
        stream: themeService.themeChange,
        initialData: themeService.getActiveTheme(),
        builder: (BuildContext context, AsyncSnapshot<OBTheme> snapshot) {
          var theme = snapshot.data;

          Widget icon;

          if (iconData.nativeIcon != null) {
            Color? iconColor;
            Gradient? iconGradient;

            if (color != null) {
              iconColor = color!;
            } else {
              switch (themeColor) {
                case OBIconThemeColor.primary:
                  iconColor = themeValueParser.parseColor(theme!.primaryColor);
                  break;
                case OBIconThemeColor.primaryText:
                  iconColor =
                      themeValueParser.parseColor(theme!.primaryTextColor);
                  break;
                case OBIconThemeColor.secondaryText:
                  iconColor =
                      themeValueParser.parseColor(theme!.secondaryTextColor);
                  break;
                case OBIconThemeColor.primaryAccent:
                  iconGradient =
                      themeValueParser.parseGradient(theme!.primaryAccentColor);
                  break;
                case OBIconThemeColor.danger:
                  iconGradient =
                      themeValueParser.parseGradient(theme!.dangerColor);
                  break;
                default:
                  iconColor =
                      themeValueParser.parseColor(theme!.primaryTextColor);
              }
            }

            if (iconColor != null) {
              icon = Icon(
                iconData.nativeIcon,
                size: iconSize,
                color: iconColor,
                semanticLabel: semanticLabel,
              );
            } else {
              icon = ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (Rect bounds) {
                  return iconGradient!.createShader(bounds);
                },
                child: Icon(
                  iconData.nativeIcon,
                  color: Colors.white,
                  size: iconSize,
                ),
              );
            }
          } else {
            String iconName = iconData.filename!;
            icon =
                Image.asset('assets/images/icons/$iconName', height: iconSize);
          }

          return icon;
        });
  }
}

class OBIcons {
  static const home = OBIconData(nativeIcon: Icons.home);
  static const explore = OBIconData(nativeIcon: Icons.public);
  static const trending = OBIconData(nativeIcon: Icons.whatshot);
  static const pause = OBIconData(nativeIcon: Icons.pause);
  static const play_arrow = OBIconData(nativeIcon: Icons.play_arrow);
  static const fullscreen_exit = OBIconData(nativeIcon: Icons.fullscreen_exit);
  static const fullscreen = OBIconData(nativeIcon: Icons.fullscreen);
  static const volume_up = OBIconData(nativeIcon: Icons.volume_up);
  static const volume_off = OBIconData(nativeIcon: Icons.volume_off);
  static const search = OBIconData(nativeIcon: Icons.search);
  static const okuna_age_baby = OBIconData(nativeIcon: Icons.child_care);
  static const okuna_age_smile = OBIconData(nativeIcon: Icons.sentiment_satisfied);
  static const notifications = OBIconData(nativeIcon: Icons.notifications);
  static const notifications_off = OBIconData(nativeIcon: Icons.notifications_off);
  static const language = OBIconData(nativeIcon: Icons.language);
  static const translate = OBIconData(nativeIcon: Icons.translate);
  static const menu = OBIconData(nativeIcon: Icons.menu);
  static const communities = OBIconData(nativeIcon: Icons.bubble_chart);
  static const settings = OBIconData(nativeIcon: Icons.settings);
  static const lists = OBIconData(nativeIcon: Icons.library_books);
  static const addToList = OBIconData(nativeIcon: Icons.queue);
  static const removeFromList = OBIconData(nativeIcon: Icons.delete);
  static const customize = OBIconData(nativeIcon: Icons.format_paint);
  static const logout = OBIconData(nativeIcon: Icons.exit_to_app);
  static const help = OBIconData(nativeIcon: Icons.help);
  static const refresh = OBIconData(nativeIcon: Icons.refresh);
  static const retry = OBIconData(nativeIcon: Icons.refresh);
  static const connections = OBIconData(nativeIcon: Icons.people);
  static const createPost = OBIconData(nativeIcon: Icons.add);
  static const add = OBIconData(nativeIcon: Icons.add);
  static const loadMore = OBIconData(nativeIcon: Icons.add);
  static const moreVertical = OBIconData(nativeIcon: Icons.more_vert);
  static const moreHorizontal = OBIconData(nativeIcon: Icons.more_horiz);
  static const react = OBIconData(nativeIcon: Icons.sentiment_very_satisfied);
  static const comment = OBIconData(nativeIcon: Icons.chat_bubble_outline);
  static const chat = OBIconData(nativeIcon: Icons.chat);
  static const close = OBIconData(nativeIcon: Icons.close);
  static const cancel = OBIconData(nativeIcon: Icons.close);
  static const sad = OBIconData(nativeIcon: Icons.sentiment_dissatisfied);
  static const happy = OBIconData(nativeIcon: Icons.sentiment_very_satisfied);
  static const location = OBIconData(nativeIcon: Icons.location_on);
  static const link = OBIconData(nativeIcon: Icons.link);
  static const linkOff = OBIconData(nativeIcon: Icons.link_off);
  static const email = OBIconData(nativeIcon: Icons.email);
  static const lock = OBIconData(nativeIcon: Icons.lock);
  static const bio = OBIconData(nativeIcon: Icons.bookmark);
  static const name = OBIconData(nativeIcon: Icons.person);
  static const followers = OBIconData(nativeIcon: Icons.supervisor_account);
  static const following = OBIconData(nativeIcon: Icons.person);
  static const cake = OBIconData(nativeIcon: Icons.cake);
  static const remove = OBIconData(nativeIcon: Icons.remove_circle_outline);
  static const checkCircle =
      OBIconData(nativeIcon: Icons.radio_button_unchecked);
  static const checkCircleSelected = OBIconData(nativeIcon: Icons.check_circle);
  static const check = OBIconData(nativeIcon: Icons.check);
  static const circles = OBIconData(nativeIcon: Icons.group_work);
  static const follow = OBIconData(nativeIcon: Icons.notifications);
  static const unfollow = OBIconData(nativeIcon: Icons.notifications_off);
  static const connect = OBIconData(nativeIcon: Icons.group_add);
  static const disconnect = OBIconData(nativeIcon: Icons.remove_circle_outline);
  static const deletePost = OBIconData(nativeIcon: Icons.delete);
  static const clear = OBIconData(nativeIcon: Icons.delete);
  static const report = OBIconData(nativeIcon: Icons.flag);
  static const filter = OBIconData(nativeIcon: Icons.tune);
  static const gallery = OBIconData(nativeIcon: Icons.apps);
  static const movie = OBIconData(nativeIcon: Icons.local_movies);
  static const picture = OBIconData(nativeIcon: Icons.image);
  static const camera = OBIconData(nativeIcon: Icons.camera_alt);
  static const video_camera = OBIconData(nativeIcon: Icons.videocam);
  static const privateCommunity = OBIconData(nativeIcon: Icons.lock);
  static const publicCommunity = OBIconData(nativeIcon: Icons.public);
  static const communityDescription = OBIconData(nativeIcon: Icons.book);
  static const communityTitle = OBIconData(nativeIcon: Icons.public);
  static const communityName = OBIconData(nativeIcon: Icons.public);
  static const communityRules = OBIconData(nativeIcon: Icons.straighten);
  static const category = OBIconData(nativeIcon: Icons.category);
  static const communityMember = OBIconData(nativeIcon: Icons.person);
  static const communityMembers = OBIconData(nativeIcon: Icons.people);
  static const color = OBIconData(nativeIcon: Icons.format_paint);
  static const shortText = OBIconData(nativeIcon: Icons.short_text);
  static const communityAdministrators = OBIconData(nativeIcon: Icons.star);
  static const communityModerators = OBIconData(nativeIcon: Icons.gavel);
  static const communityBannedUsers = OBIconData(nativeIcon: Icons.block);
  static const deleteCommunity = OBIconData(nativeIcon: Icons.delete_forever);
  static const seeMore = OBIconData(nativeIcon: Icons.arrow_right);
  static const leaveCommunity = OBIconData(nativeIcon: Icons.exit_to_app);
  static const reportCommunity = OBIconData(nativeIcon: Icons.flag);
  static const communityInvites = OBIconData(nativeIcon: Icons.email);
  static const favoriteCommunity = OBIconData(nativeIcon: Icons.favorite);
  static const unfavoriteCommunity =
      OBIconData(nativeIcon: Icons.remove_circle);
  static const expand = OBIconData(filename: 'expand-icon.png');
  static const mutePost = OBIconData(nativeIcon: Icons.notifications_active);
  static const excludePostCommunity = OBIconData(nativeIcon: Icons.not_interested);
  static const undoExcludePostCommunity = OBIconData(nativeIcon: Icons.check);
  static const mutePostComment = OBIconData(nativeIcon: Icons.notifications_active);
  static const editPost = OBIconData(nativeIcon: Icons.edit);
  static const edit = OBIconData(nativeIcon: Icons.edit);
  static const reviewModeratedObject = OBIconData(nativeIcon: Icons.gavel);
  static const unmutePost = OBIconData(nativeIcon: Icons.notifications_off);
  static const unmutePostComment =
      OBIconData(nativeIcon: Icons.notifications_off);
  static const deleteAccount = OBIconData(nativeIcon: Icons.delete_forever);
  static const account = OBIconData(nativeIcon: Icons.account_circle);
  static const application = OBIconData(nativeIcon: Icons.phone_iphone);
  static const arrowUp = OBIconData(nativeIcon: Icons.keyboard_arrow_up);
  static const arrowUpward = OBIconData(nativeIcon: Icons.arrow_upward);
  static const bug = OBIconData(nativeIcon: Icons.bug_report);
  static const featureRequest = OBIconData(nativeIcon: Icons.new_releases);
  static const guide = OBIconData(nativeIcon: Icons.book);
  static const slackChannel = OBIconData(nativeIcon: Icons.tag_faces);
  static const dashboard = OBIconData(nativeIcon: Icons.dashboard);
  static const roadmap = OBIconData(nativeIcon: Icons.assignment);
  static const themes = OBIconData(nativeIcon: Icons.format_paint);
  static const invite = OBIconData(nativeIcon: Icons.card_giftcard);
  static const disableComments = OBIconData(nativeIcon: Icons.chat_bubble);
  static const enableComments =
      OBIconData(nativeIcon: Icons.chat_bubble_outline);
  static const closePost = OBIconData(nativeIcon: Icons.lock_outline);
  static const openPost = OBIconData(nativeIcon: Icons.lock_open);
  static const block = OBIconData(nativeIcon: Icons.block);
  static const chevronRight = OBIconData(nativeIcon: Icons.chevron_right);
  static const verify = OBIconData(nativeIcon: Icons.check);
  static const unverify = OBIconData(nativeIcon: Icons.close);
  static const globalModerator = OBIconData(nativeIcon: Icons.account_balance);
  static const moderationPenalties = OBIconData(nativeIcon: Icons.flag);
  static const send = OBIconData(nativeIcon: Icons.send);
  static const arrowDown = OBIconData(nativeIcon: Icons.keyboard_arrow_down);
  static const rules = OBIconData(nativeIcon: Icons.book);
  static const communityStaff = OBIconData(nativeIcon: Icons.tag_faces);
  static const reply = OBIconData(nativeIcon: Icons.reply);
  static const support = OBIconData(nativeIcon: Icons.favorite);
  static const sound = OBIconData(nativeIcon: Icons.volume_up);
  static const linkPreviews = OBIconData(nativeIcon: Icons.library_books);
  static const nativeInfo = OBIconData(nativeIcon: Icons.info);
  static const hashtag = OBIconData(nativeIcon: Icons.label);
  static const visibility = OBIconData(nativeIcon: Icons.remove_red_eye);
  static const visibilityPublic = OBIconData(nativeIcon: Icons.public);
  static const visibilityOkuna = OBIconData(nativeIcon: Icons.people);
  static const visibilityPrivate = OBIconData(nativeIcon: Icons.lock);
  static const followRequests = OBIconData(nativeIcon: Icons.move_to_inbox);
  static const success = OBIconData(filename: 'success-icon.png');
  static const error = OBIconData(filename: 'error-icon.png');
  static const warning = OBIconData(filename: 'warning-icon.png');
  static const info = OBIconData(filename: 'info-icon.png');
  static const profile = OBIconData(filename: 'profile-icon.png');
  static const photo = OBIconData(filename: 'photo-icon.png');
  static const video = OBIconData(filename: 'video-icon.png');
  static const cameraCartoon = OBIconData(filename: 'camera-icon.png');
  static const gif = OBIconData(filename: 'gif-icon.png');
  static const audience = OBIconData(filename: 'audience-icon.png');
  static const burner = OBIconData(filename: 'burner-icon.png');
  static const comments = OBIconData(filename: 'comments-icon.png');
  static const like = OBIconData(filename: 'like-icon.png');
  static const thinking = OBIconData(filename: 'thinking.gif');
  static const finish = OBIconData(filename: 'finish-icon.png');
  static const staff = OBIconData(filename: 'staff-icon.png');
  static const loadingMorePosts =
      OBIconData(filename: 'load-more-posts-icon.gif');
}

@immutable
class OBIconData {
  final String? filename;
  final IconData? nativeIcon;

  const OBIconData({
    this.nativeIcon,
    this.filename,
  });
}

enum OBIconThemeColor {
  primary,
  primaryText,
  primaryAccent,
  danger,
  success,
  secondaryText
}
