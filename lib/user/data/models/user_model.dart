import '../../domain/entities/user.dart';

class UserModel extends User {
  UserModel({
    required super.name,
    required super.phone,
    required super.age,
  });

  factory UserModel.fromUser(User user) {
    return UserModel(
      name: user.name,
      phone: user.phone,
      age: user.age,
    );
  }
}