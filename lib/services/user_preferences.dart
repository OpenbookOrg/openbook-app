import 'dart:async';

import 'package:Okuna/models/post_comment.dart';
import 'package:Okuna/services/connectivity.dart';
import 'package:Okuna/services/storage.dart';
import 'package:connectivity/connectivity.dart';
import 'package:rxdart/rxdart.dart';

import 'localization.dart';

class UserPreferencesService {
  late LocalizationService _localizationService;
  late OBStorage _storage;
  late ConnectivityService _connectivityService;

  static const postCommentsSortTypeStorageKey = 'postCommentsSortType';
  static const videosAutoPlaySettingStorageKey = 'videosAutoPlaySetting';
  static const linkPreviewsSettingStorageKey = 'linkPreviewsSetting';
  static const videosSoundSettingStorageKey = 'videoSoundSetting';
  static const hashtagsDisplaySettingStorageKey = 'hashtagsSetting';

  ConnectivityResult? _currentConnectivity;
  StreamSubscription? _connectivityChangeSubscription;

  Future<PostCommentsSortType>? _getPostCommentsSortTypeCache;

  Stream<bool> get videosAutoPlayAreEnabledChange =>
      _videosAutoPlayEnabledChangeSubject.stream;

  final _videosAutoPlayEnabledChangeSubject = BehaviorSubject<bool>();

  bool _videosAutoPlayAreEnabled = false;

  Stream<bool> get linkPreviewsAreEnabledChange =>
      _linkPreviewsEnabledChangeSubject.stream;

  final _linkPreviewsEnabledChangeSubject = BehaviorSubject<bool>();

  bool _linkPreviewsAreEnabled = false;

  Stream<VideosSoundSetting> get videosSoundSettingChange =>
      _videosSoundSettingChangeSubject.stream;

  final _videosSoundSettingChangeSubject =
      BehaviorSubject<VideosSoundSetting>();

  Stream<LinkPreviewsSetting> get linkPreviewsSettingChange =>
      _linkPreviewsSettingChangeSubject.stream;

  final _linkPreviewsSettingChangeSubject =
      BehaviorSubject<LinkPreviewsSetting>();

  Stream<VideosAutoPlaySetting> get videosAutoPlaySettingChange =>
      _videosAutoPlaySettingChangeSubject.stream;

  final _videosAutoPlaySettingChangeSubject =
      BehaviorSubject<VideosAutoPlaySetting>();

  HashtagsDisplaySetting? currentHashtagsDisplaySetting;

  Stream<HashtagsDisplaySetting> get hashtagsDisplaySettingChange =>
      _hashtagsDisplaySettingChangeSubject.stream;

  final _hashtagsDisplaySettingChangeSubject =
      BehaviorSubject<HashtagsDisplaySetting>();

  void setStorageService(StorageService storageService) {
    _storage = storageService.getSystemPreferencesStorage(
        namespace: 'userPreferences');
  }

  // Bootstrapped after connectivity service is given in the provider
  void bootstrap() async {
    _currentConnectivity = _connectivityService.getConnectivity();
    _refreshConnectivityDependentSettings();

    _connectivityChangeSubscription =
        _connectivityService.onConnectivityChange(_onConnectivityChange);

    HashtagsDisplaySetting? hashtagsDisplaySetting = await getHashtagsDisplaySetting();
    if (hashtagsDisplaySetting != null) {
      _hashtagsDisplaySettingChangeSubject.add(hashtagsDisplaySetting);
    }
  }

  void _onConnectivityChange(ConnectivityResult newConnectivity) {
    _currentConnectivity = newConnectivity;
    _refreshConnectivityDependentSettings();
  }

  void setLocalizationService(LocalizationService localizationService) {
    _localizationService = localizationService;
  }

  void setConnectivityService(ConnectivityService connectivityService) {
    _connectivityService = connectivityService;
  }

  void dispose() {
    _connectivityChangeSubscription?.cancel();
    _linkPreviewsEnabledChangeSubject.close();
    _videosSoundSettingChangeSubject.close();
    _videosAutoPlaySettingChangeSubject.close();
    _videosAutoPlayEnabledChangeSubject.close();
    _hashtagsDisplaySettingChangeSubject.close();

  }

  bool getLinkPreviewsAreEnabled() {
    return _linkPreviewsAreEnabled;
  }

  Future setLinkPreviewsSetting(LinkPreviewsSetting linkPreviewsSetting) async {
    String rawValue = linkPreviewsSetting.toString();
    _linkPreviewsSettingChangeSubject.add(linkPreviewsSetting);
    await _storage.set(linkPreviewsSettingStorageKey, rawValue);
    _refreshLinkPreviewsAreEnabled();
  }

