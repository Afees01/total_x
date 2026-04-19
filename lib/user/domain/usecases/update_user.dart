import 'package:total_x/user/domain/entities/user.dart';
import 'package:total_x/user/domain/repositories/user_repository.dart';

class UpdateUser {
  final UserRepository repository;

  UpdateUser(this.repository);

  Future<void> call(User user) async {
    await repository.updateUser(user);
  }
}
