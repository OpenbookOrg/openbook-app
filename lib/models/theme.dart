import 'package:Okuna/models/updatable_model.dart';
import 'package:dcache/dcache.dart';

class OBTheme extends UpdatableModel<OBTheme> {
  int? id;

  String? name;

  String primaryTextColor;
  String secondaryTextColor;

  String primaryColor;
  String primaryAccentColor;

  String successColor;
  String successColorAccent;

  String dangerColor;
  String dangerColorAccent;

  String? themePreview;

  static final factory = OBThemeFactory();

  factory OBTheme.fromJson(Map<String, dynamic> json) {
    return factory.fromJson(json);
  }

  OBTheme(
      {this.id,
      this.name,
      required this.primaryColor,
      required this.primaryAccentColor,
      required this.dangerColor,
      required this.dangerColorAccent,
      required this.successColor,
      required this.successColorAccent,
      this.themePreview,
      required this.primaryTextColor,
      required this.secondaryTextColor})
      : super();

  @override
  void updateFromJson(Map json) {
    primaryTextColor = json['primary_text_color'];
    secondaryTextColor = json['secondary_text_color'];
    primaryColor = json['primary_color'];
    primaryAccentColor = json['accent_color'];
    successColor = json['primary_button_color'];
    successColorAccent = json['primary_button_text_color'];
    dangerColor = json['danger_button_color'];
    dangerColorAccent = json['danger_button_text_color'];
  }
}

class OBThemeFactory extends UpdatableModelFactory<OBTheme> {
  @override
  SimpleCache<int, OBTheme>? cache = LruCache(storage: UpdatableModelSimpleStorage(size: 10));

  @override
  OBTheme makeFromJson(Map json) {
    return OBTheme(
        primaryTextColor: json['primary_text_color'],
        secondaryTextColor: json['secondary_text_color'],
        primaryColor: json['primary_color'],
        primaryAccentColor: json['accent_color'],
        successColor: json['primary_button_color'],
        successColorAccent: json['primary_button_text_color'],
        dangerColor: json['danger_button_color'],
        dangerColorAccent: json['danger_button_text_color']);
  }
}
