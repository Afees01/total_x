import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:total_x/user/presentation/bloc/User_bloc/user_event.dart';
import 'package:total_x/user/presentation/bloc/User_bloc/user_state.dart';

import '../../domain/entities/user.dart';
import '../../domain/usecases/add_user.dart';
import '../../domain/usecases/get_users.dart';
import '../../domain/usecases/set_logged_in.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/update_user.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final AddUser addUser;
  final GetUsers getUsers;
  final SetLoggedIn setLoggedIn;
  final GetCurrentUser getCurrentUser;
  final UpdateUser updateUser;

  UserBloc(this.addUser, this.getUsers, this.setLoggedIn, this.getCurrentUser,
      this.updateUser)
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

    // UPDATE USER
    on<UpdateUserEvent>((event, emit) async {
      await updateUser(event.user);
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
            event.olderFirst ? b.age.compareTo(a.age) : a.age.compareTo(b.age));

      emit(state.copyWith(filtered: sorted));
    });

    // LOGIN
    on<LoginEvent>((event, emit) async {
      final user = User(
        name: '',
        phone: event.phone,
        age: 0,
      );
      await addUser(user);
      await setLoggedIn(true, phone: event.phone);
      final users = await getUsers();
      emit(state.copyWith(users: users, filtered: users));
    });
  }
}
