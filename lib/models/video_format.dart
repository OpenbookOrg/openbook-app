class OBVideoFormat {
  final int? id;
  final double? progress;
  final double? duration;
  final String? format;
  final String? file;

  OBVideoFormatType? type;

  OBVideoFormat(
      {this.id, this.progress, this.duration, this.format, this.file}) {
    type = OBVideoFormatType.parse(format);
  }

  factory OBVideoFormat.fromJSON(Map<String, dynamic> json) {
    return OBVideoFormat(
      id: json['int'],
      progress: json['progress']?.toDouble(),
      duration: json['duration']?.toDouble(),
      format: json['format'],
      file: json['file'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'progress': progress,
      'duration': duration,
      'format': format,
      'file': file
    };
  }
}

class OBVideoFormatType {
  final String code;

  const OBVideoFormatType._internal(this.code);

  toString() => code;

  static const mp4SD = const OBVideoFormatType._internal('mp4_sd');
  static const webmSD = const OBVideoFormatType._internal('webm_sd');

  static const _values = const <OBVideoFormatType>[
    mp4SD,
    webmSD,
  ];

  static values() => _values;

  static OBVideoFormatType? parse(String? string) {
    if (string == null) return null;

    OBVideoFormatType? videoFormatType;
    for (var type in _values) {
      if (string == type.code) {
        videoFormatType = type;
        break;
      }
    }

    if (videoFormatType == null) {
      // Don't throw as we might introduce new medias on the API which might not be yet in code
      print('Unsupported video format type');
    }

    return videoFormatType;
  }
}
