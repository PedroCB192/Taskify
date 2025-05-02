import 'package:hive/hive.dart';
import 'package:taskify/features/profile/models/user.dart';

class UserService {
  final Box<User> _userBox = Hive.box<User>('userBox');

  // Save user to Hive
  Future<void> saveUser(User user) async {
    await _userBox.put('currentUser', user);
  }

  // Get user from Hive
  User? getUser() {
    return _userBox.get('currentUser');
  }

  // Delete user from Hive
  Future<void> deleteUser() async {
    await _userBox.delete('currentUser');
  }
}
