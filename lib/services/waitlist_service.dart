import 'package:Okuna/services/httpie.dart';

class WaitlistApiService {
  late HttpieService _httpService;
  late String openbookSocialApiURL;

  static const MAILCHIMP_SUBSCRIBE_PATH = 'waitlist/subscribe/';
  static const HEALTH_PATH = 'health/';

  void setOpenbookSocialApiURL(String newApiURL) {
    openbookSocialApiURL = newApiURL;
  }

  void setHttpService(HttpieService httpService) {
    _httpService = httpService;
  }

  Future<HttpieResponse> subscribeToBetaWaitlist({String? email}) {
    var body = {};
    if (email != null && email != '') {
      body['email'] = email;
    }
    return this
        ._httpService
        .postJSON('$openbookSocialApiURL$MAILCHIMP_SUBSCRIBE_PATH', body: body);
  }
}
