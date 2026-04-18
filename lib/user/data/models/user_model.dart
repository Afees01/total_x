import 'package:total_x/user/domain/entities/user.dart';

class UserModel extends User {
  UserModel({
    required super.name,
    required super.phone,
    required super.age,
    super.image,
  });

  factory UserModel.fromUser(User user) {
    return UserModel(
      name: user.name,
      phone: user.phone,
      age: user.age,
      image: user.image,
    );
  }
}