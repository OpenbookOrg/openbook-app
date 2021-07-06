class PostImage {
  final String? image;
  final double? width;
  final double? height;
  final String? thumbnail;

  PostImage({
    this.image,
    this.width,
    this.height,
    this.thumbnail,
  });

  factory PostImage.fromJSON(Map<String, dynamic> parsedJson) {
    return PostImage(
        image: parsedJson['image'],
        thumbnail: parsedJson['thumbnail'],
        width: parsedJson['width']?.toDouble(),
        height: parsedJson['height']?.toDouble());
  }

  Map<String, dynamic> toJson() {
    return {
      'image': image,
      'width': width,
      'height': height,
      'thumbnail': thumbnail
    };
  }
}
