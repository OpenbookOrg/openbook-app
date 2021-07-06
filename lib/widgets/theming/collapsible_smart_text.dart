import 'package:Okuna/models/hashtag.dart';
import 'package:Okuna/models/post_link.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/widgets/icon.dart';
import 'package:Okuna/widgets/theming/secondary_text.dart';
import 'package:Okuna/widgets/theming/smart_text.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';

import '../../provider.dart';
import 'actionable_smart_text.dart';

class OBCollapsibleSmartText extends StatefulWidget {
  final String? text;
  final int? maxlength;
  final OBTextSize size;
  final TextOverflow overflow;
  final TextOverflow lengthOverflow;
  final SmartTextElement? trailingSmartTextElement;
  final Function? getChild;
  final Map<String, Hashtag>? hashtagsMap;
  final List<PostLink>? links;

  const OBCollapsibleSmartText(
      {Key? key,
      this.text,
      this.maxlength,
      this.size = OBTextSize.medium,
      this.overflow = TextOverflow.clip,
      this.lengthOverflow = TextOverflow.ellipsis,
      this.getChild,
      this.trailingSmartTextElement,
      this.hashtagsMap,
      this.links})
      : super(key: key);

  @override
  OBCollapsibleSmartTextState createState() {
    return OBCollapsibleSmartTextState();
  }
}

class OBCollapsibleSmartTextState extends State<OBCollapsibleSmartText> {
  late ExpandableController _expandableController;

  @override
  void initState() {
    super.initState();
    _expandableController = ExpandableController();
  }

  @override
  Widget build(BuildContext context) {
    bool shouldBeCollapsed = widget.text != null && widget.maxlength != null && widget.text!.length > widget.maxlength!;
    LocalizationService _localizationService =
        OpenbookProvider.of(context).localizationService;

    return shouldBeCollapsed
        ? _buildExpandableActionableSmartText(_localizationService)
        : _buildActionableSmartText();
  }

  Widget _buildExpandableActionableSmartText(
      LocalizationService _localizationService) {
    return ExpandableNotifier(
      controller: _expandableController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expandable(
            collapsed: _buildActionableSmartText(maxLength: widget.maxlength),
            expanded: _buildActionableSmartText(),
          ),
          Builder(builder: (BuildContext context) {
            var exp = ExpandableController.of(context);

            if (exp?.expanded == true) return const SizedBox();

            return GestureDetector(
                onTap: _toggleExpandable,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      widget.getChild!(),
                      Row(
                        children: <Widget>[
                          OBSecondaryText(
                            _localizationService.post__actions_show_more_text,
                            size: widget.size,
                            textAlign: TextAlign.start,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          OBIcon(
                            OBIcons.arrowDown,
                            themeColor: OBIconThemeColor.secondaryText,
                          )
                        ],
                      ),
                    ],
                  ),
                ));
          })
        ],
      ),
    );
  }

  void _toggleExpandable() {
    _expandableController.toggle();
  }

  Widget _buildActionableSmartText({int? maxLength}) {
    Widget translateButton;

    if (maxLength != null) {
      translateButton = SizedBox();
    } else {
      translateButton = Padding(
        padding: EdgeInsets.only(top: 10.0),
        child: widget.getChild!(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        OBActionableSmartText(
          text: widget.text,
          maxlength: maxLength,
          size: widget.size,
          lengthOverflow: widget.lengthOverflow,
          trailingSmartTextElement: widget.trailingSmartTextElement,
          hashtagsMap: widget.hashtagsMap,
          links: widget.links,
        ),
        translateButton
      ],
    );
  }
}
