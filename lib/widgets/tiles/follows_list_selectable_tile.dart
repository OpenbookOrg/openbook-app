import 'package:Okuna/libs/pretty_count.dart';
import 'package:Okuna/models/follows_list.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/widgets/emoji_preview.dart';
import 'package:Okuna/widgets/fields/checkbox_field.dart';
import 'package:flutter/material.dart';

import '../../provider.dart';

class OBFollowsListSelectableTile extends StatelessWidget {
  final FollowsList followsList;
  final OnFollowsListPressed? onFollowsListPressed;
  final bool? isSelected;
  final bool isDisabled;

  const OBFollowsListSelectableTile(this.followsList,
      {Key? key,
      this.onFollowsListPressed,
      this.isSelected,
      this.isDisabled = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    int? usersCount = followsList.followsCount;
    LocalizationService localizationService = OpenbookProvider.of(context).localizationService;
    String? prettyCount = usersCount != null
      ? getPrettyCount(usersCount, localizationService)
      : null;

    return OBCheckboxField(
      isDisabled: isDisabled,
      value: isSelected ?? false,
      title: followsList.name!,
      subtitle:
          usersCount != null ?  localizationService.user__follows_list_accounts_count(prettyCount!) : null,
      onTap: () {
        if (onFollowsListPressed != null) {
          onFollowsListPressed!(followsList);
        }
      },
      leading: SizedBox(
        height: 40,
        width: 40,
        child: Center(
          child: OBEmojiPreview(
            followsList.emoji!,
            size: OBEmojiPreviewSize.medium,
          ),
        ),
      ),
    );
  }
}

typedef void OnFollowsListPressed(FollowsList pressedFollowsList);
