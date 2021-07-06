import 'package:Okuna/models/user.dart';
import 'package:Okuna/widgets/cover.dart';
import 'package:flutter/cupertino.dart';

class OBProfileCover extends StatelessWidget {
  final User? user;

  OBProfileCover(this.user);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: user?.updateSubject,
      initialData: user,
      builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
        String? profileCover = user?.getProfileCover();

        return OBCover(
          coverUrl: profileCover,
        );
      },
    );
  }
}
