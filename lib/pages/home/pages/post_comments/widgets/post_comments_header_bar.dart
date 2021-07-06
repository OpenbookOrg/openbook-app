import 'package:Okuna/models/post_comment.dart';
import 'package:Okuna/pages/home/pages/post_comments/post_comments_page_controller.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/theme.dart';
import 'package:Okuna/services/theme_value_parser.dart';
import 'package:Okuna/widgets/icon.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:flutter/material.dart';
import 'package:Okuna/widgets/theming/secondary_text.dart';


class OBPostCommentsHeaderBar extends StatelessWidget {
  PostCommentsPageType pageType;
  bool noMoreTopItemsToLoad;
  List<PostComment> postComments;
  PostCommentsSortType currentSort;
  VoidCallback onWantsToToggleSortComments;
  VoidCallback loadMoreTopComments;
  VoidCallback onWantsToRefreshComments;

  OBPostCommentsHeaderBar({
    required this.pageType,
    required this.noMoreTopItemsToLoad,
    required this.postComments,
    required this.currentSort,
    required this.onWantsToToggleSortComments,
    required this.loadMoreTopComments,
    required this.onWantsToRefreshComments,
  });

  @override
  Widget build(BuildContext context) {
    var provider = OpenbookProvider.of(context);
    ThemeService _themeService = provider.themeService;
    LocalizationService _localizationService = provider.localizationService;
    ThemeValueParserService _themeValueParserService = provider.themeValueParserService;
    var theme = _themeService.getActiveTheme();
    late Map<String, String> _pageTextMap;
    if (this.pageType == PostCommentsPageType.comments) {
      _pageTextMap = this.getPageCommentsMap(_localizationService);
    } else {
      _pageTextMap = this.getPageRepliesMap(_localizationService);
    }


    if (this.noMoreTopItemsToLoad) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                child: OBSecondaryText(
                  this.postComments.length > 0
                      ? this.currentSort == PostCommentsSortType.dec
                      ? _pageTextMap['NEWEST']!
                      : _pageTextMap['OLDEST']!
                      : _pageTextMap['BE_THE_FIRST']!,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                ),
              ),
            ),
            Expanded(
              child: FlatButton(
                  child: OBText(
                    this.postComments.length > 0
                        ? this.currentSort == PostCommentsSortType.dec
                        ?  _pageTextMap['SEE_OLDEST']!
                        :  _pageTextMap['SEE_NEWEST']!
                        : '',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: _themeValueParserService
                            .parseGradient(theme.primaryAccentColor)
                            .colors[1],
                        fontWeight: FontWeight.bold),
                  ),
                  onPressed: this.onWantsToToggleSortComments),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              flex: 4,
              child: FlatButton(
                  child: Row(
                    children: <Widget>[
                      OBIcon(OBIcons.arrowUp),
                      const SizedBox(width: 10.0),
                      OBText(
                        this.currentSort == PostCommentsSortType.dec
                            ?  _pageTextMap['NEWER']!
                            :  _pageTextMap['OLDER']!,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  onPressed: this.loadMoreTopComments),
            ),
            Expanded(
              flex: 6,
              child: FlatButton(
                  child: OBText(
                    this.currentSort == PostCommentsSortType.dec
                        ? _pageTextMap['VIEW_NEWEST']!
                        :  _pageTextMap['VIEW_OLDEST']!,
                    style: TextStyle(
                        color: _themeValueParserService
                            .parseGradient(theme.primaryAccentColor)
                            .colors[1],
                        fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  onPressed: this.onWantsToRefreshComments),
            ),
          ],
        ),
      );
    }
  }

  Map<String, String> getPageCommentsMap(LocalizationService _localizationService) {
    return {
      'NEWEST': _localizationService.post__comments_header_newest_comments,
      'NEWER': _localizationService.post__comments_header_newer,
      'VIEW_NEWEST': _localizationService.post__comments_header_view_newest_comments,
      'SEE_NEWEST': _localizationService.post__comments_header_see_newest_comments,
      'OLDEST': _localizationService.post__comments_header_oldest_comments,
      'OLDER': _localizationService.post__comments_header_older,
      'VIEW_OLDEST': _localizationService.post__comments_header_view_oldest_comments,
      'SEE_OLDEST': _localizationService.post__comments_header_see_oldest_comments,
      'BE_THE_FIRST': _localizationService.post__comments_header_be_the_first_comments,
    };
  }

  Map<String, String> getPageRepliesMap(LocalizationService _localizationService) {
    return  {
      'NEWEST': _localizationService.post__comments_header_newest_replies,
      'NEWER': _localizationService.post__comments_header_newer,
      'VIEW_NEWEST': _localizationService.post__comments_header_view_newest_replies,
      'SEE_NEWEST': _localizationService.post__comments_header_see_newest_replies,
      'OLDEST': _localizationService.post__comments_header_oldest_replies,
      'OLDER': _localizationService.post__comments_header_older,
      'VIEW_OLDEST': _localizationService.post__comments_header_view_oldest_replies,
      'SEE_OLDEST': _localizationService.post__comments_header_see_oldest_replies,
      'BE_THE_FIRST': _localizationService.post__comments_header_be_the_first_replies,
    };
  }
}
