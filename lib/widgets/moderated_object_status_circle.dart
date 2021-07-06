import 'package:Okuna/models/moderation/moderated_object.dart';
import 'package:Okuna/models/theme.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:flutter/material.dart';
import 'package:pigment/pigment.dart';

class OBModeratedObjectStatusCircle extends StatelessWidget {
  final ModeratedObjectStatus status;

  static double statusCircleSize = 10;
  static String pendingColor = '#f48c42';

  const OBModeratedObjectStatusCircle({Key? key, required this.status})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    OpenbookProviderState openbookProvider = OpenbookProvider.of(context);
    OBTheme currentTheme = openbookProvider.themeService.getActiveTheme();

    late String circleColor;
    switch (status) {
      case ModeratedObjectStatus.rejected:
        circleColor = currentTheme.dangerColor;
        break;
      case ModeratedObjectStatus.approved:
        circleColor = currentTheme.successColor;
        break;
      case ModeratedObjectStatus.pending:
        circleColor = pendingColor;
        break;
      default:
    }

    return Container(
        height: statusCircleSize,
        width: statusCircleSize,
        decoration: BoxDecoration(
            color: Pigment.fromString(circleColor),
            borderRadius: BorderRadius.circular(50)));
  }
}
