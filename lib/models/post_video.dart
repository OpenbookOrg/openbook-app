import 'package:Okuna/models/video_format.dart';
import 'package:Okuna/models/video_formats_list.dart';

class PostVideo {
  final int? id;
  final double? width;
  final double? height;
  final double? duration;
  final String? file;
  final String? thumbnail;
  final double? thumbnailHeight;
  final double? thumbnailWidth;
  final OBVideoFormatsList? formatSet;

  const PostVideo({
    this.id,
    this.width,
    this.height,
    this.duration,
    this.file,
    this.formatSet,
    this.thumbnail,
    this.thumbnailHeight,
    this.thumbnailWidth,
  });

  OBVideoFormat? getVideoFormatOfType(OBVideoFormatType type) {
    return formatSet?.videoFormats?.firstWhere((OBVideoFormat format) {
      return format.type == type;
    });
  }

  factory PostVideo.fromJSON(Map<String, dynamic> parsedJson) {
    return PostVideo(
      width: parsedJson['width']?.toDouble(),
      height: parsedJson['height']?.toDouble(),
      duration: parsedJson['duration'],
      file: parsedJson['file'],
      formatSet: parseFormatSet(parsedJson['format_set']),
      thumbnail: parsedJson['thumbnail'],
      thumbnailHeight: parsedJson['thumbnail_height']?.toDouble(),
      thumbnailWidth: parsedJson['thumbnail_width']?.toDouble(),
    );
  }

  static OBVideoFormatsList parseFormatSet(List rawData) {
    return OBVideoFormatsList.fromJson(rawData);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'width': width,
      'height': height,
      'thumbnail': thumbnail,
      'duration': duration,
      'file': file,
      'thumbnail_height': thumbnailHeight,
      'thumbnail_width': thumbnailWidth,
      'format_set': formatSet?.videoFormats?.map((OBVideoFormat format) => format.toJson()).toList()
    };
  }
}
