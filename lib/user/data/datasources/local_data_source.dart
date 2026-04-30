import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class LocalDataSource {
  static const String _userBoxName = 'users';
  static const String _loginKey = 'isLoggedIn';
  static const String _currentUserPhoneKey = 'currentUserPhone';

  late Box<UserModel> _userBox;
  late SharedPreferences _prefs;

  Future<void> init() async {
    try {
      _userBox = await Hive.openBox<UserModel>(_userBoxName);
      _prefs = await SharedPreferences.getInstance();
    } catch (e) {
      throw Exception('Failed to initialize local storage: $e');
    }
  }

  Future<void> addUser(UserModel user) async {
    try {
      await _userBox.add(user);
    } catch (e) {
      throw Exception('Failed to save user: $e');
    }
  }

  Future<List<UserModel>> getUsers() async {
    try {
      return _userBox.values.toList();
    } catch (e) {
      throw Exception('Failed to load users: $e');
    }
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      final currentPhone = await getCurrentUserPhone();
      if (currentPhone == null) return null;

      final users = _userBox.values.toList();
      try {
        return users.firstWhere(
          (user) => user.phone == currentPhone,
        );
      } catch (e) {
        return null; // User not found
      }
    } catch (e) {
      throw Exception('Failed to get current user: $e');
    }
  }

  Future<void> setLoggedIn(bool value, {String? phone}) async {
    try {
      await _prefs.setBool(_loginKey, value);
      if (value && phone != null) {
        await _prefs.setString(_currentUserPhoneKey, phone);
      } else if (!value) {
        await _prefs.remove(_currentUserPhoneKey);
      }
    } catch (e) {
      throw Exception('Failed to update login state: $e');
    }
  }

  Future<bool> isLoggedIn() async {
    try {
      return _prefs.getBool(_loginKey) ?? false;
    } catch (e) {
      return false; // Default to not logged in on error
    }
  }

  Future<String?> getCurrentUserPhone() async {
    try {
      return _prefs.getString(_currentUserPhoneKey);
    } catch (e) {
      return null;
    }
  }

  Future<void> updateUser(UserModel user) async {
    try {
      // Find and update the user with matching phone number
      final users = _userBox.values.toList();
      final existingIndex = users.indexWhere((u) => u.phone == user.phone);

      if (existingIndex != -1) {
        await _userBox.putAt(existingIndex, user);
      } else {
        // If user doesn't exist, add them
        await _userBox.add(user);
      }
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }
}
