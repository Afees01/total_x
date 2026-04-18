class User {
  final String name;
  final String phone;
  final int age;
  final String? image; 

  User({
    required this.name,
    required this.phone,
    required this.age,
    this.image,
  });
}