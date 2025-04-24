import 'package:flutter/material.dart';
import 'package:taskify/core/constants/app_colors.dart';

ThemeData appLightTheme = ThemeData(
  // Color de fondo global
  scaffoldBackgroundColor: AppColors.backgroundLight,

  // Estilo de TextFields
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: AppColors.lavenderFloral),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: AppColors.argentinianBlue),
    ),
    labelStyle: TextStyle(color: AppColors.textSecondary),
  ),

  // Estilo de botones elevados (ElevatedButton)
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.roseBonbon,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  ),

  // Estilo de botones con borde (OutlinedButton)
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      side: BorderSide(color: AppColors.argentinianBlue),
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  ),

  // Texto de botones
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.argentinianBlue,
    ),
  ),
);