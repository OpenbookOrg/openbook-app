import 'package:Okuna/models/hashtag.dart';
import 'package:Okuna/models/theme.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/theme.dart';
import 'package:Okuna/services/theme_value_parser.dart';
import 'package:Okuna/widgets/hashtag.dart';
import 'package:Okuna/widgets/theming/text.dart';
export 'package:Okuna/widgets/theming/text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tinycolor/tinycolor.dart';
import 'dart:ui' as ui;
// Based on https://github.com/knoxpo/flutter_smart_text_view

abstract class SmartTextElement {
  /// Stores the text used when rendering the element
  String text;

  SmartTextElement(this.text);
}

/// Represents an element containing a link
class LinkElement extends SmartTextElement {
  final String url;

  LinkElement(this.url) : super(url);

  @override
  String toString() {
    return "LinkElement: $url";
  }
}

/// Represents an element containing a hastag
class HashtagElement extends SmartTextElement {
  final String tag;

  HashtagElement(this.tag) : super(tag);

  @override
  String toString() {
    return "HashTagElement: $tag";
  }
}

/// Represents an element containing a username
class UsernameElement extends SmartTextElement {
  final String username;

  UsernameElement(this.username) : super(username);

  @override
  String toString() {
    return "UsernameElement: $username";
  }
}

/// Represents an element containing a community name
class CommunityNameElement extends SmartTextElement {
  final String communityName;

  CommunityNameElement(this.communityName) : super(communityName);

  @override
  String toString() {
    return "CommunityNameElement: $communityName";
  }
}

/// Represents an element containing text
class TextElement extends SmartTextElement {
  TextElement(String text) : super(text);

  @override
  String toString() {
    return "TextElement: $text";
  }
}

/// Represents an element containing secondary text
class SecondaryTextElement extends SmartTextElement {
  SecondaryTextElement(String text) : super(text);

  @override
  String toString() {
    return "SecondaryTextElement: $text";
  }
}

final linkRegex = RegExp(
    r"(https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|www\.[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9]+\.[^\s]{2,}|www\.[a-zA-Z0-9]+\.[^\s]{2,})",
    caseSensitive: false);

final _tagRegex = RegExp(r"\B#\w*[a-zA-Z]+\w*", caseSensitive: false);

// Architecture of this regex:
//  (?:                                 don't capture this group, so the mention itself is still the first capturing group
//    \s|^                              make sure that no word characters are in front of name
//  )
//  (
//    \@                                 begin of mention
//    [A-Za-z0-9]                       first character of username
//    (?:
//      (?:
//        [A-Za-z0-9]|[._](?![._])      word character or one of [._] which may not be followed by another special char
//      ){0,28}                         repeat this 0 to 28 times
//      [A-Za-z0-9]                     always end on a word character
//    )?                                entire part is optional to allow single character names
//  )                                   end of mention
//  (?=\b|$)                            next char must be either a word boundary or end of text
final _usernameRegex = RegExp(
    r"(?:\s|^)(\@[A-Za-z0-9](?:(?:[A-Za-z0-9]|[._](?![._])){0,28}[A-Za-z0-9])?)(?:\b|$)",
    caseSensitive: false);

// Same idea as inner part of above regex, but only _ is allowed as special character
final _communityNameRegex = RegExp(
    r"((?:(?<=\s)|^)([/]?)c/([A-Za-z0-9]|[_](?![_])){1,30})(?=\b|$)",
    caseSensitive: false);

class SmartMatch {
  final SmartTextElement span;
  final int start;
  final int end;

  SmartMatch(this.span, this.start, this.end);
}

/// Turns [text] into a list of [SmartTextElement]
List<SmartTextElement> _smartify(String text) {
  List<SmartMatch> matches = [];
  matches.addAll(_usernameRegex.allMatches(text).map((m) {
    return SmartMatch(
        UsernameElement(m.group(1)!), m.start + m.group(0)!.indexOf("@"), m.end);
  }));
  matches.addAll(_communityNameRegex.allMatches(text).map((m) {
    return SmartMatch(CommunityNameElement(m.group(0)!), m.start, m.end);
  }));
  matches.addAll(linkRegex.allMatches(text).map((m) {
    return SmartMatch(LinkElement(m.group(0)!), m.start, m.end);
  }));

  matches.addAll(_tagRegex.allMatches(text).map((m) {
    return SmartMatch(HashtagElement(m.group(0)!), m.start, m.end);
  }));
  // matches.addAll(_tagRegex.allMatches(text).map((m) { return SmartMatch(HashTagElement(m.group(0)), m.start, m.end); }));
  matches.sort((a, b) {
    return a.start.compareTo(b.start);
  });

  if (matches.length == 0) {
    return [TextElement(text)];
  }

  List<SmartTextElement> span = [];
  int currentTextIndex = 0;
  int matchIndex = 0;
  SmartMatch? currentMatch = matches[matchIndex];
  while (currentTextIndex < text.length) {
    if (currentMatch == null) {
      // no more match found, add entire remaining text
      span.add(TextElement(text.substring(currentTextIndex)));
      break;
    } else if (currentTextIndex < currentMatch.start) {
      // there's normal text before the next match
      span.add(
          TextElement(text.substring(currentTextIndex, currentMatch.start)));
      currentTextIndex = currentMatch.start;
    } else if (currentTextIndex == currentMatch.start) {
      // next match starts here, add it
      span.add(currentMatch.span);
      currentTextIndex = currentMatch.end;
      matchIndex++;
      if (matchIndex < matches.length) {
        currentMatch = matches[matchIndex];
      } else {
        currentMatch = null;
      }
    } else {
      // we're already past a match, this can happen if we have overlapping matches, just move on to the next match
      matchIndex++;
      if (matchIndex < matches.length) {
        currentMatch = matches[matchIndex];
      } else {
        currentMatch = null;
      }
    }
  }

  return span;
}

