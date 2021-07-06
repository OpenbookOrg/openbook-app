import 'package:Okuna/models/community.dart';
import 'package:Okuna/widgets/cover.dart';
import 'package:flutter/cupertino.dart';

class OBCommunityCover extends StatelessWidget {
  final Community community;

  OBCommunityCover(this.community);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: community.updateSubject,
      initialData: community,
      builder: (BuildContext context, AsyncSnapshot<Community> snapshot) {
        var community = snapshot.data;
        String? communityCover = community?.cover;

        return OBCover(
          coverUrl: communityCover,
        );
      },
    );
  }
}
