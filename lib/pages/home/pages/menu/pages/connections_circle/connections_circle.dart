import 'package:Okuna/models/circle.dart';
import 'package:Okuna/pages/home/pages/menu/pages/connections_circle/widgets/connections_circle_header/connections_circle_header.dart';
import 'package:Okuna/pages/home/pages/menu/pages/connections_circle/widgets/connections_circle_users.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/modal_service.dart';
import 'package:Okuna/widgets/nav_bars/themed_nav_bar.dart';
import 'package:Okuna/widgets/page_scaffold.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/toast.dart';
import 'package:Okuna/services/user.dart';
import 'package:Okuna/widgets/theming/primary_accent_text.dart';
import 'package:Okuna/widgets/theming/primary_color_container.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Okuna/services/httpie.dart';

class OBConnectionsCirclePage extends StatefulWidget {
  final Circle connectionsCircle;

  OBConnectionsCirclePage(
    this.connectionsCircle,
  );

  @override
  State<OBConnectionsCirclePage> createState() {
    return OBConnectionsCirclePageState();
  }
}

class OBConnectionsCirclePageState extends State<OBConnectionsCirclePage> {
  late UserService _userService;
  late ToastService _toastService;
  late ModalService _modalService;
  late LocalizationService _localizationService;

  late GlobalKey<RefreshIndicatorState> _refreshIndicatorKey;
  late bool _needsBootstrap;
  late bool _isConnectionsCircle;

  @override
  void initState() {
    super.initState();
    _isConnectionsCircle = true;
    _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
    _needsBootstrap = true;
  }

  @override
  Widget build(BuildContext context) {
    var provider = OpenbookProvider.of(context);
    _userService = provider.userService;
    _toastService = provider.toastService;
    _modalService = provider.modalService;
    _localizationService = provider.localizationService;

    if (_needsBootstrap) {
      _bootstrap();
      _needsBootstrap = false;
    }

    return OBCupertinoPageScaffold(
        backgroundColor: Color.fromARGB(0, 0, 0, 0),
        navigationBar: OBThemedNavigationBar(
          trailing: _buildNavigationBarTrailingItem(),
        ),
        child: RefreshIndicator(
            key: _refreshIndicatorKey,
            child: OBPrimaryColorContainer(
              child: SizedBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    OBConnectionsCircleHeader(widget.connectionsCircle,
                        isConnectionsCircle: _isConnectionsCircle),
                    Expanded(
                      child: OBConnectionsCircleUsers(
                        widget.connectionsCircle,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            onRefresh: _refreshConnectionsCircle));
  }

  Widget _buildNavigationBarTrailingItem() {
    if (_isConnectionsCircle) return const SizedBox();
    return GestureDetector(
      onTap: () {
        _modalService.openEditConnectionsCircle(
            connectionsCircle: widget.connectionsCircle, context: context);
      },
      child: OBPrimaryAccentText(_localizationService.trans('user__connection_circle_edit')),
    );
  }

  void _bootstrap() async {
    await _refreshConnectionsCircle();
    var loggedInUser = _userService.getLoggedInUser()!;
    bool isConnectionsCircle =
        loggedInUser.isConnectionsCircle(widget.connectionsCircle);
    _setIsConnectionsCircle(isConnectionsCircle);
  }

  Future<void> _refreshConnectionsCircle() async {
    try {
      await _userService
          .getConnectionsCircleWithId(widget.connectionsCircle.id!);
    } catch (error) {
      _onError(error);
    }
  }

  void _onError(error) async {
    if (error is HttpieConnectionRefusedError) {
      _toastService.error(
          message: error.toHumanReadableMessage(), context: context);
    } else if (error is HttpieRequestError) {
      String? errorMessage = await error.toHumanReadableMessage();
      _toastService.error(message: errorMessage ?? _localizationService.trans('error__unknown_error'), context: context);
    } else {
      _toastService.error(message: _localizationService.trans('error__unknown_error'), context: context);
      throw error;
    }
  }

  void _setIsConnectionsCircle(bool isConnectionsCircle) {
    setState(() {
      _isConnectionsCircle = isConnectionsCircle;
    });
  }
}
