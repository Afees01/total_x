import '../../domain/entities/user.dart';

class UserState {
  final List<User> users;
  final List<User> filtered;

  UserState({
    required this.users,
    required this.filtered,
  });

  UserState copyWith({
    List<User>? users,
    List<User>? filtered,
  }) {
    return UserState(
      users: users ?? this.users,
      filtered: filtered ?? this.filtered,
    );
  }
}