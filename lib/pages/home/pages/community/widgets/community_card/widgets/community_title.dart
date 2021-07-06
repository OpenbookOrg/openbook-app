import 'package:Okuna/models/community.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:flutter/material.dart';

class OBCommunityTitle extends StatelessWidget {
  final Community community;

  OBCommunityTitle(this.community);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: community.updateSubject,
      initialData: community,
      builder: (BuildContext context, AsyncSnapshot<Community> snapshot) {
        var community = snapshot.data;
        String? title = community?.title;

        if (title == null)
          return const SizedBox(
            height: 20.0,
          );

        return OBText(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        );
      },
    );
  }
}
