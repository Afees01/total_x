// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:total_x/core/services/otp_services.dart';
import 'package:total_x/main.dart';
import 'package:total_x/user/domain/usecases/add_user.dart';
import 'package:total_x/user/domain/usecases/get_current_user.dart';
import 'package:total_x/user/domain/usecases/get_users.dart';
import 'package:total_x/user/domain/usecases/set_logged_in.dart';
import 'package:total_x/user/domain/usecases/update_user.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Create dummy use cases (since this is just a smoke test)
    final dummyAddUser = AddUser(null as dynamic); // Dummy
    final dummyGetUsers = GetUsers(null as dynamic);
    final dummySetLoggedIn = SetLoggedIn(null as dynamic);
    final dummyGetCurrentUser = GetCurrentUser(null as dynamic);
    final dummyUpdateUser = UpdateUser(null as dynamic);
    final dummyOtpService = OtpService();

    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(
      addUser: dummyAddUser,
      getUsers: dummyGetUsers,
      setLoggedIn: dummySetLoggedIn,
      getCurrentUser: dummyGetCurrentUser,
      updateUser: dummyUpdateUser,
      otpService: dummyOtpService,
      isLoggedIn: false,
    ));

    // Just verify the app builds without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
