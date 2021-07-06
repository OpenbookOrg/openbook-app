import 'dart:async';

import 'package:Okuna/models/user.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/user.dart';
import 'package:Okuna/widgets/avatars/avatar.dart';
import 'package:flutter/material.dart';

class OBLoggedInUserAvatar extends StatefulWidget {
  final OBAvatarSize? size;
  final VoidCallback? onPressed;

  const OBLoggedInUserAvatar({this.size, this.onPressed});

  @override
  OBLoggedInUserAvatarState createState() {
    return OBLoggedInUserAvatarState();
  }
}

/// Like the UserAvatar widget but displays the avatar of
/// the logged in user.
class OBLoggedInUserAvatarState extends State<OBLoggedInUserAvatar> {
  late bool _needsBootstrap;
  late UserService _userService;
  StreamSubscription? _onLoggedInUserChangeSubscription;
  StreamSubscription? _onUserUpdateSubscription;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _needsBootstrap = true;
  }

  @override
  void dispose() {
    super.dispose();
    if (_onLoggedInUserChangeSubscription != null)
      _onLoggedInUserChangeSubscription!.cancel();
    if (_onUserUpdateSubscription != null) _onUserUpdateSubscription!.cancel();
  }

  @override
  Widget build(BuildContext context) {
    var openbookProvider = OpenbookProvider.of(context);
    _userService = openbookProvider.userService;
    if (_needsBootstrap) {
      _bootstrap();
      _needsBootstrap = false;
    }

    return OBAvatar(
      avatarUrl: _avatarUrl,
      size: widget.size!,
      onPressed: widget.onPressed,
    );
  }

  void _bootstrap() {
    _onLoggedInUserChangeSubscription =
        _userService.loggedInUserChange.listen(_onLoggedInUserChange);
  }

  void _onLoggedInUserChange(User? user) {
    if (user == null) return;
    if (_onUserUpdateSubscription != null) _onUserUpdateSubscription!.cancel();
    _onUserUpdateSubscription =
        user.updateSubject.listen(_onLoggedInUserUpdate);
  }

  void _onLoggedInUserUpdate(User user) {
    _setAvatarUrl(user.getProfileAvatar()!);
  }

  void _setAvatarUrl(String avatarUrl) {
    setState(() {
      _avatarUrl = avatarUrl;
    });
  }
}
