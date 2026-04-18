import 'package:total_x/user/domain/entities/user.dart';

abstract class UserRepository {
  Future<void> addUser(User user);
  Future<List<User>> getUsers();
}