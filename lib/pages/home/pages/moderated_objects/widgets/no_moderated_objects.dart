import 'package:Okuna/widgets/alerts/button_alert.dart';
import 'package:Okuna/widgets/icon.dart';
import 'package:flutter/material.dart';

class OBNoModeratedObjects extends StatelessWidget {
  final VoidCallback onWantsToRefreshModeratedObjects;

  OBNoModeratedObjects({required this.onWantsToRefreshModeratedObjects});

  @override
  Widget build(BuildContext context) {
    return OBButtonAlert(
      text: 'No moderation items',
      onPressed: onWantsToRefreshModeratedObjects,
      buttonText: 'Refresh',
      buttonIcon: OBIcons.refresh,
      assetImage: 'assets/images/stickers/perplexed-owl.png',
    );
  }
}
