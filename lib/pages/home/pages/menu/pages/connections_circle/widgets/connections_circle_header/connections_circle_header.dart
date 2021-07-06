import 'package:Okuna/models/circle.dart';
import 'package:Okuna/pages/home/pages/menu/pages/connections_circle/widgets/connections_circle_header/widgets/connections_circle_name.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/widgets/circle_color_preview.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:flutter/material.dart';

import '../../../../../../../../provider.dart';

class OBConnectionsCircleHeader extends StatelessWidget {
  final Circle connectionsCircle;
  final bool isConnectionsCircle;

  OBConnectionsCircleHeader(this.connectionsCircle,
      {this.isConnectionsCircle = false});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: connectionsCircle.updateSubject,
        initialData: connectionsCircle,
        builder: (BuildContext context, AsyncSnapshot<Circle> snapshot) {
          var connectionsCircle = snapshot.data!;
          LocalizationService _localizationService = OpenbookProvider.of(context).localizationService;

          List<Widget> columnItems = [_buildCircleName(connectionsCircle)];

          if (isConnectionsCircle) {
            columnItems.add(_buildConnectionsCircleDescription(_localizationService));
          }

          columnItems.add(_buildUsersHeader(_localizationService));

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: columnItems,
          );
        });
  }

  Widget _buildCircleName(Circle connectionsCircle) {
    return Padding(
      padding: EdgeInsets.only(left: 20.0, right: 20, top: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(
            child: OBConnectionsCircleName(connectionsCircle),
          ),
          OBCircleColorPreview(
            connectionsCircle,
            size: OBCircleColorPreviewSize.large,
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionsCircleDescription(LocalizationService _localizationService) {
    return Padding(
      padding: EdgeInsets.only(left: 20.0, right: 20, top: 10.0, bottom: 20),
      child: Column(
        children: <Widget>[
          OBText(_localizationService.trans('user__connections_header_circle_desc')),
        ],
      ),
    );
  }

  Widget _buildUsersHeader(LocalizationService _localizationService) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20),
      child: OBText(_localizationService.trans('user__connections_header_users'),
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
    );
  }
}
