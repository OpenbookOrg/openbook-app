import 'package:Okuna/pages/home/bottom_sheets/rounded_bottom_sheet.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/httpie.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/toast.dart';
import 'package:Okuna/services/user.dart';
import 'package:Okuna/widgets/buttons/button.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:async/async.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OBConfirmActionBottomSheet extends StatefulWidget {
  final String? title;
  final String? subtitle;
  final String? description;
  final String? confirmText;
  final String? cancelText;
  final ActionCompleter actionCompleter;

  const OBConfirmActionBottomSheet(
      {this.title,
      required this.actionCompleter,
      this.confirmText,
      this.cancelText,
      this.subtitle,
      this.description});

  @override
  State<StatefulWidget> createState() {
    return OBConfirmActionBottomSheetState();
  }
}

class OBConfirmActionBottomSheetState
    extends State<OBConfirmActionBottomSheet> {
  late ToastService _toastService;
  late LocalizationService _localizationService;
  late bool _needsBootstrap;

  late bool _isConfirmActionInProgress;
  CancelableOperation? _confirmActionOperation;

  @override
  void initState() {
    super.initState();
    _needsBootstrap = true;
    _isConfirmActionInProgress = false;
  }

  @override
  void dispose() {
    super.dispose();
    _confirmActionOperation?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    if (_needsBootstrap) {
      var openbookProvider = OpenbookProvider.of(context);
      _toastService = openbookProvider.toastService;
      _localizationService = openbookProvider.localizationService;
      _needsBootstrap = false;
    }

    final confirmationText = widget.title ??
        _localizationService.bottom_sheets__confirm_action_are_you_sure;
    final confirmText = widget.confirmText ??
        _localizationService.bottom_sheets__confirm_action_yes;
    final cancelText = widget.confirmText ??
        _localizationService.bottom_sheets__confirm_action_no;

    List<Widget> columnItems = [
      OBText(
        confirmationText,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        textAlign: TextAlign.left,
      ),
    ];

    if (widget.subtitle != null) {
      columnItems.addAll([
        const SizedBox(
          height: 10,
        ),
        OBText(
          widget.subtitle!,
          size: OBTextSize.large,
          textAlign: TextAlign.left,
        ),
      ]);
    }

    if (widget.description != null) {
      columnItems.addAll([
        const SizedBox(
          height: 10,
        ),
        OBText(
          widget.description!,
          size: OBTextSize.medium,
          textAlign: TextAlign.left,
        ),
      ]);
    }
    columnItems.addAll([
      const SizedBox(
        height: 20,
      ),
      Row(
        children: <Widget>[
          Expanded(
            child: OBButton(
              size: OBButtonSize.large,
              child: Text(cancelText),
              type: OBButtonType.danger,
              onPressed: _onPressedCancel,
            ),
          ),
          const SizedBox(
            width: 20,
          ),
          Expanded(
            child: OBButton(
              size: OBButtonSize.large,
              child: Text(confirmText),
              type: OBButtonType.success,
              isLoading: _isConfirmActionInProgress,
              onPressed: _onPressedConfirm,
            ),
          )
        ],
      )
    ]);

    return OBRoundedBottomSheet(
        child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: columnItems),
    ));
  }

  Future<void> _onPressedConfirm() async {
    _setConfirmActionInProgress(true);
    try {
      await widget.actionCompleter(context);
      Navigator.pop(context);
    } catch (error) {
      _onError(error);
      rethrow;
    } finally {
      _setConfirmActionInProgress(false);
    }
  }

  void _onPressedCancel() {
    Navigator.pop(context);
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

  void _setConfirmActionInProgress(bool confirmActionInProgress) {
    setState(() {
      _isConfirmActionInProgress = confirmActionInProgress;
    });
  }
}

typedef Future ActionCompleter(BuildContext context);
