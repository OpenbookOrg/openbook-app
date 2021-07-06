import 'package:Okuna/models/hashtag.dart';
import 'package:Okuna/pages/home/bottom_sheets/rounded_bottom_sheet.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/widgets/tiles/actions/report_hashtag_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OBHashtagActionsBottomSheet extends StatelessWidget {
  final Hashtag hashtag;
  final ValueChanged<Hashtag>? onHashtagReported;

  const OBHashtagActionsBottomSheet({
    Key? key,
    required this.hashtag,
    this.onHashtagReported,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> hashtagActions = [];

    hashtagActions.add(OBReportHashtagTile(
      hashtag: hashtag,
      onHashtagReported: onHashtagReported,
      onWantsToReportHashtag: () {
        OpenbookProviderState openbookProvider = OpenbookProvider.of(context);
        openbookProvider.bottomSheetService
            .dismissActiveBottomSheet(context: context);
      },
    ));

    return OBRoundedBottomSheet(
      child: Column(
        children: hashtagActions,
        mainAxisSize: MainAxisSize.min,
      ),
    );
  }
}

typedef OnHashtagDeleted(Hashtag hashtag);
