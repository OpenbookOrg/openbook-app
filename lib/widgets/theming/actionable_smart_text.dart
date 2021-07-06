import 'dart:async';

import 'package:Okuna/models/community.dart';
import 'package:Okuna/models/hashtag.dart';
import 'package:Okuna/models/post_link.dart';
import 'package:Okuna/models/post_links_list.dart';
import 'package:Okuna/models/user.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/navigation_service.dart';
import 'package:Okuna/services/toast.dart';
import 'package:Okuna/services/url_launcher.dart';
import 'package:Okuna/services/user.dart';
import 'package:Okuna/widgets/theming/smart_text.dart';
export 'package:Okuna/widgets/theming/smart_text.dart';
import 'package:flutter/material.dart';

class OBActionableSmartText extends StatefulWidget {
  final String? text;
  final int? maxlength;
  final OBTextSize size;
  final TextOverflow overflow;
  final TextOverflow lengthOverflow;
  final SmartTextElement? trailingSmartTextElement;
  final Map<String, Hashtag>? hashtagsMap;
  final List<PostLink>? links;

  const OBActionableSmartText(
      {Key? key,
      this.text,
      this.maxlength,
      this.size = OBTextSize.medium,
      this.overflow = TextOverflow.clip,
      this.lengthOverflow = TextOverflow.ellipsis,
      this.trailingSmartTextElement,
      this.hashtagsMap,
      this.links})
      : super(key: key);

  @override
  OBActionableTextState createState() {
    return OBActionableTextState();
  }
}

class OBActionableTextState extends State<OBActionableSmartText> {
  late NavigationService _navigationService;
  late UserService _userService;
  late UrlLauncherService _urlLauncherService;
  late ToastService _toastService;

  late bool _needsBootstrap;
  StreamSubscription? _requestSubscription;

  @override
  void initState() {
    super.initState();
    _needsBootstrap = true;
  }

  void dispose() {
    super.dispose();
    _clearRequestSubscription();
  }

  @override
  Widget build(BuildContext context) {
    if (_needsBootstrap) {
      OpenbookProviderState openbookProvider = OpenbookProvider.of(context);
      _navigationService = openbookProvider.navigationService;
      _userService = openbookProvider.userService;
      _urlLauncherService = openbookProvider.urlLauncherService;
      _toastService = openbookProvider.toastService;
      _needsBootstrap = false;
    }

    return OBSmartText(
      text: widget.text,
      maxlength: widget.maxlength,
      overflow: widget.overflow,
      lengthOverflow: widget.lengthOverflow,
      onCommunityNameTapped: _onCommunityNameTapped,
      onUsernameTapped: _onUsernameTapped,
      onLinkTapped: _onLinkTapped,
      onHashtagTapped: _onHashtagNameHashtagRetrieved,
      trailingSmartTextElement: widget.trailingSmartTextElement,
      hashtagsMap: widget.hashtagsMap,
      size: widget.size,
    );
  }

  void _onCommunityNameTapped(String communityName) {
    _clearRequestSubscription();

    StreamSubscription requestSubscription = _userService
        .getCommunityWithName(communityName)
        .asStream()
        .listen(_onCommunityNameCommunityRetrieved,
            onError: _onError, onDone: _onRequestDone);
    _setRequestSubscription(requestSubscription);
  }

  void _onCommunityNameCommunityRetrieved(Community community) {
    _navigationService.navigateToCommunity(
        community: community, context: context);
  }

  void _onUsernameTapped(String username) {
    _clearRequestSubscription();
    StreamSubscription requestSubscription = _userService
        .getUserWithUsername(username)
        .asStream()
        .listen(_onUsernameUserRetrieved,
            onError: _onError, onDone: _onRequestDone);
    _setRequestSubscription(requestSubscription);
  }

  void _onHashtagNameHashtagRetrieved(
      {Hashtag? hashtag, String? rawHashtagName}) {
    if (hashtag != null) {
      _onHashtagRetrieved(hashtag: hashtag, rawHashtagName: rawHashtagName!);
      return;
    }

    _clearRequestSubscription();

    StreamSubscription requestSubscription = _userService
        .getHashtagWithName(rawHashtagName!)
        .asStream()
        .listen(
            (Hashtag hashtag) => _onHashtagRetrieved(
                hashtag: hashtag, rawHashtagName: rawHashtagName),
            onError: _onError,
            onDone: _onRequestDone);
    _setRequestSubscription(requestSubscription);
  }

  void _onHashtagRetrieved({required Hashtag hashtag, String? rawHashtagName}) {
    _navigationService.navigateToHashtag(
        rawHashtagName: rawHashtagName, hashtag: hashtag, context: context);
  }

  void _onUsernameUserRetrieved(User user) {
    _navigationService.navigateToUserProfile(user: user, context: context);
  }

  void _onLinkTapped(String link) {
    try {
      _urlLauncherService.launchUrl(link);
    } on UrlLauncherUnsupportedUrlException {
      _toastService.info(message: 'Unsupported link', context: context);
    } catch (error) {
      _onError(error);
    }
  }

  void _onRequestDone() {
    _clearRequestSubscription();
  }

  void _onError(error) async {
    if (error is HttpieConnectionRefusedError) {
      _toastService.error(
          message: error.toHumanReadableMessage(), context: context);
    } else if (error is HttpieRequestError) {
      String? errorMessage = await error.toHumanReadableMessage();
      _toastService.error(message: errorMessage ?? 'Unknown error', context: context);
    } else {
      _toastService.error(message: 'Unknown error', context: context);
      throw error;
    }
  }

  void _clearRequestSubscription() {
    if (_requestSubscription != null) {
      _requestSubscription!.cancel();
      _setRequestSubscription(null);
    }
  }

  void _setRequestSubscription(StreamSubscription? requestSubscription) {
    _requestSubscription = requestSubscription;
  }
}
