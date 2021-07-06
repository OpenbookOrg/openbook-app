class Emoji {
  final String? keyword;
  final int? id;
  final int? order;
  final DateTime? created;
  final String? color;
  final String? image;

  Emoji(
      {this.keyword,
      this.id,
      this.order,
      this.created,
      this.color,
      this.image});

  factory Emoji.fromJson(Map<String, dynamic> parsedJson) {
    DateTime? created;
    if (parsedJson['created'] != null) {
      created = DateTime.parse(parsedJson['created']).toLocal();
    }

    return Emoji(
        id: parsedJson['id'],
        keyword: parsedJson['keyword'],
        image: parsedJson['image'],
        created: created,
        order: parsedJson['order'],
        color: parsedJson['color']);
  }

  Map<String, dynamic> toJson() {
    return {
      'keyword': keyword,
      'id': id,
      'order': order,
      'created': created,
      'color': color,
      'image': image
    };
  }
}
