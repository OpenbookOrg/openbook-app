import 'package:Okuna/models/language.dart';

class LanguagesList {
  final List<Language>? languages;

  LanguagesList({
    this.languages,
  });

  factory LanguagesList.fromJson(List<dynamic> parsedJson) {
    List<Language> languages =
    parsedJson.map((languageJson) => Language.fromJson(languageJson)).toList();

    return new LanguagesList(
      languages: languages,
    );
  }
}
