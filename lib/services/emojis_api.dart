import 'package:Okuna/services/httpie.dart';

class EmojisApiService {
  late HttpieService _httpService;

  late String apiURL;

  static const GET_EMOJI_GROUPS_PATH = 'api/emojis/groups/';

  void setHttpService(HttpieService httpService) {
    _httpService = httpService;
  }

  void setApiURL(String newApiURL) {
    apiURL = newApiURL;
  }

  Future<HttpieResponse> getEmojiGroups() {
    String url = _makeApiUrl(GET_EMOJI_GROUPS_PATH);
    return _httpService.get(url, appendAuthorizationToken: true);
  }

  String _makeApiUrl(String string) {
    return '$apiURL$string';
  }
}
