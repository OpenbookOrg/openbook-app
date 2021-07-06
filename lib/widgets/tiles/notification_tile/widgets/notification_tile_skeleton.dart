import 'package:flutter/material.dart';

class OBNotificationTileSkeleton extends StatelessWidget {
  final Widget leading;
  final Widget? trailing;
  final Widget title;
  final Widget subtitle;
  final VoidCallback? onTap;

  const OBNotificationTileSkeleton(
      {Key? key,
      required this.leading,
      this.trailing,
      required this.title,
      this.onTap,
      required this.subtitle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget paddedTrailing = trailing != null
        ? Padding(
            padding: const EdgeInsets.only(left: 10),
            child: trailing,
          )
        : const SizedBox();

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            leading,
            const SizedBox(
              width: 15,
            ),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[title, subtitle],
              ),
            ),
            paddedTrailing
          ],
        ),
      ),
    );
  }
}
