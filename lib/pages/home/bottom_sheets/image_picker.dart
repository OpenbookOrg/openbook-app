import 'dart:io';

import 'package:Okuna/pages/home/bottom_sheets/rounded_bottom_sheet.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/media/media.dart';
import 'package:Okuna/widgets/icon.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class OBImagePickerBottomSheet extends StatelessWidget {
  const OBImagePickerBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var provider = OpenbookProvider.of(context);
    var imagePicker = ImagePicker();

    LocalizationService localizationService = provider.localizationService;

    List<Widget> imagePickerActions = [
      ListTile(
        leading: const OBIcon(OBIcons.gallery),
        title: OBText(
          localizationService.image_picker__from_gallery,
        ),
        onTap: () async {
          bool permissionGranted = await provider.permissionService
              .requestStoragePermissions(context: context);
          if (permissionGranted) {
            PickedFile? pickedFile =
                await imagePicker.getImage(source: ImageSource.gallery);

            if (pickedFile != null) {
              File file = File(pickedFile.path);
              Navigator.pop(context, file);
            }
          }
        },
      ),
      ListTile(
        leading: const OBIcon(OBIcons.camera),
        title: OBText(
          localizationService.image_picker__from_camera,
        ),
        onTap: () async {
          bool permissionGranted = await provider.permissionService
              .requestCameraPermissions(context: context);
          if (permissionGranted) {
            PickedFile? pickedFile =
                await imagePicker.getImage(source: ImageSource.camera);

            File? pickedImage = pickedFile != null ? File(pickedFile.path) : null;
            Navigator.pop(context, pickedImage);
          }
        },
      )
    ];

    return OBRoundedBottomSheet(
        child: Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Column(
        children: imagePickerActions,
        mainAxisSize: MainAxisSize.min,
      ),
    ));
  }
}
