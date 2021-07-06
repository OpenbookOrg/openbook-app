import 'package:Okuna/models/post_image.dart';
import 'package:Okuna/models/post_video.dart';
import 'package:flutter/cupertino.dart';

class PostMedia {
  final int? id;
  final PostMediaType? type;
  final dynamic contentObject;
  final int? order;

  PostMedia({this.id, this.type, this.contentObject, this.order});

  factory PostMedia.fromJSON(Map<String, dynamic> json) {
    PostMediaType? type = PostMediaType.parse(json['type']);

    return PostMedia(
        id: json['id'],
        type: type,
        order: json['oder'],
        contentObject: parseContentObject(
            contentObjectData: json['content_object'], type: type));
  }

  Map<String, dynamic> toJson() {
    return {
       'id': id,
      'type': type?.code,
      'content_object': contentObject?.toJson(),
      'order': order
    };
  }

  static dynamic parseContentObject(
      {required Map<String, dynamic>? contentObjectData, required PostMediaType? type}) {
    if (contentObjectData == null) return null;

    dynamic contentObject;
    switch (type) {
      case PostMediaType.image:
        contentObject =
            PostImage.fromJSON(contentObjectData);
        break;
      case PostMediaType.video:
        contentObject = PostVideo.fromJSON(contentObjectData);
        break;
      default:
    }
    return contentObject;
  }
}

class PostMediaType {
  final String code;

  const PostMediaType._internal(this.code);

  toString() => code;

  static const video = const PostMediaType._internal('V');
  static const image = const PostMediaType._internal('I');

  static const _values = const <PostMediaType>[
    video,
    image,
  ];

  static values() => _values;

  static PostMediaType? parse(String? string) {
    if (string == null) return null;

    PostMediaType? postMediaType;
    for (var type in _values) {
      if (string == type.code) {
        postMediaType = type;
        break;
      }
    }

    if (postMediaType == null) {
      // Don't throw as we might introduce new medias on the API which might not be yet in code
      print('Unsupported post media type');
    }

    return postMediaType;
  }
}
