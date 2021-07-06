import 'dart:io';

import 'package:Okuna/models/theme.dart';
import 'package:Okuna/pages/home/dialogs/video_dialog.dart';
import 'package:Okuna/services/theme.dart';
import 'package:Okuna/services/theme_value_parser.dart';
import 'package:Okuna/pages/home/modals/zoomable_photo.dart';
import 'package:Okuna/widgets/video_player/widgets/chewie/chewie_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:tinycolor/tinycolor.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock/wakelock.dart';

class DialogService {
  late ThemeService _themeService;
  late ThemeValueParserService _themeValueParserService;

  void setThemeService(ThemeService themeService) {
    _themeService = themeService;
  }

  void setThemeValueParserService(
      ThemeValueParserService themeValueParserService) {
    _themeValueParserService = themeValueParserService;
  }

  Future<dynamic> showColorPicker({
    required ValueChanged<Color> onColorChanged,
    required BuildContext context,
    required Color initialColor,
    bool enableAlpha = false,
  }) {
    return showAlert(
        content: SingleChildScrollView(
          child: ColorPicker(
            enableAlpha: enableAlpha,
            pickerColor: initialColor,
            onColorChanged: onColorChanged,
            pickerAreaHeightPercent: 0.8,
            showLabel: false,
          ),
        ),
        context: context);
  }

  Future<void> showZoomablePhotoBoxView(
      {required String imageUrl, required BuildContext context}) {
    return showGeneralDialog(
      context: context,
      pageBuilder: (BuildContext buildContext, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        final ThemeData theme = Theme.of(context);
        final Widget pageChild = OBZoomablePhotoModal(imageUrl);
        return Builder(builder: (BuildContext context) {
          return theme != null
              ? Theme(data: theme, child: pageChild)
              : pageChild;
        });
      },
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black87,
      transitionDuration: const Duration(milliseconds: 100),
      transitionBuilder: _buildMaterialDialogTransitions,
    );
  }

  Future<void> showVideo(
      {String? videoUrl,
      File? video,
      VideoPlayerController? videoPlayerController,
      ChewieController? chewieController,
      bool autoPlay: true,
      required BuildContext context}) async {
    SystemChrome.setEnabledSystemUIOverlays([]);
    Wakelock.enable();
    await showGeneralDialog(
      context: context,
      pageBuilder: (BuildContext buildContext, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        final ThemeData theme = Theme.of(context);
        final Widget pageChild = Material(
          child: OBVideoDialog(
            autoPlay: autoPlay,
            video: video,
            videoUrl: videoUrl,
            videoPlayerController: videoPlayerController,
            chewieController: chewieController,
          ),
        );
        return Builder(builder: (BuildContext context) {
          return theme != null
              ? Theme(data: theme, child: pageChild)
              : pageChild;
        });
      },
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black,
      transitionDuration: const Duration(milliseconds: 100),
      transitionBuilder: _buildMaterialDialogTransitions,
    );
    Wakelock.disable();
    SystemChrome.setEnabledSystemUIOverlays(
        [SystemUiOverlay.top, SystemUiOverlay.bottom]);
  }

  Widget _buildMaterialDialogTransitions(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
      ),
      child: child,
    );
  }

  Future<dynamic> showAlert(
      {required Widget content,
      List<Widget>? actions,
      Widget? title,
      required BuildContext context}) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: _getDialogShapeBorder(),
            backgroundColor: _getDialogBackgroundColor(),
            content: content,
            actions: actions,
          );
        });
  }

  Color _getDialogBackgroundColor() {
    OBTheme theme = _themeService.getActiveTheme();
    Color primaryColor =
        _themeValueParserService.parseColor(theme.primaryColor);
    return TinyColor(primaryColor).lighten(10).color;
  }

  ShapeBorder _getDialogShapeBorder() {
    return const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)));
  }
}
