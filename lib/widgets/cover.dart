import 'dart:io';

import 'package:Okuna/provider.dart';
import 'package:Okuna/widgets/theming/text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class OBCover extends StatelessWidget {
  final String? coverUrl;
  final File? coverFile;
  static const double largeSizeHeight = 230.0;
  static const double mediumSizedHeight = 190.0;
  static const double smallSizeHeight = 160.0;
  static const COVER_PLACEHOLDER = 'assets/images/fallbacks/cover-fallback.jpg';
  final OBCoverSize size;
  final bool isZoomable;

  OBCover(
      {this.coverUrl,
      this.coverFile,
      this.size = OBCoverSize.large,
      this.isZoomable = true});

  @override
  Widget build(BuildContext context) {
    Widget image;

    late double coverHeight;

    switch (size) {
      case OBCoverSize.large:
        coverHeight = largeSizeHeight;
        break;
        case OBCoverSize.medium:
        coverHeight = mediumSizedHeight;
        break;
      case OBCoverSize.small:
        coverHeight = smallSizeHeight;
        break;
      default:
        break;
    }

    if (coverFile != null) {
      image = FadeInImage(
        placeholder: AssetImage(COVER_PLACEHOLDER),
        image: FileImage(coverFile!),
        fit: BoxFit.cover,
        height: double.infinity,
        width: double.infinity,
        alignment: Alignment.center,
      );
    } else if (coverUrl == null) {
      image = _getCoverPlaceholder(coverHeight);
    } else {
      image = CachedNetworkImage(
        fit: BoxFit.cover,
        imageUrl: coverUrl ?? '',
        placeholder: (BuildContext context, String url) {
          return const Center(
            child: const CircularProgressIndicator(),
          );
        },
        errorWidget: (BuildContext context, String url, dynamic error) {
          return const SizedBox(
            child: const Center(
              child: const OBText('Could not load cover'),
            ),
          );
        },
        height: double.infinity,
        width: double.infinity,
        alignment: Alignment.center,
      );

      if (isZoomable) {
        image = GestureDetector(
          child: image,
          onTap: () {
            OpenbookProviderState openbookProvider =
                OpenbookProvider.of(context);
            openbookProvider.dialogService
                .showZoomablePhotoBoxView(imageUrl: coverUrl!, context: context);
          },
        );
      }
    }

    return SizedBox(
      height: coverHeight,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Expanded(
            child: SizedBox(
              child: image,
            ),
          )
        ],
      ),
    );
  }

  Widget _getCoverPlaceholder(double coverHeight) {
    return Image.asset(
      COVER_PLACEHOLDER,
      height: coverHeight,
      fit: BoxFit.cover,
    );
  }
}

enum OBCoverSize { large, small , medium}
