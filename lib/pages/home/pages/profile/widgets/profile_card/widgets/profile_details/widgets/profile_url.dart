import 'package:Okuna/models/user.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/widgets/icon.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:flutter/material.dart';

class OBProfileUrl extends StatelessWidget {
  final User user;

  const OBProfileUrl(this.user);

  @override
  Widget build(BuildContext context) {
    String? url = user.getProfileUrl();

    if (url == null) {
      return const SizedBox();
    }

    return GestureDetector(
      onTap: () async {
        OpenbookProviderState openbookProvider = OpenbookProvider.of(context);
        openbookProvider.urlLauncherService.launchUrl(url);
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const OBIcon(
            OBIcons.link,
            customSize: 14,
          ),
          const SizedBox(
            width: 10,
          ),
          Flexible(
              child: OBText(
                url,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(decoration: TextDecoration.underline),
              ))
        ],
      ),
    );
  }
}
