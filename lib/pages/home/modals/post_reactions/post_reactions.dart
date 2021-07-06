import 'package:Okuna/models/emoji.dart';
import 'package:Okuna/models/post.dart';
import 'package:Okuna/models/reactions_emoji_count.dart';
import 'package:Okuna/models/theme.dart';
import 'package:Okuna/pages/home/modals/post_reactions/widgets/post_reaction_list.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/theme.dart';
import 'package:Okuna/services/theme_value_parser.dart';
import 'package:Okuna/widgets/emoji_picker/widgets/emoji_groups/widgets/emoji_group/widgets/emoji.dart';
import 'package:Okuna/widgets/nav_bars/themed_nav_bar.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/widgets/page_scaffold.dart';
import 'package:Okuna/widgets/theming/primary_color_container.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OBPostReactionsModal extends StatefulWidget {
  // The post to display the reactions for
  final Post post;

  // The optional emoji to show first
  final Emoji? reactionEmoji;

  // The post reactiosn emoji counts
  final List<ReactionsEmojiCount?> reactionsEmojiCounts;

  const OBPostReactionsModal(
      {Key? key,
      required this.post,
      this.reactionEmoji,
      required this.reactionsEmojiCounts})
      : super(key: key);

  @override
  OBPostReactionsModalState createState() {
    return OBPostReactionsModalState();
  }
}

class OBPostReactionsModalState extends State<OBPostReactionsModal>
    with TickerProviderStateMixin {
  late ThemeService _themeService;
  late LocalizationService _localizationService;
  late ThemeValueParserService _themeValueParserService;
  late bool _needsBootstrap;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _needsBootstrap = true;
    _tabController =
        TabController(length: widget.reactionsEmojiCounts.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    if (_needsBootstrap) {
      var openbookProvider = OpenbookProvider.of(context);
      _themeService = openbookProvider.themeService;
      _themeValueParserService = openbookProvider.themeValueParserService;
      _localizationService = openbookProvider.localizationService;
      _bootstrap();
      _needsBootstrap = false;
    }

    OBTheme theme = _themeService.getActiveTheme();

    Color tabIndicatorColor = _themeValueParserService
        .parseGradient(theme.primaryAccentColor)
        .colors[1];

    return OBCupertinoPageScaffold(
        navigationBar: _buildNavigationBar(_localizationService),
        child: OBPrimaryColorContainer(
          child: Column(
            children: <Widget>[
              TabBar(
                controller: _tabController,
                tabs: _buildPostReactionsIcons(),
                isScrollable: true,
                indicatorColor: tabIndicatorColor,
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: _buildPostReactionsTabs(),
                ),
              )
            ],
          ),
        ));
  }

  List<Widget> _buildPostReactionsTabs() {
    return widget.reactionsEmojiCounts.map((reactionsEmojiCount) {
      return OBPostReactionList(
        post: widget.post,
        emoji: reactionsEmojiCount?.emoji,
      );
    }).toList();
  }

  List<Widget> _buildPostReactionsIcons() {
    return widget.reactionsEmojiCounts.map((reactionsEmojiCount) {
      if (reactionsEmojiCount == null) {
        return SizedBox();
      }

      return Padding(
        padding: EdgeInsets.symmetric(vertical: 5),
        child: Tab(icon: OBEmoji(reactionsEmojiCount.emoji!)),
      );
    }).toList();
  }

  ObstructingPreferredSizeWidget _buildNavigationBar(LocalizationService localizationService) {
    return OBThemedNavigationBar(
        title: localizationService.post__post_reactions_title);
  }

  void _bootstrap() async {
    int tabIndex = 0;

    if (widget.reactionEmoji != null) {
      tabIndex = widget.reactionsEmojiCounts.indexWhere((reactionEmojiCount) {
        return reactionEmojiCount?.emoji?.id == widget.reactionEmoji!.id;
      });
    }

    _tabController.index = tabIndex;
  }
}