/// Callback with URL to open
typedef StringCallback(String url);

/// Turns URLs into links
class OBSmartText extends StatelessWidget {
  /// Text to be linkified
  final String? text;

  /// Maximum text length
  final int? maxlength;

  /// Style for non-link text
  final TextStyle? style;

  /// Style of link text
  final TextStyle? linkStyle;

  /// Style of HashTag text
  final TextStyle? tagStyle;

  /// Callback for tapping a link
  final StringCallback? onLinkTapped;

  /// Callback for tapping a link
  final OnHashtagTapped? onHashtagTapped;

  /// Callback for tapping a link
  final StringCallback? onUsernameTapped;

  /// Callback for tapping a link
  final StringCallback? onCommunityNameTapped;

  /// SmartTextElement element to add at the end of smart text
  final SmartTextElement? trailingSmartTextElement;

  final OBTextSize size;

  final TextOverflow overflow;

  final TextOverflow lengthOverflow;

  final Map<String, Hashtag>? hashtagsMap;

  const OBSmartText({
    Key? key,
    this.text,
    this.maxlength,
    this.overflow = TextOverflow.clip,
    this.lengthOverflow = TextOverflow.ellipsis,
    this.style,
    this.linkStyle,
    this.tagStyle,
    this.onLinkTapped,
    this.onHashtagTapped,
    this.onUsernameTapped,
    this.onCommunityNameTapped,
    this.trailingSmartTextElement,
    this.size = OBTextSize.medium,
    this.hashtagsMap,
  }) : super(key: key);

  /// Raw TextSpan builder for more control on the RichText
  TextSpan _buildSpan({
    String? text,
    TextStyle? style,
    TextStyle? secondaryTextStyle,
    TextStyle? linkStyle,
    TextStyle? tagStyle,
    TextStyle? usernameStyle,
    TextStyle? communityNameStyle,
    StringCallback? onLinkTapped,
    StringCallback? onTagTapped,
    StringCallback? onUsernameTapped,
    StringCallback? onCommunityNameTapped,
  }) {
    void _onOpen(String url) {
      if (onLinkTapped != null) {
        onLinkTapped(url);
      }
    }

    void _onUsernameTapped(String username) {
      if (onUsernameTapped != null) {
        // Remove @
        String cleanedUsername =
        username.substring(1, username.length).toLowerCase();
        onUsernameTapped(cleanedUsername);
      }
    }

    void _onCommunityNameTapped(String communityName) {
      if (onCommunityNameTapped != null) {
        String cleanedCommunityName = communityName;
        // Remove c/
        if (cleanedCommunityName.startsWith('/c/')) {
          cleanedCommunityName =
              cleanedCommunityName.substring(3, communityName.length);
        } else if (cleanedCommunityName.startsWith('c/')) {
          cleanedCommunityName =
              cleanedCommunityName.substring(2, communityName.length);
        }

        cleanedCommunityName = cleanedCommunityName.toLowerCase();

        onCommunityNameTapped(cleanedCommunityName);
      }
    }

    List<SmartTextElement> elements = _smartify(text!);

    if (this.maxlength != null && text.length > maxlength!) {
      _enforceMaxLength(elements, maxlength!);
    }

    if (this.trailingSmartTextElement != null) {
      elements.add(this.trailingSmartTextElement!);
    }

    return TextSpan(
        children: elements.map<InlineSpan>((element) {
          late InlineSpan textSpan;
          if (element is TextElement) {
            textSpan = TextSpan(
              text: element.text,
              style: style,
            );
          } else if (element is SecondaryTextElement) {
            textSpan = TextSpan(
              text: element.text,
              style: secondaryTextStyle,
            );
          } else if (element is LinkElement) {
            textSpan = LinkTextSpan(
              text: element.text,
              style: linkStyle,
              onPressed: () => _onOpen(element.url),
            );
          } else if (element is HashtagElement) {
            String rawHashtagName =
            element.text.substring(1, element.text.length);
            String hashtagName = rawHashtagName.toLowerCase();
            if (this.hashtagsMap != null &&
                this.hashtagsMap!.containsKey(hashtagName)) {
              Hashtag hashtag = this.hashtagsMap![hashtagName]!;
              textSpan = WidgetSpan(
                  baseline: TextBaseline.alphabetic,
                  alignment: ui.PlaceholderAlignment.baseline,
                  child: OBHashtag(
                    discoDisplayMargin: const EdgeInsets.symmetric(vertical: 3),
                    hashtag: hashtag,
                    rawHashtagName: rawHashtagName,
                    onPressed: (Hashtag hashtag) {
                      if (onHashtagTapped != null) onHashtagTapped!(
                          hashtag: hashtag, rawHashtagName: rawHashtagName);
                    },
                    textStyle: linkStyle,
                  ));
            } else {
              textSpan = LinkTextSpan(
                text: element.text,
                style: linkStyle,
                onPressed: () => onHashtagTapped!(rawHashtagName: rawHashtagName),
              );
            }
          } else if (element is UsernameElement) {
            textSpan = LinkTextSpan(
              text: element.text,
              style: usernameStyle,
              onPressed: () => _onUsernameTapped(element.username),
            );
          } else if (element is CommunityNameElement) {
            textSpan = LinkTextSpan(
              text: element.text,
              style: communityNameStyle,
              onPressed: () => _onCommunityNameTapped(element.communityName),
            );
          }

          return textSpan;
        }).toList());
  }

