import 'package:Okuna/services/httpie.dart';

class CategoriesApiService {
  late HttpieService _httpService;

  late String apiURL;

  static const getCategoriesPath = 'api/categories/';

  void setHttpService(HttpieService httpService) {
    _httpService = httpService;
  }

  void setApiURL(String newApiURL) {
    apiURL = newApiURL;
  }

  Future<HttpieResponse> getCategories() {
    String url = _makeApiUrl(getCategoriesPath);
    return _httpService.get(url, appendAuthorizationToken: true);
  }

  String _makeApiUrl(String string) {
    return '$apiURL$string';
  }
}
