import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:total_x/core/services/otp_services.dart';
import 'package:total_x/user/data/datasources/local_data_source.dart';
import 'package:total_x/user/data/repositories/user_repository_impl.dart';
import 'package:total_x/user/domain/entities/user.dart';
import 'package:total_x/user/domain/usecases/add_user.dart';
import 'package:total_x/user/domain/usecases/get_current_user.dart';
import 'package:total_x/user/domain/usecases/get_users.dart';
import 'package:total_x/user/domain/usecases/set_logged_in.dart';
import 'package:total_x/user/domain/usecases/update_user.dart';
import 'package:total_x/user/presentation/bloc/OTP_bloc/otp_bloc.dart';
import 'package:total_x/user/presentation/bloc/User_bloc/user_event.dart';
import 'package:total_x/user/presentation/bloc/user_bloc.dart';
import 'package:total_x/user/presentation/pages/home_page.dart';
import 'package:total_x/user/presentation/pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(UserAdapter());
  final localDataSource = LocalDataSource();
  await localDataSource.init();
  final repository = UserRepositoryImpl(localDataSource);
  final addUser = AddUser(repository);
  final getUsers = GetUsers(repository);
  final setLoggedIn = SetLoggedIn(repository);
  final getCurrentUser = GetCurrentUser(repository);
  final updateUser = UpdateUser(repository);
  final otpService = OtpService();

  // Check if user is logged in
  final isLoggedIn = await localDataSource.isLoggedIn();

  runApp(MyApp(
    addUser: addUser,
    getUsers: getUsers,
    setLoggedIn: setLoggedIn,
    getCurrentUser: getCurrentUser,
    updateUser: updateUser,
    otpService: otpService,
    isLoggedIn: isLoggedIn,
  ));
}

class MyApp extends StatelessWidget {
  final AddUser addUser;
  final GetUsers getUsers;
  final SetLoggedIn setLoggedIn;
  final GetCurrentUser getCurrentUser;
  final UpdateUser updateUser;
  final OtpService otpService;
  final bool isLoggedIn;

  const MyApp({
    super.key,
    required this.addUser,
    required this.getUsers,
    required this.setLoggedIn,
    required this.getCurrentUser,
    required this.updateUser,
    required this.otpService,
    required this.isLoggedIn,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => UserBloc(
              addUser, getUsers, setLoggedIn, getCurrentUser, updateUser)
            ..add(LoadUsers()),
        ),
        BlocProvider(
          create: (_) => OtpBloc(otpService),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Total X',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: isLoggedIn ? HomePage() : const LoginPage(),
      ),
    );
  }
}
