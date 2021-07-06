import 'package:Okuna/models/user.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/navigation_service.dart';
import 'package:Okuna/widgets/icon.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:Okuna/widgets/tiles/loading_tile.dart';
import 'package:flutter/material.dart';

class OBReportUserTile extends StatefulWidget {
  final User user;
  final ValueChanged<dynamic>? onUserReported;
  final VoidCallback? onWantsToReportUser;

  const OBReportUserTile({
    Key? key,
    this.onUserReported,
    required this.user,
    this.onWantsToReportUser,
  }) : super(key: key);

  @override
  OBReportUserTileState createState() {
    return OBReportUserTileState();
  }
}

class OBReportUserTileState extends State<OBReportUserTile> {
  late NavigationService _navigationService;
  late bool _requestInProgress;

  @override
  void initState() {
    super.initState();
    _requestInProgress = false;
  }

  @override
  Widget build(BuildContext context) {
    var openbookProvider = OpenbookProvider.of(context);
    _navigationService = openbookProvider.navigationService;
    LocalizationService _localizationService = openbookProvider.localizationService;

    return StreamBuilder(
      stream: widget.user.updateSubject,
      initialData: widget.user,
      builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
        var user = snapshot.data;

        bool isReported = user?.isReported ?? false;

        return OBLoadingTile(
          isLoading: _requestInProgress || isReported,
          leading: OBIcon(OBIcons.report),
          title: OBText(
              isReported ? _localizationService.moderation__you_have_reported_account_text : _localizationService.moderation__report_account_text),
          onTap: isReported ? () {} : _reportUser,
        );
      },
    );
  }

  void _reportUser() {
    if (widget.onWantsToReportUser != null) widget.onWantsToReportUser!();
    _navigationService.navigateToReportObject(
        context: context,
        object: widget.user,
        onObjectReported: widget.onUserReported);
  }
}
