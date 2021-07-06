import 'package:Okuna/models/hashtag.dart';
import 'package:Okuna/models/theme.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/theme.dart';
import 'package:Okuna/services/theme_value_parser.dart';
import 'package:Okuna/widgets/avatars/avatar.dart';
export 'package:Okuna/widgets/avatars/avatar.dart';
import 'package:Okuna/widgets/avatars/letter_avatar.dart';
import 'package:flutter/material.dart';
import 'package:tinycolor/tinycolor.dart';

class OBHashtagAvatar extends StatelessWidget {
  final Hashtag hashtag;
  final OBAvatarSize size;
  final VoidCallback? onPressed;
  final bool isZoomable;
  final double? borderRadius;
  final double? customSize;

  const OBHashtagAvatar(
      {Key? key,
      required this.hashtag,
      this.size = OBAvatarSize.small,
      this.isZoomable = false,
      this.borderRadius,
      this.onPressed,
      this.customSize})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: hashtag.updateSubject,
        initialData: hashtag,
        builder: (BuildContext context, AsyncSnapshot<Hashtag> snapshot) {
          Hashtag hashtag = snapshot.data!;
          bool hashtagHasImage = hashtag.hasImage();

          Widget avatar;

          if (hashtagHasImage) {
            avatar = OBAvatar(
                avatarUrl: hashtag.image,
                size: size,
                onPressed: onPressed,
                isZoomable: isZoomable,
                borderRadius: borderRadius,
                customSize: customSize);
          } else {
            String hashtagHexColor = hashtag.color!;

            OpenbookProviderState openbookProviderState = OpenbookProvider.of(context);

            Color hashtagColor =  openbookProviderState.utilsService.parseHexColor(hashtagHexColor);
            Color textColor = Colors.white;

            avatar = OBLetterAvatar(
                letter: '#',
                color: hashtagColor,
                size: size,
                onPressed: onPressed,
                borderRadius: borderRadius,
                labelColor: textColor,
                customSize: customSize);
          }

          return avatar;
        });
  }
}
