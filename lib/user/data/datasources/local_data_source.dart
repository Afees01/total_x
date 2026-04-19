import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class LocalDataSource {
  static const String _userBoxName = 'users';
  static const String _loginKey = 'isLoggedIn';

  late Box<UserModel> _userBox;
  late SharedPreferences _prefs;

  Future<void> init() async {
    _userBox = await Hive.openBox<UserModel>(_userBoxName);
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> addUser(UserModel user) async {
    await _userBox.add(user);
  }

  Future<List<UserModel>> getUsers() async {
    return _userBox.values.toList();
  }

  Future<UserModel?> getCurrentUser() async {
    final users = await getUsers();
    return users.isNotEmpty
        ? users.last
        : null; // Assuming last added is current
  }

  Future<void> setLoggedIn(bool value) async {
    await _prefs.setBool(_loginKey, value);
  }

  Future<bool> isLoggedIn() async {
    return _prefs.getBool(_loginKey) ?? false;
  }

  Future<void> updateUser(UserModel user) async {
    // For simplicity, clear and add, assuming one user
    await _userBox.clear();
    await _userBox.add(user);
  }
}
