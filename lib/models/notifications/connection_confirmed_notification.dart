import 'package:Okuna/models/user.dart';

class ConnectionConfirmedNotification {
  final int? id;
  final User? connectionConfirmator;

  ConnectionConfirmedNotification({this.id, this.connectionConfirmator});

  factory ConnectionConfirmedNotification.fromJson(Map<String, dynamic> json) {
    return ConnectionConfirmedNotification(
        id: json['id'],
        connectionConfirmator: _parseUser(json['connection_confirmator']));
  }

  static User _parseUser(Map<String, dynamic> userData) {
    return User.fromJson(userData);
  }
}
