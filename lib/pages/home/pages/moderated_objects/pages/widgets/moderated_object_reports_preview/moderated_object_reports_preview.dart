import 'package:Okuna/models/moderation/moderated_object.dart';
import 'package:Okuna/models/moderation/moderation_report.dart';
import 'package:Okuna/models/moderation/moderation_report_list.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/navigation_service.dart';
import 'package:Okuna/services/toast.dart';
import 'package:Okuna/services/user.dart';
import 'package:Okuna/widgets/avatars/avatar.dart';
import 'package:Okuna/widgets/buttons/see_all_button.dart';
import 'package:Okuna/widgets/progress_indicator.dart';
import 'package:Okuna/widgets/theming/divider.dart';
import 'package:Okuna/widgets/theming/secondary_text.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:Okuna/widgets/tile_group_title.dart';
import 'package:Okuna/widgets/tiles/user_tile.dart';
import 'package:async/async.dart';
import 'package:flutter/material.dart';

import 'moderation_report_tile.dart';

class OBModeratedObjectReportsPreview extends StatefulWidget {
  final bool isEditable;
  final ModeratedObject moderatedObject;

  const OBModeratedObjectReportsPreview(
      {Key? key, required this.moderatedObject, required this.isEditable})
      : super(key: key);

  @override
  OBModeratedObjectReportsPreviewState createState() {
    return OBModeratedObjectReportsPreviewState();
  }
}

class OBModeratedObjectReportsPreviewState
    extends State<OBModeratedObjectReportsPreview> {
  static int reportsPreviewsCount = 5;

  late bool _needsBootstrap;
  late UserService _userService;
  late ToastService _toastService;
  late NavigationService _navigationService;
  late LocalizationService _localizationService;

  CancelableOperation? _refreshReportsOperation;
  late bool _refreshInProgress;
  late List<ModerationReport> _reports;

  @override
  void initState() {
    super.initState();
    _needsBootstrap = true;
    _refreshInProgress = false;
    _reports = [];
  }

  @override
  void dispose() {
    super.dispose();
    if (_refreshReportsOperation != null) _refreshReportsOperation!.cancel();
  }

  @override
  Widget build(BuildContext context) {
    if (_needsBootstrap) {
      OpenbookProviderState openbookProvider = OpenbookProvider.of(context);
      _userService = openbookProvider.userService;
      _toastService = openbookProvider.toastService;
      _navigationService = openbookProvider.navigationService;
      _localizationService = openbookProvider.localizationService;
      _refreshReports();
      _needsBootstrap = false;
      _refreshInProgress = true;
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        OBTileGroupTitle(
          title: _localizationService.moderation__reports_preview_title
        ),
        OBDivider(),
        _refreshInProgress
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: OBProgressIndicator(),
                  )
                ],
              )
            : ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                separatorBuilder: (BuildContext context, int index) {
                  return OBDivider();
                },
                itemBuilder: _buildModerationReport,
                itemCount: _reports.length,
                shrinkWrap: true,
              ),
        OBDivider(),
        OBSeeAllButton(
          previewedResourcesCount: _reports.length,
          resourcesCount: widget.moderatedObject.reportsCount ?? 0,
          resourceName: _localizationService.moderation__reports_preview_resource_reports,
          onPressed: _onWantsToSeeAllReports,
        )
      ],
    );
  }

  Widget _buildModerationReport(BuildContext contenxt, int index) {
    ModerationReport report = _reports[index];

    return OBModerationReportTile(report: report);
  }

  Future _refreshReports() async {
    _setRefreshInProgress(true);
    try {
      _refreshReportsOperation = CancelableOperation.fromFuture(_userService
          .getModeratedObjectReports(widget.moderatedObject, count: 5));

      ModerationReportsList? moderationReportsList =
          await _refreshReportsOperation?.value;
      _setReports(moderationReportsList?.moderationReports ?? []);
    } catch (error) {
      _onError(error);
    }
    _setRefreshInProgress(false);
  }

  void _onWantsToSeeAllReports() {
    _navigationService.navigateToModeratedObjectReports(
        context: context, moderatedObject: widget.moderatedObject);
  }

  void _setRefreshInProgress(bool refreshInProgress) {
    setState(() {
      _refreshInProgress = refreshInProgress;
    });
  }

  void _setReports(List<ModerationReport> reports) {
    setState(() {
      _reports = reports;
    });
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
}
