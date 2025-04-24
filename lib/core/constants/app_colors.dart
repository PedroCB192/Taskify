import 'dart:ui';

import 'package:flutter/material.dart';

class AppColors {
  // Colores base
  static const Color roseBonbon = Color(0xFFff499e); // Botones primarios, logo
  static const Color skyMagenta = Color(0xFFd264b6); // Tareas completadas, acentos
  static const Color lavenderFloral = Color(0xFFa480cf); // Botones secundarios, bordes
  static const Color vistaBlue = Color(0xFF779be7); // Prioridad media, íconos
  static const Color argentinianBlue = Color(0xFF49b6ff); // AppBar, fondos, links

  // Colores para texto
  static const Color textPrimary = Colors.black; // Títulos
  static const Color textSecondary = Color(0xFF616161); // Subtítulos
  static const Color textHint = Color(0xFF9E9E9E); // Placeholders

  // Fondos
  static const Color backgroundLight = Colors.white;
  static const Color backgroundDark = Color(0xFF121212); // Para modo oscuro

  // Componentes específicos (opcionales)
  static const Color appBarBackground = argentinianBlue;
  static const Color floatingActionButton = roseBonbon;
  static const Color cardBorder = vistaBlue;
}