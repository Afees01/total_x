import 'package:total_x/user/domain/entities/user.dart';
import 'package:total_x/user/domain/repositories/user_repository.dart';

class AddUser {
  final UserRepository repository;

  AddUser(this.repository);

  Future<void> call(User user) async {
    await repository.addUser(user);
  }
}