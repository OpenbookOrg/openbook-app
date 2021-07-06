import 'package:Okuna/models/emoji.dart';
import 'package:Okuna/models/emoji_group.dart';
import 'package:Okuna/models/emoji_group_list.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/user.dart';
import 'package:Okuna/widgets/emoji_picker/widgets/emoji_groups/emoji_groups.dart';
import 'package:Okuna/widgets/emoji_picker/widgets/emoji_search_results.dart';
import 'package:Okuna/widgets/search_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OBEmojiPicker extends StatefulWidget {
  final OnEmojiPicked? onEmojiPicked;
  final bool isReactionsPicker;
  final bool hasSearch;

  OBEmojiPicker(
      {this.onEmojiPicked,
      this.isReactionsPicker = false,
      this.hasSearch = true});

  @override
  State<StatefulWidget> createState() {
    return OBEmojiPickerState();
  }
}

class OBEmojiPickerState extends State<OBEmojiPicker> {
  late UserService _userService;

  late bool _needsBootstrap;
  late bool _hasSearch;

  late List<EmojiGroup> _emojiGroups;
  late List<EmojiGroupSearchResults> _emojiSearchResults;
  late String _emojiSearchQuery;

  @override
  void initState() {
    super.initState();
    _emojiGroups = [];
    _emojiSearchResults = [];
    _emojiSearchQuery = '';
    _needsBootstrap = true;
    _hasSearch = false;
  }

  @override
  Widget build(BuildContext context) {
    var openbookProvider = OpenbookProvider.of(context);
    _userService = openbookProvider.userService;

    if (_needsBootstrap) {
      _bootstrap();
      _needsBootstrap = false;
    }

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        _hasSearch
            ? OBSearchBar(
                onSearch: _onSearch,
                hintText: 'Search emojis...',
              )
            : const SizedBox(),
        Expanded(
            child: _hasSearch
                ? OBEmojiSearchResults(
                    _emojiSearchResults,
                    _emojiSearchQuery,
                    onEmojiPressed: _onEmojiPressed,
                  )
                : OBEmojiGroups(
                    _emojiGroups,
                    onEmojiPressed: _onEmojiPressed,
                  ))
      ],
    );
  }

  void _onEmojiPressed(Emoji pressedEmoji, EmojiGroup? emojiGroup) {
    if (widget.onEmojiPicked == null) {
      return;
    }

    widget.onEmojiPicked!(pressedEmoji, emojiGroup);
  }

  void _onSearch(String searchString) {
    if (searchString.length == 0) {
      _setHasSearch(false);
      return;
    }

    if (!_hasSearch) _setHasSearch(true);

    String standarisedSearchStr = searchString.toLowerCase();

    List<EmojiGroupSearchResults> searchResults =
        _emojiGroups.map((EmojiGroup emojiGroup) {
      List<Emoji> groupEmojis = emojiGroup.getEmojis()!;
      List<Emoji> groupSearchResults = groupEmojis.where((Emoji emoji) {
        return emoji.keyword!.toLowerCase().contains(standarisedSearchStr);
      }).toList();
      return EmojiGroupSearchResults(
          group: emojiGroup, searchResults: groupSearchResults);
    }).toList();

    _setEmojiSearchResults(searchResults);
    _setEmojiSearchQuery(searchString);
  }

  void _bootstrap() async {
    EmojiGroupList emojiGroupList = await (widget.isReactionsPicker
        ? _userService.getReactionEmojiGroups()
        : _userService.getEmojiGroups());
    this._setEmojiGroups(emojiGroupList.emojisGroups!);
  }

  void _setEmojiGroups(List<EmojiGroup> emojiGroups) {
    setState(() {
      _emojiGroups = emojiGroups;
    });
  }

  void _setEmojiSearchResults(
      List<EmojiGroupSearchResults> emojiSearchResults) {
    setState(() {
      _emojiSearchResults = emojiSearchResults;
    });
  }

  void _setEmojiSearchQuery(String searchQuery) {
    setState(() {
      _emojiSearchQuery = searchQuery;
    });
  }

  void _setHasSearch(bool hasSearch) {
    setState(() {
      _hasSearch = hasSearch;
    });
  }
}

enum OBEmojiPickerStatus { searching, suggesting, overview }

typedef void OnEmojiPicked(Emoji pickedEmoji, EmojiGroup? emojiGroup);

class EmojiGroupSearchResults {
  final EmojiGroup group;
  final List<Emoji> searchResults;

  EmojiGroupSearchResults({required this.group, required this.searchResults});
}
