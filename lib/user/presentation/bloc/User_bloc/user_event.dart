import 'package:total_x/user/domain/entities/user.dart';

abstract class UserEvent {}

class LoadUsers extends UserEvent {}

class AddUserEvent extends UserEvent {
  final User user;
  AddUserEvent(this.user);
}

class UpdateUserEvent extends UserEvent {
  final User user;
  UpdateUserEvent(this.user);
}

class SearchUserEvent extends UserEvent {
  final String query;
  SearchUserEvent(this.query);
}

class SortUserEvent extends UserEvent {
  final bool olderFirst;
  SortUserEvent(this.olderFirst);
}

class LoginEvent extends UserEvent {
  final String phone;
  LoginEvent(this.phone);
}
