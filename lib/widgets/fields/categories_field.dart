import 'package:Okuna/models/category.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/widgets/categories_picker.dart';
import 'package:Okuna/widgets/theming/divider.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../provider.dart';

class OBCategoriesField extends StatefulWidget {
  final OBCategoriesFieldController? controller;
  final String title;
  final int max;
  final int min;
  final bool displayErrors;
  final ValueChanged<List<Category>> onChanged;
  final List<Category>? initialCategories;

  const OBCategoriesField(
      {Key? key,
      this.controller,
      required this.title,
      required this.max,
      required this.min,
      required this.onChanged,
      this.displayErrors = false,
      this.initialCategories})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return OBCategoriesFieldState();
  }
}

class OBCategoriesFieldState extends State<OBCategoriesField> {
  late bool _isValid;
  late LocalizationService _localizationService;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      widget.controller!.attach(this);
    }
    _isValid = widget.initialCategories == null
        ? false
        : _categoriesLengthIsValid(widget.initialCategories!);
  }

  @override
  Widget build(BuildContext context) {
    int max = widget.max;
    var openbookProvider = OpenbookProvider.of(context);
    _localizationService = openbookProvider.localizationService;

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: OBText(
                widget.title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: OBText(_localizationService.community__pick_upto_max(max)),
            ),
          ),
          OBCategoriesPicker(
            maxSelections: widget.max,
            onChanged: _onCategoriesChanged,
            initialCategories: widget.initialCategories,
          ),
          widget.displayErrors && !_isValid
              ? _buildErrorMsg()
              : const SizedBox(
                  height: 20,
                ),
          OBDivider()
        ]);
  }

  Widget _buildErrorMsg() {
    int min = widget.min;
    String errorMsg;
    if (min == 1) {
      errorMsg = _localizationService.community__pick_atleast_min_category(min);
    } else {
      errorMsg = _localizationService.community__pick_atleast_min_categories(min);
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 10, top: 20),
      child: OBText(
        errorMsg,
        style: TextStyle(color: Colors.redAccent),
      ),
    );
  }

  void _onCategoriesChanged(List<Category> categories) {
    _setIsValid(_categoriesLengthIsValid(categories));
    widget.onChanged(categories);
  }

  void _setIsValid(bool isValid) {
    setState(() {
      this._isValid = isValid;
    });
  }

  bool _categoriesLengthIsValid(List<Category> categories) {
    int min = widget.min;
    return categories.length >= min;
  }
}

class OBCategoriesFieldController {
  OBCategoriesFieldState? _state;

  void attach(OBCategoriesFieldState state) {
    _state = state;
  }

  bool isValid() {
    return _state == null ? false : _state!._isValid;
  }
}
