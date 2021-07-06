
class PostLink {
  final int? id;
  String? link;
  bool? hasPreview;

  PostLink({
    this.id,
    this.link,
    this.hasPreview,
  });

  factory PostLink.fromJSON(Map<String, dynamic> json) {
    return PostLink(
      id: json['id'],
      link: json['link'],
      hasPreview: json['has_preview'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'link': link,
      'has_preview': hasPreview,
    };
  }
}
