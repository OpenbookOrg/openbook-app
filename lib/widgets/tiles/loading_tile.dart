import 'package:flutter/material.dart';

// TODO Refactor this into a tile that takes an async action, which can then
// optionally retry

class OBLoadingTile extends StatelessWidget {
  final bool isLoading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  const OBLoadingTile(
      {Key? key,
      this.isLoading = false,
      this.title,
      this.subtitle,
      this.onTap,
      this.trailing,
      this.leading})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget tile = ListTile(
      leading: leading,
      title: title,
      subtitle: subtitle,
      trailing: trailing,
      onTap: isLoading ? null : onTap,
    );

    if (isLoading) {
      tile = Opacity(
        opacity: 0.5,
        child: tile,
      );
    }

    return tile;
  }
}
