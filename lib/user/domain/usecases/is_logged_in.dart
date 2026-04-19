import 'package:total_x/user/domain/repositories/user_repository.dart';

class IsLoggedIn {
  final UserRepository repository;

  IsLoggedIn(this.repository);

  Future<bool> call() async {
    return await repository.isLoggedIn();
  }
}
