import 'package:Okuna/services/httpie.dart';

class DocumentsService {
  late HttpieService _httpService;

  static const guidelinesUrl =
      'https://about.okuna.io/docs/COMMUNITY_GUIDELINES.md';
  static const privacyPolicyUrl =
      'https://about.okuna.io/docs/PRIVACY_POLICY.md';
  static const termsOfUsePolicyUrl =
      'https://about.okuna.io/docs/TERMS_OF_USE.md';

  // Cache
  String _communityGuidelines = '';
  String _termsOfUse = '';
  String _privacyPolicy = '';

  void preload() {
    getCommunityGuidelines();
    getPrivacyPolicy();
    getTermsOfUse();
  }

  void setHttpService(HttpieService httpService) {
    _httpService = httpService;
  }

  Future<String> getCommunityGuidelines() async {
    if (_communityGuidelines.isNotEmpty) return _communityGuidelines;
    HttpieResponse response = await _httpService.get(guidelinesUrl);
    _communityGuidelines = response.body;
    return _communityGuidelines;
  }

  Future<String> getPrivacyPolicy() async {
    if (_privacyPolicy.isNotEmpty) return _privacyPolicy;

    HttpieResponse response = await _httpService.get(privacyPolicyUrl);
    _privacyPolicy = response.body;
    return _privacyPolicy;
  }

  Future<String> getTermsOfUse() async {
    if (_termsOfUse.isNotEmpty) return _termsOfUse;

    HttpieResponse response = await _httpService.get(termsOfUsePolicyUrl);
    _termsOfUse = response.body;
    return _termsOfUse;
  }
}
