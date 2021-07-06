import 'package:Okuna/services/localization.dart';
import 'package:Okuna/widgets/theming/secondary_text.dart';
import 'package:flutter/material.dart';

import '../../provider.dart';
import '../icon.dart';

class OBSeeAllButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String resourceName;
  final int previewedResourcesCount;
  final int resourcesCount;

  const OBSeeAllButton(
      {Key? key,
      required this.onPressed,
      required this.resourceName,
      required this.previewedResourcesCount,
      required this.resourcesCount})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    int remainingResourcesToDisplay = resourcesCount - previewedResourcesCount;
    LocalizationService _localizationService = OpenbookProvider.of(context).localizationService;

    if (previewedResourcesCount == 0 || remainingResourcesToDisplay <= 0) return const SizedBox();

    return GestureDetector(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            OBSecondaryText(
              _localizationService.moderation__reports_see_all(resourcesCount, resourceName),
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(
              width: 5,
            ),
            OBIcon(OBIcons.seeMore, themeColor: OBIconThemeColor.secondaryText)
          ],
        ),
      ),
    );
  }
}
