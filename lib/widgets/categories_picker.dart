import 'package:Okuna/models/categories_list.dart';
import 'package:Okuna/models/category.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/toast.dart';
import 'package:Okuna/widgets/category_badge.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/user.dart';
import 'package:Okuna/widgets/tiles/retry_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OBCategoriesPicker extends StatefulWidget {
  final List<Category>? initialCategories;
  final ValueChanged<List<Category>> onChanged;
  final maxSelections;

  const OBCategoriesPicker(
      {Key? key,
      this.initialCategories,
      this.maxSelections,
      required this.onChanged})
      : super(key: key);

  @override
  OBCategoriesPickerState createState() {
    return OBCategoriesPickerState();
  }
}

class OBCategoriesPickerState extends State<OBCategoriesPicker> {
  late UserService _userService;
  late ToastService _toastService;
  late LocalizationService _localizationService;
  late bool _hasError;

  late bool _needsBootstrap;
  late bool _requestInProgress;

  late List<Category> _categories;
  late List<Category> _pickedCategories;

  @override
  void initState() {
    super.initState();
    _categories = [];
    _pickedCategories = widget.initialCategories == null
        ? []
        : widget.initialCategories!.toList();
    _needsBootstrap = true;
    _requestInProgress = true;
    _hasError = true;
  }

  @override
  Widget build(BuildContext context) {
    if (_needsBootstrap) {
      var openbookProvider = OpenbookProvider.of(context);
      _userService = openbookProvider.userService;
      _toastService = openbookProvider.toastService;
      _localizationService = openbookProvider.localizationService;
      _bootstrap();
      _needsBootstrap = false;
    }

    return _hasError
        ? OBRetryTile(
            isLoading: _requestInProgress,
            onWantsToRetry: _onWantsToRetry,
          )
        : Wrap(
            alignment: WrapAlignment.start,
            spacing: 10,
            runSpacing: 10,
            children: _categories.map(_buildCategory).toList());
  }

  void _bootstrap() async {
    _refreshCategories();
  }

  void _refreshCategories() async {
    _setRequestInProgress(true);
    try {
      CategoriesList categoriesList = await _userService.getCategories();
      _setHasError(false);
      _setCategories(categoriesList.categories);
    } catch (error) {
      _setHasError(true);
      _onError(error);
    } finally{
      _setRequestInProgress(false);
    }
  }

  void _onWantsToRetry() {
    _refreshCategories();
  }

  Widget _buildCategory(Category category) {
    return OBCategoryBadge(
      category: category,
      size: OBCategoryBadgeSize.large,
      isEnabled: _pickedCategories.contains(category),
      onPressed: _onCategoryPressed,
    );
  }

  void _onCategoryPressed(Category pressedCategory) {
    if (_pickedCategories.contains(pressedCategory)) {
      // Remove
      _removeSelectedCategory(pressedCategory);
    } else {
      // Add
      if (widget.maxSelections != null &&
          widget.maxSelections == _pickedCategories.length) return;
      _addSelectedCategory(pressedCategory);
    }

    if (widget.onChanged != null) widget.onChanged(_pickedCategories.toList());
  }

  void _addSelectedCategory(Category category) {
    setState(() {
      _pickedCategories.add(category);
    });
  }

  void _removeSelectedCategory(Category category) {
    setState(() {
      _pickedCategories.remove(category);
    });
  }

  void _setCategories(List<Category>? categories) {
    setState(() {
      _categories = categories ?? [];
    });
  }

  void _setHasError(bool hasError) {
    setState(() {
      _hasError = hasError;
    });
  }

  void _setRequestInProgress(bool requestInProgress) {
    setState(() {
      _requestInProgress = requestInProgress;
    });
  }

  void _onError(error) async {
    if (error is HttpieConnectionRefusedError) {
      _toastService.error(
          message: error.toHumanReadableMessage(), context: context);
    } else if (error is HttpieRequestError) {
      String? errorMessage = await error.toHumanReadableMessage();
      _toastService.error(message: errorMessage ?? _localizationService.error__unknown_error, context: context);
    } else {
      _toastService.error(
          message: _localizationService.error__unknown_error, context: context);
      throw error;
    }
  }
}