  Future<LinkPreviewsSetting?> getLinkPreviewsSetting() async {
    String rawValue = (await _storage.get(linkPreviewsSettingStorageKey,
        defaultValue: LinkPreviewsSetting.always.toString()))!;
    return LinkPreviewsSetting.parse(rawValue);
  }

  Map<LinkPreviewsSetting, String> getLinkPreviewsSettingLocalizationMap() {
    return {
      LinkPreviewsSetting.always: _localizationService
          .application_settings__link_previews_autoplay_always,
      LinkPreviewsSetting.never: _localizationService
          .application_settings__link_previews_autoplay_never,
      LinkPreviewsSetting.wifiOnly: _localizationService
          .application_settings__link_previews_autoplay_wifi_only
    };
  }

  bool getVideosAutoPlayAreEnabled() {
    return _videosAutoPlayAreEnabled;
  }

  Future setVideosAutoPlaySetting(
      VideosAutoPlaySetting videosAutoPlaySetting) async {
    String rawValue = videosAutoPlaySetting.toString();
    _videosAutoPlaySettingChangeSubject.add(videosAutoPlaySetting);
    await _storage.set(videosAutoPlaySettingStorageKey, rawValue);
    _refreshVideosAutoPlayAreEnabled();
  }

  Future<VideosAutoPlaySetting?> getVideosAutoPlaySetting() async {
    String rawValue = (await _storage.get(videosAutoPlaySettingStorageKey,
        defaultValue: VideosAutoPlaySetting.wifiOnly.toString()))!;
    return VideosAutoPlaySetting.parse(rawValue);
  }

  Map<VideosAutoPlaySetting, String> getVideosAutoPlaySettingLocalizationMap() {
    return {
      VideosAutoPlaySetting.always:
          _localizationService.application_settings__videos_autoplay_always,
      VideosAutoPlaySetting.never:
          _localizationService.application_settings__videos_autoplay_never,
      VideosAutoPlaySetting.wifiOnly:
          _localizationService.application_settings__videos_autoplay_wifi_only
    };
  }

  Future setVideosSoundSetting(VideosSoundSetting videosSoundSetting) {
    String rawValue = videosSoundSetting.toString();
    _videosSoundSettingChangeSubject.add(videosSoundSetting);
    return _storage.set(videosSoundSettingStorageKey, rawValue);
  }

  Future<VideosSoundSetting?> getVideosSoundSetting() async {
    String rawValue = (await _storage.get(videosSoundSettingStorageKey,
        defaultValue: VideosSoundSetting.disabled.toString()))!;
    return VideosSoundSetting.parse(rawValue);
  }

  Map<VideosSoundSetting, String> getVideosSoundSettingLocalizationMap() {
    return {
      VideosSoundSetting.disabled:
          _localizationService.application_settings__videos_sound_disabled,
      VideosSoundSetting.enabled:
          _localizationService.application_settings__videos_sound_enabled
    };
  }

  Future setHashtagsDisplaySetting(
      HashtagsDisplaySetting newHashtagsDisplaySetting) {
    String rawValue = newHashtagsDisplaySetting.toString();
    currentHashtagsDisplaySetting = newHashtagsDisplaySetting;
    _hashtagsDisplaySettingChangeSubject.add(newHashtagsDisplaySetting);
    return _storage.set(hashtagsDisplaySettingStorageKey, rawValue);
  }

  Future<HashtagsDisplaySetting?> getHashtagsDisplaySetting() async {
    String rawValue = (await _storage.get(hashtagsDisplaySettingStorageKey,
        defaultValue: HashtagsDisplaySetting.traditional.toString()))!;
    return HashtagsDisplaySetting.parse(rawValue);
  }

  Map<HashtagsDisplaySetting, String>
      getHashtagsDisplaySettingLocalizationMap() {
    return {
      HashtagsDisplaySetting.traditional: _localizationService
          .application_settings__hashtags_display_traditional,
      HashtagsDisplaySetting.disco:
          _localizationService.application_settings__hashtags_display_disco
    };
  }

  Future setPostCommentsSortType(PostCommentsSortType type) {
    _getPostCommentsSortTypeCache = null;
    String rawType = PostComment.convertPostCommentSortTypeToString(type);
    return _storage.set(postCommentsSortTypeStorageKey, rawType);
  }

  Future<PostCommentsSortType> getPostCommentsSortType() async {
    if (_getPostCommentsSortTypeCache != null)
      return _getPostCommentsSortTypeCache!;
    _getPostCommentsSortTypeCache = _getPostCommentsSortType();
    return _getPostCommentsSortTypeCache!;
  }

  Future<PostCommentsSortType> _getPostCommentsSortType() async {
    String? rawType = await _storage.get(postCommentsSortTypeStorageKey);
    if (rawType == null) {
      PostCommentsSortType defaultSortType = _getDefaultPostCommentsSortType();
      await setPostCommentsSortType(defaultSortType);
      return defaultSortType;
    }
    return PostComment.parsePostCommentSortType(rawType);
  }

