import 'package:Okuna/models/user.dart';
import 'package:Okuna/widgets/nav_bars/themed_nav_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OBProfileNavBar extends StatelessWidget
    implements ObstructingPreferredSizeWidget {
  final User user;

  OBProfileNavBar(this.user);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: user.updateSubject,
        initialData: user,
        builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
          var user = snapshot.data!;
          return OBThemedNavigationBar(
            title: '@' + user.username!,
          );
        });
  }

  bool get fullObstruction {
    return true;
  }

  @override
  Size get preferredSize {
    return const Size.fromHeight(44);
  }

  @override
  bool shouldFullyObstruct(BuildContext context) {
    return true;
  }
}
