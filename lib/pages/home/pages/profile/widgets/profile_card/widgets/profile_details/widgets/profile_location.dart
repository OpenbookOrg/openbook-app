import 'package:Okuna/models/user.dart';
import 'package:Okuna/widgets/icon.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:flutter/material.dart';

class OBProfileLocation extends StatelessWidget {
  final User user;

  const OBProfileLocation(this.user);

  @override
  Widget build(BuildContext context) {
    String? location = user.getProfileLocation();

    if (location == null) {
      return const SizedBox();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        const OBIcon(
          OBIcons.location,
          customSize: 14,
        ),
        const SizedBox(
          width: 10,
        ),
        Flexible(
          child: OBText(
            location,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        )
      ],
    );
  }
}
