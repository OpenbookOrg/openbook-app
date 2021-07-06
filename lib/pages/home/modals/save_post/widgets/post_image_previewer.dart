import 'dart:io';

import 'package:Okuna/models/post_image.dart';
import 'package:Okuna/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';

class OBPostImagePreviewer extends StatelessWidget {
  final PostImage? postImage;
  final File? postImageFile;
  final VoidCallback? onRemove;
  final VoidCallback? onWillEditImage;

  final ValueChanged<File>? onPostImageEdited;

  final double buttonSize = 30.0;

  const OBPostImagePreviewer(
      {Key? key,
      this.postImage,
      this.postImageFile,
      this.onRemove,
      this.onWillEditImage,
      this.onPostImageEdited})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double avatarBorderRadius = 10.0;

    bool isFileImage = postImageFile != null;

    var imagePreview = SizedBox(
        height: 200.0,
        width: 200,
        child: ClipRRect(
            borderRadius: new BorderRadius.circular(avatarBorderRadius),
            child: isFileImage
                ? Image.file(
                    postImageFile!,
                    fit: BoxFit.cover,
                  )
                : Image(
                    fit: BoxFit.cover,
                    image: AdvancedNetworkImage(postImage!.image ?? '',
                        useDiskCache: true,
                        fallbackAssetImage:
                            'assets/images/fallbacks/post-fallback.png',
                        retryLimit: 0),
                  )));

    if (onRemove == null) return imagePreview;

    return Stack(
      children: <Widget>[
        imagePreview,
        Positioned(
          top: 10,
          right: 10,
          child: _buildRemoveButton(),
        ),
        isFileImage
            ? Positioned(
                bottom: 10,
                left: 10,
                child: _buildEditButton(context),
              )
            : const SizedBox()
      ],
    );
  }

  Widget _buildRemoveButton() {
    return GestureDetector(
      onTap: onRemove,
      child: SizedBox(
        width: buttonSize,
        height: buttonSize,
        child: FloatingActionButton(
          heroTag: Key('postImagePreviewerRemoveButton'),
          onPressed: onRemove,
          backgroundColor: Colors.black54,
          child: Icon(
            Icons.clear,
            color: Colors.white,
            size: 20.0,
          ),
        ),
      ),
    );
  }

  Widget _buildEditButton(BuildContext context) {
    VoidCallback onWantsToEditImage = () {
      _onWantsToEditImage(context);
    };

    return GestureDetector(
      onTap: onWantsToEditImage,
      child: SizedBox(
        width: buttonSize,
        height: buttonSize,
        child: FloatingActionButton(
          heroTag: Key('postImagePreviewerEditButton'),
          onPressed: onWantsToEditImage,
          backgroundColor: Colors.black54,
          child: Icon(
            Icons.edit,
            color: Colors.white,
            size: 20.0,
          ),
        ),
      ),
    );
  }

  void _onWantsToEditImage(BuildContext context) async {
    if (onWillEditImage != null) onWillEditImage!();

    OpenbookProviderState openbookProvider = OpenbookProvider.of(context);

    File? croppedFile =
        await openbookProvider.mediaService.cropImage(postImageFile!);
    if (croppedFile != null) onPostImageEdited!(croppedFile);
  }
}
