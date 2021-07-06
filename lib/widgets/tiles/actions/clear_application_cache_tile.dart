import 'package:Okuna/provider.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/widgets/icon.dart';
import 'package:Okuna/widgets/theming/secondary_text.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:Okuna/widgets/tiles/loading_tile.dart';
import 'package:flutter/material.dart';

class OBClearApplicationCacheTile extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return OBClearApplicationCacheTileState();
  }
}

class OBClearApplicationCacheTileState
    extends State<OBClearApplicationCacheTile> {
  late bool _inProgress;

  @override
  initState() {
    super.initState();
    _inProgress = false;
  }

  @override
  Widget build(BuildContext context) {
    LocalizationService localizationService = OpenbookProvider.of(context).localizationService;

    return OBLoadingTile(
      leading: OBIcon(OBIcons.clear),
      title: OBText(localizationService.user__clear_application_cache_text),
      subtitle: OBSecondaryText(localizationService.user__clear_application_cache_desc),
      isLoading: _inProgress,
      onTap: () => _clearApplicationCache(localizationService),
    );
  }

  Future _clearApplicationCache(LocalizationService localizationService) async {
    _setInProgress(true);

    OpenbookProviderState openbookProvider = OpenbookProvider.of(context);
    try {
      await openbookProvider.userService.clearCache();
      openbookProvider.toastService
          .success(message: localizationService.user__clear_application_cache_success, context: context);
    } catch (error) {
      openbookProvider.toastService
          .error(message: localizationService.user__clear_application_cache_failure, context: context);
      rethrow;
    } finally {
      _setInProgress(false);
    }
  }

  void _setInProgress(bool inProgress) {
    setState(() {
      this._inProgress = inProgress;
    });
  }
}