  String runeSubstring({required String input, required int start, required int end}) {
    return String.fromCharCodes(input.runes.toList().sublist(start, end));
  }

  void _enforceMaxLength(List<SmartTextElement> elements, int maxlength) {
    int length = 0;

    if (lengthOverflow == TextOverflow.visible) {
      return;
    } else if (lengthOverflow == TextOverflow.ellipsis) {
      maxlength -= 3;
    }

    for (int i = 0; i < elements.length; i++) {
      var element = elements[i];
      var elementLength = element.text.length;

      if (length + elementLength > maxlength) {
        elements.removeRange(i + 1, elements.length);
        element.text = runeSubstring(
            input: element.text, start: 0, end: maxlength - length)
            .trimRight();

        if (lengthOverflow == TextOverflow.ellipsis) {
          element.text = element.text + '...';
        }
        break;
      } else {
        length += elementLength;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    OpenbookProviderState openbookProvider = OpenbookProvider.of(context);
    ThemeService themeService = openbookProvider.themeService;
    ThemeValueParserService themeValueParserService =
        openbookProvider.themeValueParserService;

    double fontSize = OBText.getTextSize(size);

    return StreamBuilder(
      initialData: themeService.getActiveTheme(),
      stream: themeService.themeChange,
      builder: (BuildContext context, AsyncSnapshot<OBTheme> snapshot) {
        OBTheme theme = snapshot.data!;

        Color primaryTextColor =
        themeValueParserService.parseColor(theme.primaryTextColor);

        TextStyle textStyle = TextStyle(
            color: primaryTextColor,
            fontSize: fontSize,
            fontFamilyFallback: ['NunitoSans']);

        TextStyle? secondaryTextStyle;

        if (trailingSmartTextElement != null) {
          // This is ugly af, why do we even need this.
          Color secondaryTextColor =
          themeValueParserService.parseColor(theme.secondaryTextColor);
          secondaryTextColor = TinyColor(secondaryTextColor)
              .lighten(10)
              .color;
          secondaryTextStyle = TextStyle(
              color: secondaryTextColor,
              fontSize: fontSize * 0.8,
              fontFamilyFallback: ['NunitoSans']);
        }

        Color actionsForegroundColor = themeValueParserService
            .parseGradient(theme.primaryAccentColor)
            .colors[1];

        TextStyle smartItemsStyle = TextStyle(
          color: actionsForegroundColor,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        );

        return RichText(
          overflow: overflow,
          softWrap: true,
          text: _buildSpan(
              text: text,
              style: textStyle,
              secondaryTextStyle: secondaryTextStyle,
              linkStyle: smartItemsStyle,
              tagStyle: smartItemsStyle,
              communityNameStyle: smartItemsStyle,
              usernameStyle: smartItemsStyle,
              onLinkTapped: onLinkTapped,
              onCommunityNameTapped: onCommunityNameTapped,
              onUsernameTapped: onUsernameTapped),
        );
      },
    );
  }
}

class LinkTextSpan extends TextSpan {
  LinkTextSpan({TextStyle? style, VoidCallback? onPressed, String? text})
      : super(
    style: style,
    text: text,
    recognizer: new TapGestureRecognizer()
      ..onTap = onPressed,
  );
}

typedef OnHashtagTapped({Hashtag hashtag, String rawHashtagName});
