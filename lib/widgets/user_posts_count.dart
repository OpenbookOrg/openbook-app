import 'package:Okuna/models/user.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/toast.dart';
import 'package:Okuna/services/user.dart';
import 'package:Okuna/widgets/posts_count.dart';
import 'package:Okuna/widgets/progress_indicator.dart';
import 'package:flutter/material.dart';

class OBUserPostsCount extends StatefulWidget {
  final User user;

  OBUserPostsCount(this.user);

  @override
  OBUserPostsCountState createState() {
    return OBUserPostsCountState();
  }
}

class OBUserPostsCountState extends State<OBUserPostsCount> {
  late UserService _userService;
  late ToastService _toastService;
  late LocalizationService _localizationService;
  late bool _requestInProgress;
  late bool _hasError;
  late bool _needsBootstrap;

  @override
  void initState() {
    super.initState();
    _requestInProgress = false;
    _hasError = false;
    _needsBootstrap = true;
  }

  @override
  Widget build(BuildContext context) {
    var openbookProvider = OpenbookProvider.of(context);
    _userService = openbookProvider.userService;
    if(_needsBootstrap){
      _localizationService = openbookProvider.localizationService;
      _toastService = openbookProvider.toastService;
      _refreshUserPostsCount();
      _needsBootstrap = false;
    }

    return StreamBuilder(
      stream: widget.user.updateSubject,
      initialData: widget.user,
      builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
        var user = snapshot.data;

        return _hasError
            ? _buildErrorIcon()
            : _requestInProgress
                ? _buildLoadingIcon()
                : _buildPostsCount(user!);
      },
    );
  }

  Widget _buildPostsCount(User user) {
    return OBPostsCount(
      user.postsCount,
      showZero: true,
    );
  }

  Widget _buildErrorIcon() {
    return const SizedBox();
  }

  Widget _buildLoadingIcon() {
    return Padding(
      padding: const EdgeInsets.only(right: 5),
      child: OBProgressIndicator(
        size: 15.0,
      ),
    );
  }

  void _refreshUserPostsCount() async {
    _setRequestInProgress(true);
    try {
      await _userService.countPostsForUser(widget.user);
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
      _toastService.error(
          message: _localizationService.error__unknown_error, context: context);
      throw error;
    }
  }

  void _setRequestInProgress(bool requestInProgress) {
    setState(() {
      _requestInProgress = requestInProgress;
    });
  }
}
