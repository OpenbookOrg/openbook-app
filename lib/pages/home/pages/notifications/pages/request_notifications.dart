import 'package:Okuna/models/notifications/notification.dart';
import 'package:Okuna/widgets/http_list.dart';
import 'package:flutter/material.dart';

class OBRequestNotifications extends StatefulWidget {
  final OBHttpListController controller;
  final OBHttpListRefresher<OBNotification> refresher;
  final OBHttpListOnScrollLoader<OBNotification> onScrollLoader;
  final OBHttpListItemBuilder<OBNotification> itemBuilder;
  final String resourceSingularName;
  final String resourcePluralName;

  const OBRequestNotifications(
      {Key? key,
      required this.controller,
      required this.refresher,
      required this.onScrollLoader,
      required this.itemBuilder,
      required this.resourceSingularName,
      required this.resourcePluralName})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return OBRequestNotificationsState();
  }
}

class OBRequestNotificationsState extends State<OBRequestNotifications>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    return OBHttpList(
      key: Key('requestNotificationsList'),
      controller: widget.controller,
      listRefresher: widget.refresher,
      listOnScrollLoader: widget.onScrollLoader,
      listItemBuilder: widget.itemBuilder,
      resourceSingularName: widget.resourceSingularName,
      resourcePluralName: widget.resourcePluralName,
      physics: const ClampingScrollPhysics(),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
