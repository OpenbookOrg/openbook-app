import 'package:Okuna/models/circle.dart';
import 'package:Okuna/models/post.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/widgets/cirles_wrap.dart';
import 'package:Okuna/widgets/theming/actionable_smart_text.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../provider.dart';

class OBPostCircles extends StatelessWidget {
  final Post _post;

  OBPostCircles(this._post);

  @override
  Widget build(BuildContext context) {
    LocalizationService _localizationService = OpenbookProvider.of(context).localizationService;
    if (_post.hasCircles()) {
      return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: SizedBox(
          height: 26.0,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            itemCount: 1,
            scrollDirection: Axis.horizontal,
            itemBuilder: (BuildContext context, int index) {
              return OBCirclesWrap(
                  textSize: OBTextSize.small,
                  circlePreviewSize: OBCircleColorPreviewSize.extraSmall,
                  leading: OBText(_localizationService.trans('post__you_shared_with'), size: OBTextSize.small),
                  circles: _post.getPostCircles()
              );
            },
          ),
        ),
      );
    } else if (_post.isEncircled != null && _post.isEncircled!) {
      String postCreatorUsername = _post.creator!.username!;

      return Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
        child: Row(
          children: <Widget>[
            OBText(
              _localizationService.trans('post__shared_privately_on'),
              size: OBTextSize.small,
            ),
            SizedBox(
              width: 10,
            ),
            OBCircleColorPreview(
              Circle(color: '#ffffff'),
              size: OBCircleColorPreviewSize.extraSmall,
            ),
            SizedBox(
              width: 5,
            ),
            Flexible(
              child: OBActionableSmartText(
                text: _localizationService.post__usernames_circles(postCreatorUsername),
                size: OBTextSize.small,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox();
  }
}
