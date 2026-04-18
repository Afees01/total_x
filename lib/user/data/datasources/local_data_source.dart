import '../models/user_model.dart';

class LocalDataSource {
  final List<UserModel> _users = [];

  Future<void> addUser(UserModel user) async {
    _users.add(user);
  }

  Future<List<UserModel>> getUsers() async {
    return _users;
  }
}