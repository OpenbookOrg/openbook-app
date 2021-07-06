import 'dart:async';

import 'package:Okuna/models/link_preview/link_preview.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/httpie.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/url_launcher.dart';
import 'package:Okuna/services/user.dart';
import 'package:Okuna/services/user_preferences.dart';
import 'package:Okuna/services/utils_service.dart';
import 'package:Okuna/widgets/buttons/actions/block_button.dart';
import 'package:Okuna/widgets/icon.dart';
import 'package:Okuna/widgets/progress_indicator.dart';
import 'package:Okuna/widgets/theming/highlighted_box.dart';
import 'package:Okuna/widgets/theming/secondary_text.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_svg/svg.dart';
import 'package:async/async.dart';

class OBLinkPreview extends StatefulWidget {
  final LinkPreview? linkPreview;
  final String? link;
  final ValueChanged<LinkPreview?>? onLinkPreviewRetrieved;

  const OBLinkPreview(
      {required this.linkPreview, this.link, this.onLinkPreviewRetrieved});

  @override
  State<StatefulWidget> createState() {
    return OBLinkPreviewState();
  }
}

class OBLinkPreviewState extends State<OBLinkPreview> {
  static double iconSize = 16;
  static double linkPreviewHeight = 300;

  LinkPreview? _linkPreview;
  late UrlLauncherService _urlLauncherService;
  late LocalizationService _localizationService;
  late UtilsService _utilsService;
  late UserService _userService;
  late UserPreferencesService _userPreferencesService;

  late HttpieService _httpieService;

  late bool _linkPreviewRequestInProgress;
  CancelableOperation? _fetchLinkPreviewOperation;

  late bool _needsBootstrap;
  late bool _failedToPreviewLink;

  StreamSubscription? _linkPreviewsAreEnabledChangeSubscription;

  late bool _linkPreviewsAreEnabled;

