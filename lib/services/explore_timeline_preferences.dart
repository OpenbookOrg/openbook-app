import 'dart:async';

import 'package:Okuna/services/storage.dart';
import 'package:rxdart/rxdart.dart';

class ExploreTimelinePreferencesService {
  late OBStorage _storage;

  static const excludeJoinedCommunitiesStorageKey = 'excludeJoinedCommunitiesSetting';

  bool _isExcludeJoinedCommunitiesEnabled = true;

  Stream<bool> get excludeJoinedCommunitiesSettingChange =>
      _excludeJoinedCommunitiesSettingChangeSubject.stream;

  final _excludeJoinedCommunitiesSettingChangeSubject =
  BehaviorSubject<bool>();

  void setStorageService(StorageService storageService) {
    _storage = storageService.getSystemPreferencesStorage(
        namespace: 'exploreTimelinePreferences');
  }

  bool getIsExcludeJoinedCommunitiesEnabled() {
    return _isExcludeJoinedCommunitiesEnabled;
  }

  Future setExcludeJoinedCommunitiesSetting(bool excludeJoinedCommunitiesSetting) async {
    String rawValue = excludeJoinedCommunitiesSetting.toString();
    await _storage.set(excludeJoinedCommunitiesStorageKey, rawValue);
    _refreshExcludeJoinedCommunitiesEnabled();
  }

  Future<bool> getExcludeJoinedCommunitiesSetting() async {
    String rawValue = (await _storage.get(excludeJoinedCommunitiesStorageKey,
        defaultValue: 'true'))!;
    return rawValue == 'true';
  }

  void _refreshExcludeJoinedCommunitiesEnabled() async {
    bool currentSetting = await getExcludeJoinedCommunitiesSetting();
    _isExcludeJoinedCommunitiesEnabled = currentSetting;
    _excludeJoinedCommunitiesSettingChangeSubject.add(_isExcludeJoinedCommunitiesEnabled);
  }

  void dispose() {
    _excludeJoinedCommunitiesSettingChangeSubject.close();
  }

}
