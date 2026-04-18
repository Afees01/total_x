import '../../domain/entities/user.dart';

abstract class UserEvent {}

class LoadUsers extends UserEvent {}

class AddUserEvent extends UserEvent {
  final User user;
  AddUserEvent(this.user);
}

class SearchUserEvent extends UserEvent {
  final String query;
  SearchUserEvent(this.query);
}

class SortUserEvent extends UserEvent {
  final bool olderFirst;
  SortUserEvent(this.olderFirst);
}