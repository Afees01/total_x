import 'package:total_x/user/domain/entities/user.dart';

abstract class UserRepository {
  Future<void> addUser(User user);
  Future<List<User>> getUsers();
  Future<void> setLoggedIn(bool value, {String? phone});
  Future<bool> isLoggedIn();
  Future<User?> getCurrentUser();
  Future<void> updateUser(User user);
}
