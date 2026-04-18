import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:total_x/user/data/datasources/local_data_source.dart';
import 'package:total_x/user/data/repositories/user_repository_impl.dart';
import 'package:total_x/user/domain/usecases/add_user.dart';
import 'package:total_x/user/domain/usecases/get_users.dart';
import 'package:total_x/user/presentation/bloc/user_bloc.dart';
import 'package:total_x/user/presentation/bloc/user_event.dart';
import 'package:total_x/user/presentation/pages/home_page.dart';
import 'package:total_x/user/presentation/pages/login_page.dart';

void main() {
  final localDataSource = LocalDataSource();
  final repository = UserRepositoryImpl(localDataSource);
  final addUser = AddUser(repository);
  final getUsers = GetUsers(repository);

  runApp(MyApp(
    addUser: addUser,
    getUsers: getUsers,
  ));
}

class MyApp extends StatelessWidget {
  final AddUser addUser;
  final GetUsers getUsers;

  const MyApp({
    super.key,
    required this.addUser,
    required this.getUsers,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UserBloc(addUser, getUsers)..add(LoadUsers()),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: LoginPage(),
      ),
    );
  }
}
