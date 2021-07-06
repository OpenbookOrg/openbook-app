// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that looks up messages for specific locales by
// delegating to the appropriate library.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:implementation_imports, file_names, unnecessary_new
// ignore_for_file:unnecessary_brace_in_string_interps, directives_ordering
// ignore_for_file:argument_type_not_assignable, invalid_assignment
// ignore_for_file:prefer_single_quotes, prefer_generic_function_type_aliases
// ignore_for_file:comment_references

import 'dart:async';

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';
import 'package:intl/src/intl_helpers.dart';

import 'messages_da.dart' as messages_da;
import 'messages_de.dart' as messages_de;
import 'messages_en.dart' as messages_en;
import 'messages_es-ES.dart' as messages_es_es;
import 'messages_fr.dart' as messages_fr;
import 'messages_hu.dart' as messages_hu;
import 'messages_it.dart' as messages_it;
import 'messages_nl.dart' as messages_nl;
import 'messages_pt-BR.dart' as messages_pt_br;
import 'messages_sv-SE.dart' as messages_sv_se;
import 'messages_tr.dart' as messages_tr;

typedef Future<dynamic> LibraryLoader();
Map<String, LibraryLoader> _deferredLibraries = {
  'da': () => new Future.value(null),
  'de': () => new Future.value(null),
  'en': () => new Future.value(null),
  'es_ES': () => new Future.value(null),
  'fr': () => new Future.value(null),
  'hu': () => new Future.value(null),
  'it': () => new Future.value(null),
  'nl': () => new Future.value(null),
  'pt_BR': () => new Future.value(null),
  'sv_SE': () => new Future.value(null),
  'tr': () => new Future.value(null),
};

MessageLookupByLibrary? _findExact(String localeName) {
  switch (localeName) {
    case 'da':
      return messages_da.messages;
    case 'de':
      return messages_de.messages;
    case 'en':
      return messages_en.messages;
    case 'es_ES':
      return messages_es_es.messages;
    case 'fr':
      return messages_fr.messages;
    case 'hu':
      return messages_hu.messages;
    case 'it':
      return messages_it.messages;
    case 'nl':
      return messages_nl.messages;
    case 'pt_BR':
      return messages_pt_br.messages;
    case 'sv_SE':
      return messages_sv_se.messages;
    case 'tr':
      return messages_tr.messages;
    default:
      return null;
  }
}

/// User programs should call this before using [localeName] for messages.
Future<bool> initializeMessages(String localeName) async {
  var availableLocale = Intl.verifiedLocale(
    localeName,
    (locale) => _deferredLibraries[locale] != null,
    onFailure: (_) => null);
  if (availableLocale == null) {
    return new Future.value(false);
  }
  var lib = _deferredLibraries[availableLocale];
  await (lib == null ? new Future.value(false) : lib());
  initializeInternalMessageLookup(() => new CompositeMessageLookup());
  messageLookup.addLocale(availableLocale, _findGeneratedMessagesFor);
  return new Future.value(true);
}

bool _messagesExistFor(String locale) {
  try {
    return _findExact(locale) != null;
  } catch (e) {
    return false;
  }
}

MessageLookupByLibrary? _findGeneratedMessagesFor(String locale) {
  var actualLocale = Intl.verifiedLocale(locale, _messagesExistFor,
      onFailure: (_) => null);
  if (actualLocale == null) return null;
  return _findExact(actualLocale);
}
