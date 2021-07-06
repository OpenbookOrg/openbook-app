class Share {
  static const String IMAGE = 'image';
  static const String VIDEO = 'video';
  static const String TEXT = 'text';
  static const String ERROR = 'error';

  final String? image;
  final String? video;
  final String? text;
  final String? error;

  const Share({
    this.image,
    this.video,
    this.text,
    this.error
  });

  static Share fromReceived(Map received) {
    late String text;
    late String image;
    late String video;
    late String error;

    if (received.containsKey(TEXT)) {
      text = received[TEXT];
    }
    if (received.containsKey(IMAGE)) {
      image = received[IMAGE];
    }
    if (received.containsKey(VIDEO)) {
      video = received[VIDEO];
    }
    if (received.containsKey(ERROR)) {
      error = received[ERROR];
    }

    return Share(image: image, video: video, text: text, error: error);
  }
}
