
import 'link_preview_image.dart';

class LinkPreview {
  String? url;
  String? domain;
  DateTime? lastUpdated;
  DateTime? nextUpdate;
  String? contentType;
  String? mimeType;
  bool? redirected;
  String? redirectionUrl;
  List<String>? redirectionTrail;
  String? title;
  String? description;
  String? name;
  bool? trackersDetected;
  LinkPreviewImage? icon;
  LinkPreviewImage? image;

  LinkPreview({
    this.url,
    this.domain,
    this.lastUpdated,
    this.nextUpdate,
    this.contentType,
    this.mimeType,
    this.redirected,
    this.redirectionUrl,
    this.redirectionTrail,
    this.title,
    this.description,
    this.name,
    this.trackersDetected,
    this.icon,
    this.image,
  });

  factory LinkPreview.fromJSON(Map<String, dynamic> json) {
    return LinkPreview(
      url: json['url'],
      domain: json['domain'],
      lastUpdated: parseDate(json['lastUpdated']),
      nextUpdate: parseDate(json['nextUpdate']),
      contentType: json['contentType'],
      mimeType: json['mimeType'],
      redirected: json['redirected'],
      redirectionUrl: json['redirectionUrl'],
      redirectionTrail: json['redirectionTrail']?.cast<String>(),
      title: json['title'],
      description: json['description'],
      name: json['name'],
      trackersDetected: json['trackersDetected'],
      icon: parsePreviewImage(json['icon']),
      image: parsePreviewImage(json['image']),
    );
  }

  static LinkPreviewImage? parsePreviewImage(Map<String, dynamic>? previewImageData) {
    if (previewImageData == null) return null;
    return LinkPreviewImage.fromJson(previewImageData);
  }

  static DateTime? parseDate(String? created) {
    if (created == null) return null;
    return DateTime.parse(created).toLocal();
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'domain': domain,
      'lastUpdated': lastUpdated.toString(),
      'nextUpdate': nextUpdate.toString(),
      'contentType': contentType,
      'mimeType': mimeType,
      'redirected': redirected,
      'redirectionUrl': redirectionUrl,
      'redirectionTrail': redirectionTrail,
      'title': title,
      'description': description,
      'name': name,
      'trackersDetected': trackersDetected,
      'icon': icon,
      'image': image,
    };
  }
}
