import 'package:Okuna/models/post.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/widgets/buttons/button.dart';
import 'package:Okuna/widgets/icon.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OBPostActionComment extends StatelessWidget {
  final Post _post;
  final VoidCallback? onWantsToCommentPost;

  OBPostActionComment(this._post, {this.onWantsToCommentPost});

  @override
  Widget build(BuildContext context) {
    var openbookProvider = OpenbookProvider.of(context);
    var navigationService = openbookProvider.navigationService;
    var localizationService = openbookProvider.localizationService;

    return OBButton(
        type: OBButtonType.highlight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const OBIcon(
              OBIcons.comment,
              customSize: 20.0,
            ),
            const SizedBox(
              width: 10.0,
            ),
            OBText(localizationService.trans('post__action_comment')),
          ],
        ),
        onPressed: () {
          if (onWantsToCommentPost != null) {
            onWantsToCommentPost!();
          } else {
            navigationService.navigateToCommentPost(
                post: _post, context: context);
          }
        });
  }
}

typedef void OnWantsToCommentPost(Post post);
