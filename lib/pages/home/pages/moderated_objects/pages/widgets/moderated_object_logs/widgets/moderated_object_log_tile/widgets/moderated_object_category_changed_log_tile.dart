import 'package:Okuna/models/moderation/moderated_object_log.dart';
import 'package:Okuna/widgets/theming/secondary_text.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:Okuna/widgets/tiles/moderation_category_tile.dart';
import 'package:flutter/material.dart';

import 'moderated_object_log_actor.dart';

class OBModeratedObjectCategoryChangedLogTile extends StatelessWidget {
  final ModeratedObjectLog log;
  final ModeratedObjectCategoryChangedLog moderatedObjectCategoryChangedLog;
  final VoidCallback? onPressed;

  const OBModeratedObjectCategoryChangedLogTile(
      {Key? key,
      required this.log,
      required this.moderatedObjectCategoryChangedLog,
      this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          OBText(
            'Category changed from:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          OBModerationCategoryTile(
              contentPadding: const EdgeInsets.all(0),
              category: moderatedObjectCategoryChangedLog.changedFrom!),
          OBText(
            'To:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          OBModerationCategoryTile(
              contentPadding: const EdgeInsets.all(0),
              category: moderatedObjectCategoryChangedLog.changedTo!),
        ],
      ),
    );
  }
}
