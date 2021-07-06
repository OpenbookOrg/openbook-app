import 'package:Okuna/models/hashtag.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/navigation_service.dart';
import 'package:Okuna/widgets/icon.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:Okuna/widgets/tiles/loading_tile.dart';
import 'package:flutter/material.dart';

class OBReportHashtagTile extends StatefulWidget {
  final Hashtag hashtag;
  final ValueChanged<Hashtag>? onHashtagReported;
  final VoidCallback? onWantsToReportHashtag;

  const OBReportHashtagTile({
    Key? key,
    this.onHashtagReported,
    required this.hashtag,
    this.onWantsToReportHashtag,
  }) : super(key: key);

  @override
  OBReportHashtagTileState createState() {
    return OBReportHashtagTileState();
  }
}

class OBReportHashtagTileState extends State<OBReportHashtagTile> {
  late NavigationService _navigationService;
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
    _navigationService = openbookProvider.navigationService;
    _localizationService = openbookProvider.localizationService;

    return StreamBuilder(
      stream: widget.hashtag.updateSubject,
      initialData: widget.hashtag,
      builder: (BuildContext context, AsyncSnapshot<Hashtag> snapshot) {
        var hashtag = snapshot.data;

        bool isReported = hashtag?.isReported ?? false;

        return OBLoadingTile(
          isLoading: _requestInProgress || isReported,
          leading: OBIcon(OBIcons.report),
          title: OBText(isReported
              ? _localizationService.moderation__you_have_reported_hashtag_text
              : _localizationService.moderation__report_hashtag_text),
          onTap: isReported ? () {} : _reportHashtag,
        );
      },
    );
  }

  void _reportHashtag() {
    if (widget.onWantsToReportHashtag != null) widget.onWantsToReportHashtag!();
    _navigationService.navigateToReportObject(
        context: context,
        object: widget.hashtag,
        onObjectReported: (dynamic reportedObject) {
          if (reportedObject != null && widget.onHashtagReported != null)
            widget.onHashtagReported!(reportedObject as Hashtag);
        });
  }
}
