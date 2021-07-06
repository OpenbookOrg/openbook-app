import 'package:Okuna/models/community.dart';
import 'package:Okuna/models/hashtag.dart';
import 'package:Okuna/models/user.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/text_autocompletion.dart';
import 'package:Okuna/widgets/contextual_search_boxes/contextual_account_search_box.dart';
import 'package:Okuna/widgets/contextual_search_boxes/contextual_community_search_box.dart';
import 'package:Okuna/widgets/contextual_search_boxes/contextual_hashtag_search_box.dart';
import 'package:flutter/material.dart';

abstract class OBContextualSearchBoxState<T extends StatefulWidget>
    extends State<T> {
  late TextAutocompletionService _textAutocompletionService;
  late OBContextualAccountSearchBoxController _contextualAccountSearchBoxController;
  late OBContextualCommunitySearchBoxController
      _contextualCommunitySearchBoxController;
  late OBContextualHashtagSearchBoxController _contextualHashtagSearchBoxController;

  TextAutocompletionType? _autocompletionType;

  TextEditingController? _autocompleteTextController;

  late bool isAutocompleting;

  @override
  void initState() {
    super.initState();
    _contextualAccountSearchBoxController =
        OBContextualAccountSearchBoxController();
    _contextualCommunitySearchBoxController =
        OBContextualCommunitySearchBoxController();
    _contextualHashtagSearchBoxController =
        OBContextualHashtagSearchBoxController();
    isAutocompleting = false;
  }

  @override
  void dispose() {
    super.dispose();
    _autocompleteTextController?.removeListener(_checkForAutocomplete);
  }

  void bootstrap() {
    OpenbookProviderState openbookProvider = OpenbookProvider.of(context);
    _textAutocompletionService =
        openbookProvider.textAccountAutocompletionService;
  }

  void setAutocompleteTextController(TextEditingController textController) {
    _autocompleteTextController = textController;
    textController.addListener(_checkForAutocomplete);
  }

  Widget buildSearchBox() {
    if (!isAutocompleting) {
      throw 'There is no current autocompletion';
    }

    switch (_autocompletionType) {
      case TextAutocompletionType.account:
        return _buildAccountSearchBox();
      case TextAutocompletionType.community:
        return _buildCommunitySearchBox();
      case TextAutocompletionType.hashtag:
        return _buildHashtagSearchBox();
      default:
        throw 'Unhandled text autocompletion type';
    }
  }

  Widget _buildAccountSearchBox() {
    return OBContextualAccountSearchBox(
      controller: _contextualAccountSearchBoxController,
      onPostParticipantPressed: _onAccountSearchBoxUserPressed,
      initialSearchQuery:
          _contextualAccountSearchBoxController.getLastSearchQuery(),
    );
  }

  Widget _buildCommunitySearchBox() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: OBContextualCommunitySearchBox(
        controller: _contextualCommunitySearchBoxController,
        onCommunityPressed: _onCommunitySearchBoxUserPressed,
        initialSearchQuery:
            _contextualCommunitySearchBoxController.getLastSearchQuery(),
      ),
    );
  }

  Widget _buildHashtagSearchBox() {
    return OBContextualHashtagSearchBox(
      controller: _contextualHashtagSearchBoxController,
      onHashtagPressed: _onHashtagSearchBoxUserPressed,
      initialSearchQuery:
      _contextualHashtagSearchBoxController.getLastSearchQuery(),
    );
  }

  void _onAccountSearchBoxUserPressed(User user) {
    autocompleteFoundAccountUsername(user.username!);
  }

  void _onCommunitySearchBoxUserPressed(Community community) {
    autocompleteFoundCommunityName(community.name!);
  }

  void _onHashtagSearchBoxUserPressed(Hashtag hashtag) {
    autocompleteFoundHashtagName(hashtag.name!);
  }

  void _checkForAutocomplete() {
    TextAutocompletionResult? result = _autocompleteTextController != null
      ? _textAutocompletionService
        .checkTextForAutocompletion(_autocompleteTextController!)
      : null;

    if (result != null && result.isAutocompleting) {
      debugLog('Wants to autocomplete with type ${result.type} searchQuery:' +
          (result.autocompleteQuery ?? 'null'));
      _setIsAutocompleting(true);
      _setAutocompletionType(result.type);
      switch (result.type) {
        case TextAutocompletionType.hashtag:
          _contextualHashtagSearchBoxController
              .search(result.autocompleteQuery ?? '');
          break;
        case TextAutocompletionType.account:
          _contextualAccountSearchBoxController
              .search(result.autocompleteQuery ?? '');
          break;
        case TextAutocompletionType.community:
          _contextualCommunitySearchBoxController
              .search(result.autocompleteQuery ?? '');
          break;
        case null:
          break;
      }
    } else if (isAutocompleting) {
      debugLog('Finished autocompleting');
      _setIsAutocompleting(false);
    }
  }

  void autocompleteFoundAccountUsername(String foundAccountUsername) {
    if (!isAutocompleting) {
      debugLog(
          'Tried to autocomplete found account username but was not searching account');
      return;
    }

    debugLog('Autocompleting with username:$foundAccountUsername');
    setState(() {
      if (_autocompleteTextController != null) {
        _textAutocompletionService.autocompleteTextWithUsername(
            _autocompleteTextController!, foundAccountUsername);
      }
    });
  }

  void autocompleteFoundCommunityName(String foundCommunityName) {
    if (!isAutocompleting) {
      debugLog(
          'Tried to autocomplete found community name but was not searching community');
      return;
    }

    debugLog('Autocompleting with name:$foundCommunityName');
    setState(() {
      if (_autocompleteTextController != null) {
        _textAutocompletionService.autocompleteTextWithCommunityName(
            _autocompleteTextController!, foundCommunityName);
      }
    });
  }

  void autocompleteFoundHashtagName(String foundHashtagName) {
    if (!isAutocompleting) {
      debugLog(
          'Tried to autocomplete found hashtag name but was not searching hashtag');
      return;
    }

    debugLog('Autocompleting with name:$foundHashtagName');
    setState(() {
      if (_autocompleteTextController != null) {
        _textAutocompletionService.autocompleteTextWithHashtagName(
            _autocompleteTextController!, foundHashtagName);
      }
    });
  }

  void _setIsAutocompleting(bool isSearchingAccount) {
    setState(() {
      isAutocompleting = isSearchingAccount;
    });
  }

  void _setAutocompletionType(TextAutocompletionType? autocompletionType) {
    setState(() {
      _autocompletionType = autocompletionType;
    });
  }

  void setState(VoidCallback fn);

  void debugLog(String log) {
    debugPrint('ContextualSearchBoxStateMixin:$log');
  }
}