  PostCommentsSortType _getDefaultPostCommentsSortType() {
    return PostCommentsSortType.asc;
  }

  void _refreshConnectivityDependentSettings() {
    _refreshLinkPreviewsAreEnabled();
    _refreshVideosAutoPlayAreEnabled();
  }

  void _refreshLinkPreviewsAreEnabled() async {
    LinkPreviewsSetting? currentLinkPreviewsSetting =
        await getLinkPreviewsSetting();
    _linkPreviewsAreEnabled =
        currentLinkPreviewsSetting == LinkPreviewsSetting.always ||
            (currentLinkPreviewsSetting == LinkPreviewsSetting.wifiOnly &&
                _currentConnectivity == ConnectivityResult.wifi);
    _linkPreviewsEnabledChangeSubject.add(_linkPreviewsAreEnabled);
  }

  void _refreshVideosAutoPlayAreEnabled() async {
    VideosAutoPlaySetting? currentVideosAutoPlaySetting =
        await getVideosAutoPlaySetting();
    _videosAutoPlayAreEnabled =
        currentVideosAutoPlaySetting == VideosAutoPlaySetting.always ||
            (currentVideosAutoPlaySetting == VideosAutoPlaySetting.wifiOnly &&
                _currentConnectivity == ConnectivityResult.wifi);
    _videosAutoPlayEnabledChangeSubject.add(_videosAutoPlayAreEnabled);
  }

  Future clear() {
    return _storage.clear();
  }
}

class VideosAutoPlaySetting {
  final String code;

  const VideosAutoPlaySetting._internal(this.code);

  toString() => code;

  static const never = const VideosAutoPlaySetting._internal('n');
  static const always = const VideosAutoPlaySetting._internal('a');
  static const wifiOnly = const VideosAutoPlaySetting._internal('w');

  static const _values = const <VideosAutoPlaySetting>[never, always, wifiOnly];

  static values() => _values;

  static VideosAutoPlaySetting? parse(String? string) {
    if (string == null) return null;

    VideosAutoPlaySetting? autoPlaySetting;
    for (var type in _values) {
      if (string == type.code) {
        autoPlaySetting = type;
        break;
      }
    }

    if (autoPlaySetting == null) {
      // Don't throw as we might introduce new notifications on the API which might not be yet in code
      print('Unsupported autoplay setting');
    }

    return autoPlaySetting;
  }
}

class VideosSoundSetting {
  final String code;

  const VideosSoundSetting._internal(this.code);

  toString() => code;

  static const enabled = const VideosSoundSetting._internal('e');
  static const disabled = const VideosSoundSetting._internal('d');

  static const _values = const <VideosSoundSetting>[enabled, disabled];

  static values() => _values;

  static VideosSoundSetting? parse(String? string) {
    if (string == null) return null;

    VideosSoundSetting? soundSetting;
    for (var type in _values) {
      if (string == type.code) {
        soundSetting = type;
        break;
      }
    }

    if (soundSetting == null) {
      // Don't throw as we might introduce new notifications on the API which might not be yet in code
      print('Unsupported videos sound setting');
    }

    return soundSetting;
  }
}

class LinkPreviewsSetting {
  final String code;

  const LinkPreviewsSetting._internal(this.code);

  toString() => code;

  static const never = const LinkPreviewsSetting._internal('n');
  static const always = const LinkPreviewsSetting._internal('a');
  static const wifiOnly = const LinkPreviewsSetting._internal('w');

  static const _values = const <LinkPreviewsSetting>[never, always, wifiOnly];

  static values() => _values;

  static LinkPreviewsSetting? parse(String? string) {
    if (string == null) return null;

    LinkPreviewsSetting? autoPlaySetting;
    for (var type in _values) {
      if (string == type.code) {
        autoPlaySetting = type;
        break;
      }
    }

    if (autoPlaySetting == null) {
      // Don't throw as we might introduce new notifications on the API which might not be yet in code
      print('Unsupported links previews setting');
    }

    return autoPlaySetting;
  }
}

class HashtagsDisplaySetting {
  final String code;

  const HashtagsDisplaySetting._internal(this.code);

  toString() => code;

  static const traditional = const HashtagsDisplaySetting._internal('t');
  static const disco = const HashtagsDisplaySetting._internal('d');

  static const _values = const <HashtagsDisplaySetting>[traditional, disco];

  static values() => _values;

  static HashtagsDisplaySetting? parse(String? string) {
    if (string == null) return null;

    HashtagsDisplaySetting? setting;
    for (var type in _values) {
      if (string == type.code) {
        setting = type;
        break;
      }
    }

    if (setting == null) {
      // Don't throw as we might introduce new notifications on the API which might not be yet in code
      print('Unsupported hashtags display setting');
    }

    return setting;
  }
}
