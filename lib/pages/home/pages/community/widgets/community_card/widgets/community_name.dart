import 'package:Okuna/models/community.dart';
import 'package:Okuna/widgets/theming/secondary_text.dart';
import 'package:flutter/material.dart';

class OBCommunityName extends StatelessWidget {
  final Community community;

  OBCommunityName(this.community);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: community.updateSubject,
      initialData: community,
      builder: (BuildContext context, AsyncSnapshot<Community> snapshot) {
        var community = snapshot.data;
        String? communityName = community?.name;

        if (communityName == null)
          return const SizedBox(
            height: 10.0,
          );

        return OBSecondaryText(
          'c/' + communityName,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black45),
        );
      },
    );
  }
}
