import 'package:flutter/material.dart';
import 'package:taskify/features/profile/models/user.dart';
import 'package:taskify/features/profile/services/user_service.dart';

class UserProvider with ChangeNotifier {
  User? _user; // User object to hold user data

  User? get user => _user;

  bool get isPremium => _user?.isPremium ?? false;

  final UserService _userService = UserService();

  Future<void> loadUser() async {
    _user = _userService.getUser(); // Upload user from Hive
    notifyListeners();
  }

  Future<void> updateUser(User user) async {
    _user = user; // Update user locally
    await _userService.saveUser(user); // Save user to Hive
    notifyListeners();
  }

  Future<void> clearUser() async {
    _user = null; // Clear user locally
    await _userService.deleteUser(); // Delete user from Hive
    notifyListeners();
  }
}
