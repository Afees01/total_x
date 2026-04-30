import 'package:total_x/user/domain/repositories/user_repository.dart';

class SetLoggedIn {
  final UserRepository repository;

  SetLoggedIn(this.repository);

  Future<void> call(bool value, {String? phone}) async {
    await repository.setLoggedIn(value, phone: phone);
  }
}