  @override
  void initState() {
    super.initState();
    _needsBootstrap = true;
    _linkPreview = widget.linkPreview;
    _linkPreviewRequestInProgress = true;
    _failedToPreviewLink = false;
  }

  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);

    String previousLinkUrl;
    if (oldWidget.link != null) {
      previousLinkUrl = oldWidget.link!;
    } else {
      previousLinkUrl = oldWidget.linkPreview!.url!;
    }

    String newLinkUrl;
    if (widget.link != null) {
      newLinkUrl = widget.link!;
    } else {
      newLinkUrl = widget.linkPreview!.url!;
    }

    if (previousLinkUrl != newLinkUrl) {
      _needsBootstrap = true;
      _linkPreview = widget.linkPreview;
      _linkPreviewRequestInProgress = true;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _fetchLinkPreviewOperation?.cancel();
    _linkPreviewsAreEnabledChangeSubscription?.cancel();
  }

  void _bootstrap() async {
    _linkPreviewsAreEnabled =
        _userPreferencesService.getLinkPreviewsAreEnabled();

    _onLinkPreviewsAreEnabledChange(_linkPreviewsAreEnabled, isBootstrap: true);

    _linkPreviewsAreEnabledChangeSubscription = _userPreferencesService
        .linkPreviewsAreEnabledChange
        .listen(_onLinkPreviewsAreEnabledChange);
  }

  @override
  Widget build(BuildContext context) {
    if (_needsBootstrap) {
      OpenbookProviderState openbookProvider = OpenbookProvider.of(context);
      _urlLauncherService = openbookProvider.urlLauncherService;
      _localizationService = openbookProvider.localizationService;
      _httpieService = openbookProvider.httpService;
      _userPreferencesService = openbookProvider.userPreferencesService;
      _utilsService = openbookProvider.utilsService;
      _userService = openbookProvider.userService;
      _bootstrap();
      _needsBootstrap = false;
    }

    return _linkPreviewsAreEnabled
        ? ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: OBHighlightedBox(
                child: Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Expanded(
                  child: AnimatedSwitcher(
                    duration: Duration(milliseconds: 300),
                    child: _linkPreviewRequestInProgress || _linkPreview == null
                        ? _failedToPreviewLink
                            ? _buildFailedToPreviewLink()
                            : _buildRequestInProgress()
                        : _buildLinkPreview(),
                  ),
                )
              ],
            )),
          )
        : const SizedBox();
  }

  Widget _buildFailedToPreviewLink() {
    return SizedBox(
        // Estimated size of the preview bottom bar
        height: linkPreviewHeight,
        child: Column(
          children: <Widget>[
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    OBIcon(
                      OBIcons.linkOff,
                      size: OBIconSize.large,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 150),
                      child: Column(
                        children: [
                          OBText(
                            _localizationService.link_preview_failed__title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 10,),
                          OBText(
                            _localizationService.link_preview_failed__description,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20,),
                          OBButton(
                              child: Text(_localizationService.retry),
                              onPressed: _retrieveLinkPreview,
                              type: OBButtonType.highlight,
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Expanded(
                  child: OBHighlightedBox(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 5),
                      child: OBSecondaryText(_getLinkPreviewDomain(),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ),
                )
              ],
            )
          ],
        ));
  }

  Widget _buildLinkPreview() {
    return GestureDetector(
      child: SizedBox(
          height: linkPreviewHeight,
          child: Column(
            children: [
              Expanded(
                child: _buildPreviewImage(),
              ),
              _buildPreviewBar()
            ],
          )),
      onTap: () {
        _urlLauncherService.launchUrl(_linkPreview?.url ?? widget.link!);
      },
    );
  }

  Widget _buildRequestInProgress() {
    return SizedBox(
      // Estimated size of the preview bottom bar
      height: 300,
      child: Center(
        child: OBProgressIndicator(),
      ),
    );
  }

  Widget _buildPreviewImage() {
    if (_linkPreview?.image == null) {
      return Semantics(
        label: 'Link preview image',
        child: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage(
                    'assets/images/fallbacks/post-fallback.png',
                  ))),
        ),
      );
    }

    return _buildLinkPreviewImageFromUrl(_linkPreview!.image!.url!);
  }

  Widget _buildLinkPreviewImageFromUrl(String url) {
    String proxiedImageUrl = _utilsService.getProxiedContentLink(url);

    String proxyAuthToken = _httpieService.getAuthorizationToken()!;

    return _buildCrossCompatImageForSource(proxiedImageUrl,
        semanticsLabel: 'Link preview image',
        headers: {'Authorization': 'Token $proxyAuthToken'});
  }

  Widget _buildPreviewBar() {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                _linkPreview?.icon != null
                    ? _buildLinkPreviewIcon()
                    : const SizedBox(),
                OBSecondaryText(_getLinkPreviewDomain(),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))
              ],
            ),
          ),
          _linkPreview?.title != null
              ? Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: OBText(
                    _linkPreview!.title!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                )
              : const SizedBox(),
          _linkPreview?.description != null
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: OBSecondaryText(
                    _linkPreview!.description!,
                    size: OBTextSize.mediumSecondary,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              : const SizedBox()
        ],
      ),
    );
  }

  Widget _buildLinkPreviewIcon() {
    Widget iconWidget;

    String proxiedIconImageUrl =
        _utilsService.getProxiedContentLink(_linkPreview!.icon!.url!);
    String proxyAuthToken = _httpieService.getAuthorizationToken()!;

    iconWidget = _buildCrossCompatImageForSource(proxiedIconImageUrl,
        semanticsLabel: 'Icon',
        headers: {'Authorization': 'Token $proxyAuthToken'});

    return Padding(
      padding: EdgeInsets.only(right: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3.0),
        child: SizedBox(
          height: iconSize,
          width: iconSize,
          child: iconWidget,
        ),
      ),
    );
  }

  Widget _buildCrossCompatImageForSource(String imageSource,
      {String? semanticsLabel, Map<String, String>? headers}) {
    String iconExtension = imageSource.split('.').last;

    Widget image;

    if (iconExtension == 'svg') {
      image = SvgPicture.network(
        imageSource,
        headers: headers,
        semanticsLabel: semanticsLabel,
        fit: BoxFit.cover,
        placeholderBuilder: (BuildContext context) =>
            Image.asset('assets/images/fallbacks/post-fallback.png'),
      );
    } else {
      image = Semantics(
        label: semanticsLabel,
        child: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AdvancedNetworkImage(imageSource,
                      header: headers,
                      useDiskCache: true,
                      fallbackAssetImage:
                          'assets/images/fallbacks/post-fallback.png',
                      retryLimit: 3,
                      timeoutDuration: const Duration(minutes: 1)))),
        ),
      );
    }

    return image;
  }

  void _onLinkPreviewsAreEnabledChange(bool newAreLinkPreviewsEnabled,
      {bool isBootstrap = false}) {
    if (isBootstrap) {
      _linkPreviewsAreEnabled = newAreLinkPreviewsEnabled;
    } else {
      setState(() {
        _linkPreviewsAreEnabled = newAreLinkPreviewsEnabled;
      });
    }

    if (_linkPreview == null && newAreLinkPreviewsEnabled) {
      _retrieveLinkPreview();
    } else {
      // No link preview, requesting
      _linkPreviewRequestInProgress = false;
    }
  }

  Future _retrieveLinkPreview() async {
    _setFailedToPreviewLink(false);
    if (_fetchLinkPreviewOperation != null) return;
    _setLinkPreviewRequestInProgress(true);

    String link = widget.link!;

    debugLog('Retrieving link preview for url: $link');

    try {
      _fetchLinkPreviewOperation =
          CancelableOperation.fromFuture(_userService.previewLink(link: link));

      LinkPreview? linkPreview = await _fetchLinkPreviewOperation?.value;

      if (widget.onLinkPreviewRetrieved != null)
        widget.onLinkPreviewRetrieved!(linkPreview);
      if (linkPreview != null) {
        _setLinkPreview(linkPreview);
        debugLog('Retrieved link preview for url: $link');
      }
    } catch (error) {
      debugLog('Failed to retrieve link preview for url: $link');
      _onError(error);
    } finally {
      _fetchLinkPreviewOperation = null;
      _setLinkPreviewRequestInProgress(false);
    }
  }

  void _onError(error) async {
    _setFailedToPreviewLink(true);

    if (!(error is HttpieConnectionRefusedError) ||
        !(error is HttpieRequestError)) {
      throw error;
    }
  }

  String _getLinkPreviewDomain() {
    return (_linkPreview != null && _linkPreview!.domain != null
            ? _linkPreview!.domain!
            : Uri.parse(widget.link!).host)
        .toUpperCase();
  }

  void _setFailedToPreviewLink(bool failedToPreviewLink) {
    setState(() {
      _failedToPreviewLink = failedToPreviewLink;
    });
  }

  void _setLinkPreviewRequestInProgress(bool previewRequestInProgress) {
    setState(() {
      _linkPreviewRequestInProgress = previewRequestInProgress;
    });
  }

  void _setLinkPreview(LinkPreview linkPreview) {
    setState(() {
      _linkPreview = linkPreview;
    });
  }

  void debugLog(String log) {
    //debugPrint('OBLinkPreview:$log');
  }
}
