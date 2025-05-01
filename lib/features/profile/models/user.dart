import 'package:hive/hive.dart';

part 'user.g.dart'; // Generado automáticamente por Hive

@HiveType(typeId: 3) // Asigna un ID único para el adaptador
class User {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final bool isPremium;

  User({required this.id, required this.name, required this.isPremium});
}
