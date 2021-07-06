import 'package:Okuna/models/circle.dart';

class CirclesList {
  final List<Circle>? circles;

  CirclesList({
    this.circles,
  });

  factory CirclesList.fromJson(List<dynamic> parsedJson) {
    List<Circle> circles =
        parsedJson.map((circleJson) => Circle.fromJSON(circleJson)).toList();

    return new CirclesList(
      circles: circles,
    );
  }
}
