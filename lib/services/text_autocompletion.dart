import 'package:Okuna/services/validation.dart';
import 'package:flutter/cupertino.dart';

class TextAutocompletionService {
  static const String _usernamePrefix = '@';
  static const String _hashtagPrefix = '#';
  static const String _communityPrefix = 'c/';

  late ValidationService _validationService;

  void setValidationService(validationService) {
    _validationService = validationService;
  }

  TextAutocompletionResult checkTextForAutocompletion(
      TextEditingController textController) {
    int cursorPosition = textController.selection.baseOffset;

    if (cursorPosition >= 1) {
      String lastWord =
          _getWordBeforeCursor(textController.text, cursorPosition);

      if (lastWord.startsWith(_usernamePrefix)) {
        String searchQuery = lastWord.substring(_usernamePrefix.length);
        return TextAutocompletionResult(
            isAutocompleting: true,
            autocompleteQuery: searchQuery,
            type: TextAutocompletionType.account);
      } else if (lastWord.startsWith(_communityPrefix)) {
        String searchQuery = lastWord.substring(_communityPrefix.length);
        return TextAutocompletionResult(
            isAutocompleting: true,
            autocompleteQuery: searchQuery,
            type: TextAutocompletionType.community);
      } else if (lastWord.startsWith(_hashtagPrefix) && lastWord.length > 1 &&
          _validationService.isPostTextContainingValidHashtags(lastWord)) {
        String searchQuery = lastWord.substring(_hashtagPrefix.length);
        return TextAutocompletionResult(
            isAutocompleting: true,
            autocompleteQuery: searchQuery,
            type: TextAutocompletionType.hashtag);
      }
    }

    return TextAutocompletionResult(isAutocompleting: false);
  }

  void autocompleteTextWithUsername(
      TextEditingController textController, String username) {
    _autocompleteText(textController, username, _usernamePrefix,
        () => throw 'Tried to autocomplete text with username without $_usernamePrefix');
  }

  void autocompleteTextWithHashtagName(
      TextEditingController textController, String hashtag) {
    _autocompleteText(textController, hashtag, _hashtagPrefix,
        () => throw 'Tried to autocomplete text with hashtag without $_hashtagPrefix');
  }

  void autocompleteTextWithCommunityName(
      TextEditingController textController, String communityName) {
    _autocompleteText(textController, communityName, _communityPrefix,
        () => throw 'Tried to autocomplete text with community name without $_communityPrefix');
  }

  String _getWordBeforeCursor(String text, int cursorPosition) {
    if (text.isNotEmpty) {
      var start = text.lastIndexOf(RegExp(r'\s'), cursorPosition - 1);
      return text.substring(start + 1, cursorPosition);
    } else {
      return text;
    }
  }

  void _autocompleteText(TextEditingController textController, String value,
      String prefix, VoidCallback onPrefixMissing) {
    String text = textController.text;
    int cursorPosition = textController.selection.baseOffset;
    String lastWord = _getWordBeforeCursor(text, cursorPosition);

    if (!lastWord.startsWith(prefix)) {
      onPrefixMissing();
    }

    var newTextStart =
        text.substring(0, cursorPosition - lastWord.length) + '$prefix$value ';
    var newTextEnd = text.substring(cursorPosition);
    var newSelection = TextSelection.collapsed(offset: newTextStart.length);

    textController.value = TextEditingValue(
        text: newTextStart + newTextEnd, selection: newSelection);
  }
}

class TextAutocompletionResult {
  final bool isAutocompleting;
  final String? autocompleteQuery;
  final TextAutocompletionType? type;

  TextAutocompletionResult(
      {required this.isAutocompleting, this.type, this.autocompleteQuery});
}

enum TextAutocompletionType { account, community, hashtag }
