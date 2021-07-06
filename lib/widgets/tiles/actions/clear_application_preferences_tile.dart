import 'package:Okuna/provider.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/widgets/icon.dart';
import 'package:Okuna/widgets/theming/secondary_text.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:Okuna/widgets/tiles/loading_tile.dart';
import 'package:flutter/material.dart';

class OBClearApplicationPreferencesTile extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return OBClearApplicationPreferencesTileState();
  }
}

class OBClearApplicationPreferencesTileState
    extends State<OBClearApplicationPreferencesTile> {
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
      title: OBText(localizationService.user__clear_app_preferences_title),
      subtitle: OBSecondaryText(
          localizationService.user__clear_app_preferences_desc),
      isLoading: _inProgress,
      onTap: () => _clearApplicationPreferences(localizationService),
    );
  }

  Future _clearApplicationPreferences(LocalizationService localizationService) async {
    OpenbookProviderState openbookProvider = OpenbookProvider.of(context);
    try {
      await openbookProvider.userPreferencesService.clear();
      openbookProvider.toastService.success(
          message: localizationService.user__clear_app_preferences_cleared_successfully, context: context);
    } catch (error) {
      openbookProvider.toastService
          .error(message: localizationService.user__clear_app_preferences_error, context: context);
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
