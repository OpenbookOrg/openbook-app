import 'package:Okuna/models/moderation/moderated_object.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/widgets/icon.dart';
import 'package:Okuna/widgets/theming/secondary_text.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:Okuna/widgets/tile_group_title.dart';
import 'package:flutter/material.dart';

class OBModeratedObjectDescription extends StatelessWidget {
  final bool isEditable;
  final ModeratedObject moderatedObject;
  final ValueChanged<String>? onDescriptionChanged;

  const OBModeratedObjectDescription(
      {Key? key,
      required this.moderatedObject,
      required this.isEditable,
      this.onDescriptionChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        OBTileGroupTitle(
          title: 'Description',
        ),
        ListTile(
          onTap: () async {
            if(!isEditable) return;
            OpenbookProviderState openbookProvider =
                OpenbookProvider.of(context);
            String? newDescription = await openbookProvider.modalService
                .openModeratedObjectUpdateDescription(
                    context: context, moderatedObject: moderatedObject);
            if (newDescription != null && onDescriptionChanged != null)
              onDescriptionChanged!(newDescription);
          },
          title: StreamBuilder(
            initialData: moderatedObject,
            stream: moderatedObject.updateSubject,
            builder: (BuildContext context,
                AsyncSnapshot<ModeratedObject> snapshot) {
              String? description = snapshot.data?.description;
              return description != null
                  ? OBText(description)
                  : OBSecondaryText(
                      'No description',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    );
            },
          ),
          trailing: isEditable ? const OBIcon(
            OBIcons.edit,
            themeColor: OBIconThemeColor.secondaryText,
          ) : null,
        )
      ],
    );
  }
}
