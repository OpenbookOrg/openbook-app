import 'package:Okuna/models/category.dart';

class CategoriesList {
  final List<Category>? categories;

  CategoriesList({
    this.categories,
  });

  factory CategoriesList.fromJson(List<dynamic> parsedJson) {
    List<Category> categories = parsedJson
        .map((categoryJson) => Category.fromJSON(categoryJson))
        .toList();

    return new CategoriesList(
      categories: categories,
    );
  }
}
