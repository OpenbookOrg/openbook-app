import 'package:Okuna/models/user.dart';
import 'package:Okuna/pages/home/pages/profile/widgets/profile_card/widgets/profile_details/widgets/profile_age.dart';
import 'package:Okuna/pages/home/pages/profile/widgets/profile_card/widgets/profile_details/widgets/profile_location.dart';
import 'package:Okuna/pages/home/pages/profile/widgets/profile_card/widgets/profile_details/widgets/profile_url.dart';
import 'package:flutter/material.dart';

class OBProfileDetails extends StatelessWidget {
  final User user;

  const OBProfileDetails(this.user);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: user.updateSubject,
      initialData: user,
      builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
        var user = snapshot.data!;
        if ((!user.hasProfileLocation() && !user.hasProfileUrl()) && !user.hasAge())
          return const SizedBox();

        int _childrenCount = 0;

        if (user.hasProfileLocation())_childrenCount++;
        if (user.hasProfileUrl())_childrenCount++;
        if (user.hasAge())_childrenCount++;

        return Padding(
            padding: EdgeInsets.only(top: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: SizedBox(
                    child: Wrap(
                      spacing: _childrenCount == 1 ? 0.0 : 10.0,
                      runSpacing: 10.0,
                      children: <Widget>[
                        OBProfileLocation(user),
                        OBProfileUrl(user),
                        OBProfileAge(user),
                      ],
                    ),
                  ),
                )
              ],
            ));
      },
    );
  }
}
