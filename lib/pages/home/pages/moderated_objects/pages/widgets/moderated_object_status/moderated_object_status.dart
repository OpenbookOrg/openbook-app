import 'package:Okuna/models/moderation/moderated_object.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/widgets/icon.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:Okuna/widgets/tile_group_title.dart';
import 'package:Okuna/widgets/tiles/moderated_object_status_tile.dart';
import 'package:flutter/material.dart';

class OBModeratedObjectStatus extends StatelessWidget {
  final bool isEditable;
  final ModeratedObject moderatedObject;
  final ValueChanged<ModeratedObjectStatus>? onStatusChanged;

  const OBModeratedObjectStatus(
      {Key? key,
      required this.moderatedObject,
      required this.isEditable,
      this.onStatusChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    LocalizationService _localizationService = OpenbookProvider.of(context).localizationService;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        OBTileGroupTitle(
          title: _localizationService.moderation__object_status_title,
        ),
        StreamBuilder(
          initialData: moderatedObject,
          stream: moderatedObject.updateSubject,
          builder:
              (BuildContext context, AsyncSnapshot<ModeratedObject> snapshot) {
            return OBModeratedObjectStatusTile(
              moderatedObject: moderatedObject,
              trailing: isEditable
                  ? const OBIcon(
                      OBIcons.edit,
                      themeColor: OBIconThemeColor.secondaryText,
                    )
                  : null,
              onPressed: (moderatedObject) async {
                if (!isEditable) return;
                OpenbookProviderState openbookProvider =
                    OpenbookProvider.of(context);
                ModeratedObjectStatus? newModerationStatus =
                    await openbookProvider.modalService
                        .openModeratedObjectUpdateStatus(
                            context: context, moderatedObject: moderatedObject);
                if (newModerationStatus != null && onStatusChanged != null)
                  onStatusChanged!(newModerationStatus);
              },
            );
          },
        ),
      ],
    );
  }
}
