import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/local_data_source.dart';
import '../models/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  final LocalDataSource local;

  UserRepositoryImpl(this.local);

  @override
  Future<void> addUser(User user) async {
    final model = UserModel.fromUser(user);
    await local.addUser(model);
  }

  @override
  Future<List<User>> getUsers() async {
    return await local.getUsers();
  }
}