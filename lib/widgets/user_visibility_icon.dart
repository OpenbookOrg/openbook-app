import 'package:Okuna/models/user.dart';
import 'package:flutter/material.dart';

import 'icon.dart';

enum OBIconSize { small, medium, large, extraLarge }

class OBUserVisibilityIcon extends StatelessWidget {
  final UserVisibility visibility;
  final OBIconSize? size;
  final double? customSize;
  final Color? color;
  final String? semanticLabel;

  const OBUserVisibilityIcon(
      {Key? key,
      this.size,
      this.customSize,
      this.color,
      this.semanticLabel,
      required this.visibility})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (this.visibility) {
      case UserVisibility.public:
        return OBIcon(OBIcons.visibilityPublic);
      case UserVisibility.okuna:
        return OBIcon(OBIcons.visibilityOkuna);
      case UserVisibility.private:
        return OBIcon(OBIcons.visibilityPrivate);
      default:
        print('No icon found for given visibility');
        return const SizedBox();
    }
  }
}
