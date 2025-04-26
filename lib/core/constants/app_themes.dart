import 'package:flutter/material.dart';
import 'package:taskify/core/constants/app_colors.dart';

ThemeData appLightTheme = ThemeData(
  // ========== Global ==========
  scaffoldBackgroundColor: AppColors.backgroundLight,

  // ========== AppBar Global ==========
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.roseBonbon,
    foregroundColor: Colors.white,
    centerTitle: true,
    elevation: 2,
    titleTextStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
  ),

  // ========== BottomAppBar Global ==========
  bottomAppBarTheme: BottomAppBarTheme(
    color: AppColors.vistaBlue,
    elevation: 8,
    shape: const CircularNotchedRectangle(),
  ),

  // ========== FloatingActionButton ==========
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: AppColors.roseBonbon,
    foregroundColor: Colors.white,
    elevation: 4,
  ),

  // ========== IconButtons (BottomNav) ==========
  iconTheme: IconThemeData(color: Colors.white, size: 28),

  // ========== Inputs (TextField, DropdownMenu) ==========
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: AppColors.argentinianBlue),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: AppColors.argentinianBlue, width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
    filled: true,
    fillColor: AppColors.backgroundLight,
    labelStyle: TextStyle(color: AppColors.textSecondary),
  ),

  // ========== ElevatedButton ==========
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.roseBonbon,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  ),

  // ========== OutlinedButton ==========
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      side: BorderSide(color: AppColors.argentinianBlue),
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  ),

  // ========== TextButton ==========
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: AppColors.argentinianBlue),
  ),

  // ========== DropdownMenu ==========
  dropdownMenuTheme: DropdownMenuThemeData(
    menuStyle: MenuStyle(
      backgroundColor: WidgetStateProperty.all(AppColors.backgroundLight),
      elevation: WidgetStateProperty.all(4),
      side: WidgetStateProperty.all(
        BorderSide(color: AppColors.argentinianBlue),
      ),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 8)),
    ),
  ),
);
