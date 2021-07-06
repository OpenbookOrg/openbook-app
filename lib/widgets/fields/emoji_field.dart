import 'package:Okuna/models/emoji.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/widgets/emoji_picker/widgets/emoji_groups/widgets/emoji_group/widgets/emoji.dart';
import 'package:Okuna/widgets/theming/divider.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:flutter/material.dart';

import '../../provider.dart';

class OBEmojiField extends StatelessWidget {
  final Emoji? emoji;
  final String? subtitle;
  final String? labelText;
  final String? errorText;
  final OnEmojiFieldTapped? onEmojiFieldTapped;

  const OBEmojiField(
      {Key? key,
      this.emoji,
      this.subtitle,
      this.labelText,
      this.onEmojiFieldTapped,
      this.errorText})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    LocalizationService _localizationService = OpenbookProvider.of(context).localizationService;
    return Column(
      children: <Widget>[
        MergeSemantics(
          child: ListTile(
              title: OBText(
                labelText ?? '',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              subtitle: errorText != null
                  ? Text(errorText!, style: TextStyle(color: Colors.red))
                  : null,
              trailing: emoji == null ? OBText(_localizationService.user__emoji_field_none_selected) : OBEmoji(emoji!),
              onTap: () {
                if (onEmojiFieldTapped != null) onEmojiFieldTapped!(emoji);
              }),
        ),
        OBDivider(),
      ],
    );
  }
}

typedef void OnEmojiFieldTapped(Emoji? currentEmoji);
