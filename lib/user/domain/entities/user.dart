import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 0)
class User {
  @HiveField(0)
  final String name;
  @HiveField(1)
  final String phone;
  @HiveField(2)
  final int age;
  @HiveField(3)
  final String? image;

  User({
    required this.name,
    required this.phone,
    required this.age,
    this.image,
  });
}
