import 'package:hive/hive.dart';
import 'package:taskify/features/profile/models/user.dart';

class UserService {
  final Box<User> _userBox = Hive.box<User>('userBox');

  // Guardar el usuario en Hive
  Future<void> saveUser(User user) async {
    await _userBox.put('currentUser', user);
  }

  // Obtener el usuario desde Hive
  User? getUser() {
    return _userBox.get('currentUser');
  }

  // Eliminar el usuario de Hive (por ejemplo, al cerrar sesión)
  Future<void> deleteUser() async {
    await _userBox.delete('currentUser');
  }
}
