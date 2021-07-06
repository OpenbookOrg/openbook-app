import 'package:Okuna/models/moderation/moderated_object_log.dart';
import 'package:Okuna/pages/home/pages/moderated_objects/pages/widgets/moderated_object_logs/widgets/moderated_object_log_tile/widgets/moderated_object_category_changed_log_tile.dart';
import 'package:Okuna/pages/home/pages/moderated_objects/pages/widgets/moderated_object_logs/widgets/moderated_object_log_tile/widgets/moderated_object_description_changed_log_tile.dart';
import 'package:Okuna/pages/home/pages/moderated_objects/pages/widgets/moderated_object_logs/widgets/moderated_object_log_tile/widgets/moderated_object_log_actor.dart';
import 'package:Okuna/pages/home/pages/moderated_objects/pages/widgets/moderated_object_logs/widgets/moderated_object_log_tile/widgets/moderated_object_status_changed_log_tile.dart';
import 'package:Okuna/pages/home/pages/moderated_objects/pages/widgets/moderated_object_logs/widgets/moderated_object_log_tile/widgets/moderated_object_verified_changed_log_tile.dart';
import 'package:Okuna/widgets/theming/divider.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:flutter/material.dart';

class OBModeratedObjectLogTile extends StatelessWidget {
  final ModeratedObjectLog log;
  final ValueChanged<ModeratedObjectLog>? onModeratedObjectLogTileDeleted;
  final ValueChanged<ModeratedObjectLog>? onPressed;

  const OBModeratedObjectLogTile(
      {Key? key,
      required this.log,
      this.onModeratedObjectLogTileDeleted,
      this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget logTile;

    switch (log.contentObject.runtimeType) {
      case ModeratedObjectDescriptionChangedLog:
        logTile = OBModeratedObjectDescriptionChangedLogTile(
          moderatedObjectDescriptionChangedLog: log.contentObject,
          log: log,
        );
        break;
      case ModeratedObjectVerifiedChangedLog:
        logTile = OBModeratedObjectVerifiedChangedLogTile(
          moderatedObjectVerifiedChangedLog: log.contentObject,
          log: log,
        );
        break;
      case ModeratedObjectStatusChangedLog:
        logTile = OBModeratedObjectStatusChangedLogTile(
          moderatedObjectStatusChangedLog: log.contentObject,
          log: log,
        );
        break;
      case ModeratedObjectCategoryChangedLog:
        logTile = OBModeratedObjectCategoryChangedLogTile(
          moderatedObjectCategoryChangedLog: log.contentObject,
          log: log,
        );
        break;
      default:
        logTile = ListTile(
          title: OBText(
            'Unsupported log type',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        logTile,
        const SizedBox(
          height: 5,
        ),
        ListTile(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              OBText(
                'By:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              OBModeratedObjectLogActor(
                actor: log.actor!,
              ),
              SizedBox(
                height: 5,
              ),
              OBText(
                'On:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              OBText(log.created.toString()),
            ],
          ),
        ),
        OBDivider()
      ],
    );
  }
}
