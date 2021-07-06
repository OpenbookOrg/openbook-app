import 'package:Okuna/libs/type_to_str.dart';
import 'package:Okuna/models/moderation/moderation_category.dart';
import 'package:Okuna/models/moderation/moderation_category_list.dart';
import 'package:Okuna/services/navigation_service.dart';
import 'package:Okuna/services/user.dart';
import 'package:Okuna/widgets/nav_bars/themed_nav_bar.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/widgets/page_scaffold.dart';
import 'package:Okuna/widgets/progress_indicator.dart';
import 'package:Okuna/widgets/theming/primary_color_container.dart';
import 'package:Okuna/widgets/theming/secondary_text.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OBReportObjectPage extends StatefulWidget {
  final dynamic object;
  final OnObjectReported? onObjectReported;
  final Map<String, dynamic>? extraData;

  const OBReportObjectPage({
    Key? key,
    this.object,
    this.onObjectReported,
    this.extraData,
  }) : super(key: key);

  @override
  OBReportObjectPageState createState() {
    return OBReportObjectPageState();
  }
}

class OBReportObjectPageState extends State<OBReportObjectPage> {
  late NavigationService _navigationService;
  late UserService _userService;
  late List<ModerationCategory> _moderationCategories = [];
  late bool _needsBootstrap;

  @override
  void initState() {
    super.initState();
    _needsBootstrap = true;
  }

  @override
  Widget build(BuildContext context) {
    if (_needsBootstrap) {
      var openbookProvider = OpenbookProvider.of(context);
      _userService = openbookProvider.userService;
      _navigationService = openbookProvider.navigationService;
      _bootstrap();
      _needsBootstrap = false;
    }

    return OBCupertinoPageScaffold(
        navigationBar: _buildNavigationBar(),
        child: OBPrimaryColorContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding:
                    EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 20),
                child: OBText(
                  'Why are you reporting this ' +
                      modelTypeToString(widget.object) +
                      '?',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
              _moderationCategories.isEmpty
                  ? _buildProgressIndicator()
                  : _buildModerationCategories(),
            ],
          ),
        ));
  }

  Widget _buildProgressIndicator() {
    return Expanded(
      child: Center(
        child: OBProgressIndicator(),
      ),
    );
  }

  Widget _buildModerationCategories() {
    return Expanded(
      child: ListView.separated(
        padding: EdgeInsets.all(0.0),
        itemBuilder: _buildModerationCategoryTile,
        separatorBuilder: (context, index) {
          return const Divider();
        },
        itemCount: _moderationCategories.length,
      ),
    );
  }

  Widget _buildModerationCategoryTile(context, index) {
    ModerationCategory category = _moderationCategories[index];

    return ListTile(
      onTap: () async {
        var result = await _navigationService.navigateToConfirmReportObject(
            extraData: widget.extraData,
            object: widget.object,
            category: category,
            context: context);
        if (result != null && result) {
          if (widget.onObjectReported != null)
            widget.onObjectReported!(widget.object);
          Navigator.pop(context);
        }
      },
      title: OBText(
        category.title ?? '',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: OBSecondaryText(category.description ?? ''),
      //trailing: OBIcon(OBIcons.chevronRight),
    );
  }

  ObstructingPreferredSizeWidget _buildNavigationBar() {
    return OBThemedNavigationBar(
      title: 'Report ' + modelTypeToString(widget.object),
    );
  }

  void _bootstrap() async {
    var moderationCategories = await _userService.getModerationCategories();
    _setModerationCategories(moderationCategories);
  }

  _setModerationCategories(ModerationCategoriesList moderationCategoriesList) {
    setState(() {
      _moderationCategories = moderationCategoriesList.moderationCategories!;
    });
  }
}

typedef OnObjectReported(dynamic object);
