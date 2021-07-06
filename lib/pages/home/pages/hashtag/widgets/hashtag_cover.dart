import 'package:Okuna/models/hashtag.dart';
import 'package:Okuna/widgets/cover.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OBHashtagCover extends StatelessWidget {
  final Hashtag hashtag;

  OBHashtagCover(this.hashtag);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: hashtag.updateSubject,
      initialData: hashtag,
      builder: (BuildContext context, AsyncSnapshot<Hashtag> snapshot) {
        String? hashtagCover = hashtag.image;

        return Stack(
          children: <Widget>[
            OBCover(
              coverUrl: hashtagCover,
              size: OBCoverSize.small,
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              child: DecoratedBox(
                  decoration: BoxDecoration(color: Colors.black54)),
            )
          ],
        );
      },
    );
  }
}
