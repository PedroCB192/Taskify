import 'package:flutter/material.dart';
import 'package:taskify/features/profile/models/user.dart';
import 'package:taskify/features/profile/services/user_service.dart';

class UserProvider with ChangeNotifier {
  User? _user; // Modelo de usuario de tu aplicación

  User? get user => _user;

  bool get isPremium => _user?.isPremium ?? false;

  final UserService _userService = UserService();

  Future<void> loadUser() async {
    _user = _userService.getUser(); // Cargar el usuario desde Hive
    notifyListeners();
  }

  Future<void> updateUser(User user) async {
    _user = user; // Actualizar el usuario localmente
    await _userService.saveUser(user); // Guardar en Hive
    notifyListeners();
  }

  Future<void> clearUser() async {
    _user = null; // Limpiar el usuario localmente
    await _userService.deleteUser(); // Eliminar de Hive
    notifyListeners();
  }
}
