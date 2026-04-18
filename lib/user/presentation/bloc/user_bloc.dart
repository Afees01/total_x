import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/user.dart';
import '../../domain/usecases/add_user.dart';
import '../../domain/usecases/get_users.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final AddUser addUser;
  final GetUsers getUsers;

  UserBloc(this.addUser, this.getUsers)
      : super(UserState(users: [], filtered: [])) {

    // LOAD USERS
    on<LoadUsers>((event, emit) async {
      final users = await getUsers();
      emit(state.copyWith(users: users, filtered: users));
    });

    // ADD USER
    on<AddUserEvent>((event, emit) async {
      await addUser(event.user);
      final users = await getUsers();
      emit(state.copyWith(users: users, filtered: users));
    });

    // SEARCH USER
    on<SearchUserEvent>((event, emit) {
      final filtered = state.users.where((u) {
        return u.name.toLowerCase().contains(event.query.toLowerCase()) ||
               u.phone.contains(event.query);
      }).toList();

      emit(state.copyWith(filtered: filtered));
    });

    // SORT USER
    on<SortUserEvent>((event, emit) {
      final sorted = List<User>.from(state.filtered)
        ..sort((a, b) =>
          event.olderFirst
            ? b.age.compareTo(a.age)
            : a.age.compareTo(b.age));

      emit(state.copyWith(filtered: sorted));
    });
  }
}