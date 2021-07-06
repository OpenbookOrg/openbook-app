import 'package:Okuna/models/moderation/moderated_object.dart';
import 'package:Okuna/models/moderation/moderation_category.dart';
import 'package:Okuna/models/moderation/moderation_category_list.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/toast.dart';
import 'package:Okuna/services/user.dart';
import 'package:Okuna/widgets/buttons/button.dart';
import 'package:Okuna/widgets/checkbox.dart';
import 'package:Okuna/widgets/nav_bars/themed_nav_bar.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/widgets/page_scaffold.dart';
import 'package:Okuna/widgets/progress_indicator.dart';
import 'package:Okuna/widgets/theming/primary_color_container.dart';
import 'package:Okuna/widgets/theming/secondary_text.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OBModeratedObjectUpdateCategoryModal extends StatefulWidget {
  final ModeratedObject moderatedObject;

  const OBModeratedObjectUpdateCategoryModal(
      {Key? key, required this.moderatedObject})
      : super(key: key);

  @override
  OBModeratedObjectUpdateCategoryModalState createState() {
    return OBModeratedObjectUpdateCategoryModalState();
  }
}

class OBModeratedObjectUpdateCategoryModalState
    extends State<OBModeratedObjectUpdateCategoryModal> {
  late UserService _userService;
  late ToastService _toastService;
  late LocalizationService _localizationService;
  List<ModerationCategory> _moderationCategories = [];
  late ModerationCategory _selectedModerationCategory;
  late bool _needsBootstrap;
  late bool _requestInProgress;

  @override
  void initState() {
    super.initState();
    _needsBootstrap = true;
    _requestInProgress = false;
    _selectedModerationCategory = widget.moderatedObject.category!;
  }

  @override
  Widget build(BuildContext context) {
    if (_needsBootstrap) {
      var openbookProvider = OpenbookProvider.of(context);
      _toastService = openbookProvider.toastService;
      _userService = openbookProvider.userService;
      _localizationService = openbookProvider.localizationService;
      _bootstrap();
      _needsBootstrap = false;
    }

    return OBCupertinoPageScaffold(
        navigationBar: _buildNavigationBar(),
        child: OBPrimaryColorContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
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
        itemBuilder: _buildModerationCategoryTile,
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        separatorBuilder: (context, index) {
          return const Divider();
        },
        itemCount: _moderationCategories.length,
      ),
    );
  }

  Widget _buildModerationCategoryTile(context, index) {
    ModerationCategory category = _moderationCategories[index];

    return GestureDetector(
      key: Key(category.id.toString()),
      onTap: () => _setSelectedModerationCategory(category),
      child: Row(
        children: <Widget>[
          Expanded(
            child: ListTile(
              title: OBText(
                category.title!,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: OBSecondaryText(category.description!),
              //trailing: OBIcon(OBIcons.chevronRight),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: OBCheckbox(
              value: _selectedModerationCategory.id == category.id,
            ),
          )
        ],
      ),
    );
  }

  void _setSelectedModerationCategory(ModerationCategory category) {
    setState(() {
      _selectedModerationCategory = category;
    });
  }

  void _saveModerationCategory() async{
    _setRequestInProgress(true);
    try {
      await _userService.updateModeratedObject(widget.moderatedObject,
          category: _selectedModerationCategory);
      Navigator.of(context).pop(_selectedModerationCategory);
    } catch (error) {
      _onError(error);
    } finally {
      _setRequestInProgress(false);
    }
  }

  void _onError(error) async {
    if (error is HttpieConnectionRefusedError) {
      _toastService.error(
          message: error.toHumanReadableMessage(), context: context);
    } else if (error is HttpieRequestError) {
      String? errorMessage = await error.toHumanReadableMessage();
      _toastService.error(message: errorMessage ?? _localizationService.trans('error__unknown_error'), context: context);
    } else {
      _toastService.error(message: _localizationService.trans('error__unknown_error'), context: context);
      throw error;
    }
  }

  ObstructingPreferredSizeWidget _buildNavigationBar() {
    return OBThemedNavigationBar(
      title: _localizationService.trans('moderation__update_category_title'),
      trailing: OBButton(
        isLoading: _requestInProgress,
        size: OBButtonSize.small,
        onPressed: _saveModerationCategory,
        child: Text(_localizationService.trans('moderation__update_category_save')),
      ),
    );
  }

  void _bootstrap() async {
    var moderationCategories = await _userService.getModerationCategories();
    _setModerationCategories(moderationCategories);
  }

  _setModerationCategories(ModerationCategoriesList moderationCategoriesList) {
    setState(() {
      _moderationCategories = moderationCategoriesList.moderationCategories ?? [];
    });
  }

  _setRequestInProgress(bool requestInProgress) {
    setState(() {
      _requestInProgress = requestInProgress;
    });
  }
}

typedef OnObjectReported(dynamic object);
