import 'package:Okuna/models/moderation/moderated_object.dart';
import 'package:Okuna/models/theme.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:flutter/material.dart';
import 'package:pigment/pigment.dart';

import '../moderated_object_status_circle.dart';

class OBModeratedObjectStatusTile extends StatelessWidget {
  final ModeratedObject moderatedObject;
  final ValueChanged<ModeratedObject>? onPressed;
  final Widget? trailing;

  static double statusCircleSize = 10;
  static String pendingColor = '#f48c42';

  const OBModeratedObjectStatusTile(
      {Key? key, required this.moderatedObject, this.onPressed, this.trailing})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: moderatedObject.updateSubject,
      initialData: moderatedObject,
      builder: (BuildContext context, AsyncSnapshot<ModeratedObject> snapshot) {
        ModeratedObject currentModeratedObject = snapshot.data!;

        return ListTile(
          title: Row(
            children: <Widget>[
              OBModeratedObjectStatusCircle(
                status: moderatedObject.status!,
              ),
              const SizedBox(
                width: 10,
              ),
              OBText(ModeratedObject.factory.convertStatusToHumanReadableString(
                  currentModeratedObject.status,
                  capitalize: true) ?? '')
            ],
          ),
          onTap: () async {
            if (onPressed != null) onPressed!(moderatedObject);
          },
          trailing: trailing,
        );
      },
    );
  }
}
