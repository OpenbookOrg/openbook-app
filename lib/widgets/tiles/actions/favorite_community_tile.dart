import 'package:Okuna/models/community.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/httpie.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/toast.dart';
import 'package:Okuna/services/user.dart';
import 'package:Okuna/widgets/icon.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:flutter/material.dart';

class OBFavoriteCommunityTile extends StatefulWidget {
  final Community community;
  final VoidCallback? onFavoritedCommunity;
  final VoidCallback? onUnfavoritedCommunity;
  final Widget? favoriteSubtitle;
  final Widget? unfavoriteSubtitle;

  const OBFavoriteCommunityTile(
      {Key? key,
      required this.community,
      this.onFavoritedCommunity,
      this.onUnfavoritedCommunity,
      this.favoriteSubtitle,
      this.unfavoriteSubtitle})
      : super(key: key);

  @override
  OBFavoriteCommunityTileState createState() {
    return OBFavoriteCommunityTileState();
  }
}

class OBFavoriteCommunityTileState extends State<OBFavoriteCommunityTile> {
  late UserService _userService;
  late ToastService _toastService;
  late LocalizationService _localizationService;
  late bool _requestInProgress;

  @override
  void initState() {
    super.initState();
    _requestInProgress = false;
  }

  @override
  Widget build(BuildContext context) {
    var openbookProvider = OpenbookProvider.of(context);
    _userService = openbookProvider.userService;
    _toastService = openbookProvider.toastService;
    _localizationService = openbookProvider.localizationService;

    return StreamBuilder(
      stream: widget.community.updateSubject,
      initialData: widget.community,
      builder: (BuildContext context, AsyncSnapshot<Community> snapshot) {
        var community = snapshot.data;

        bool isFavorite = community?.isFavorite ?? false;

        return ListTile(
          enabled: !_requestInProgress,
          leading: OBIcon(isFavorite
              ? OBIcons.unfavoriteCommunity
              : OBIcons.favoriteCommunity),
          title: OBText(
              isFavorite ? _localizationService.community__unfavorite_action : _localizationService.community__favorite_action),
          onTap: isFavorite ? _unfavoriteCommunity : _favoriteCommunity,
          subtitle:
              isFavorite ? widget.unfavoriteSubtitle : widget.favoriteSubtitle,
        );
      },
    );
  }

  void _favoriteCommunity() async {
    _setRequestInProgress(true);
    try {
      await _userService.favoriteCommunity(widget.community);
      if (widget.onFavoritedCommunity != null) widget.onFavoritedCommunity!();
    } catch (e) {
      _onError(e);
    } finally {
      _setRequestInProgress(false);
    }
  }

  void _unfavoriteCommunity() async {
    _setRequestInProgress(true);
    try {
      await _userService.unfavoriteCommunity(widget.community);
      if (widget.onUnfavoritedCommunity != null)
        widget.onUnfavoritedCommunity!();
    } catch (e) {
      _onError(e);
    } finally {
      _setRequestInProgress(false);
    }
  }

  void _onError(error) async {
    if (error is HttpieConnectionRefusedError) {
      _toastService.error(
          message: error.toHumanReadableMessage(), context: context);
    } else if (error is HttpieRequestError) {
      String? errorMessage = await error.toHumanReadableMessage();
      _toastService.error(message: errorMessage ?? _localizationService.error__unknown_error, context: context);
    } else {
      _toastService.error(message: _localizationService.error__unknown_error, context: context);
      throw error;
    }
  }

  void _setRequestInProgress(bool requestInProgress) {
    setState(() {
      _requestInProgress = requestInProgress;
    });
  }
}
