import 'package:Okuna/models/hashtag.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/widgets/icon.dart';
import 'package:flutter/material.dart';
import 'package:Okuna/services/bottom_sheet.dart';

class OBHashtagMoreButton extends StatelessWidget {
  final Hashtag hashtag;

  const OBHashtagMoreButton({Key? key, required this.hashtag})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: hashtag.updateSubject,
      initialData: hashtag,
      builder: (BuildContext context, AsyncSnapshot<Hashtag> snapshot) {
        var hashtag = snapshot.data!;

        return IconButton(
          icon: const OBIcon(
            OBIcons.moreVertical,
          ),
          onPressed: () {
            OpenbookProviderState openbookProvider =
                OpenbookProvider.of(context);
            BottomSheetService bottomSheetService =
                openbookProvider.bottomSheetService;

            bottomSheetService.showHashtagActions(
                context: context,
                hashtag: hashtag,
                onHashtagReported: (Hashtag hashtag) {
                  Navigator.of(context).pop();
                });
          },
        );
      },
    );
  }
}
