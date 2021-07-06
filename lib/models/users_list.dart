import 'package:Okuna/models/user.dart';

class UsersList {
  final List<User>? users;

  UsersList({
    this.users,
  });

  factory UsersList.fromJson(List<dynamic> parsedJson, {storeInMaxSessionCache = false}) {
    List<User> users =
        parsedJson.map((userJson) => User.fromJson(userJson, storeInMaxSessionCache: storeInMaxSessionCache)).toList();

    return new UsersList(
      users: users,
    );
  }
}
