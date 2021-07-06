import 'package:Okuna/models/moderation/moderated_object_log.dart';
import 'package:Okuna/widgets/theming/secondary_text.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:flutter/material.dart';

import 'moderated_object_log_actor.dart';

class OBModeratedObjectDescriptionChangedLogTile extends StatelessWidget {
  final ModeratedObjectLog log;
  final ModeratedObjectDescriptionChangedLog
      moderatedObjectDescriptionChangedLog;
  final VoidCallback? onPressed;

  const OBModeratedObjectDescriptionChangedLogTile(
      {Key? key,
      required this.log,
      required this.moderatedObjectDescriptionChangedLog,
      this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          OBText(
            'Description changed from:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          OBSecondaryText(
            moderatedObjectDescriptionChangedLog.changedFrom != null
                ? moderatedObjectDescriptionChangedLog.changedFrom!
                : 'No description',
            style: TextStyle(
                fontStyle:
                    moderatedObjectDescriptionChangedLog.changedFrom != null
                        ? FontStyle.normal
                        : FontStyle.italic),
          ),
          const SizedBox(
            height: 10,
          ),
          OBText(
            'To:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          OBSecondaryText(moderatedObjectDescriptionChangedLog.changedTo!),
        ],
      ),
    );
  }
}
