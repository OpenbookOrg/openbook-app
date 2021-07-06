import 'package:Okuna/models/post.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/widgets/post/widgets/post-body/widgets/post_body_link_preview.dart';
import 'package:Okuna/widgets/post/widgets/post-body/widgets/post_body_media/post_body_media.dart';
import 'package:Okuna/widgets/post/widgets/post-body/widgets/post_body_text.dart';
import 'package:flutter/material.dart';

class OBPostBody extends StatelessWidget {
  final Post post;
  final OnTextExpandedChange? onTextExpandedChange;
  final String? inViewId;

  const OBPostBody(this.post,
      {Key? key, this.onTextExpandedChange, this.inViewId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> bodyItems = [];
    OpenbookProviderState openbookProvider = OpenbookProvider.of(context);
    if (post.hasMediaThumbnail()) {
      bodyItems.add(OBPostBodyMedia(post: post, inViewId: inViewId));
    }

    if (post.hasText()) {
      if (!post.hasMediaThumbnail() &&
          post.hasLinkToPreview()) {
        bodyItems.add(
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: OBPostBodyLinkPreview(post: post),
          ),
        );
      }

      bodyItems.add(OBPostBodyText(
        post,
        onTextExpandedChange: onTextExpandedChange,
      ));
    }

    return Row(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: bodyItems,
        ))
      ],
    );
  }
}
