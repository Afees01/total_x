import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:total_x/core/services/otp_services.dart';
import 'package:total_x/user/data/datasources/local_data_source.dart';
import 'package:total_x/user/data/repositories/user_repository_impl.dart';
import 'package:total_x/user/domain/usecases/add_user.dart';
import 'package:total_x/user/domain/usecases/get_users.dart';
import 'package:total_x/user/presentation/bloc/OTP_bloc/otp_bloc.dart';
import 'package:total_x/user/presentation/bloc/User_bloc/user_event.dart';
import 'package:total_x/user/presentation/bloc/user_bloc.dart';
import 'package:total_x/user/presentation/pages/login_page.dart';

void main() {
  final localDataSource = LocalDataSource();
  final repository = UserRepositoryImpl(localDataSource);
  final addUser = AddUser(repository);
  final getUsers = GetUsers(repository);
  final otpService = OtpService();

  runApp(MyApp(
    addUser: addUser,
    getUsers: getUsers,
    otpService: otpService,
  ));
}

class MyApp extends StatelessWidget {
  final AddUser addUser;
  final GetUsers getUsers;
  final OtpService otpService;

  const MyApp({
    super.key,
    required this.addUser,
    required this.getUsers,
    required this.otpService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => UserBloc(addUser, getUsers)..add(LoadUsers()),
        ),
        BlocProvider(
          create: (_) => OtpBloc(otpService),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: LoginPage(),
      ),
    );
  }
}
