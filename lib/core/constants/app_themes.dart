import 'package:flutter/material.dart';
import 'package:taskify/core/constants/app_colors.dart';
import 'package:table_calendar/table_calendar.dart';

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
    shadowColor: Colors.black,
    scrolledUnderElevation: 15,
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

  // ========== NavigationRail ==========
  navigationRailTheme: NavigationRailThemeData(
    backgroundColor: AppColors.vistaBlue,
    elevation: 8,
    selectedIconTheme: IconThemeData(color: Colors.white),
    unselectedIconTheme: IconThemeData(color: Colors.white.withOpacity(0.6)),
    selectedLabelTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),
    unselectedLabelTextStyle: TextStyle(
      color: Colors.white.withOpacity(0.6),
      fontSize: 14,
      fontWeight: FontWeight.w400,
    ),
    indicatorColor: Colors.transparent,
  ),

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

CalendarStyle customCalendarStyle = CalendarStyle(
  todayDecoration: BoxDecoration(
    color: AppColors.roseBonbon,
    shape: BoxShape.circle,
  ),
  selectedDecoration: BoxDecoration(
    color: AppColors.argentinianBlue,
    shape: BoxShape.circle,
  ),
  weekendTextStyle: const TextStyle(color: AppColors.skyMagenta),
  defaultTextStyle: const TextStyle(color: AppColors.textPrimary),
  outsideTextStyle: const TextStyle(color: AppColors.textHint),
  disabledTextStyle: const TextStyle(color: AppColors.textHint),
  holidayTextStyle: const TextStyle(color: AppColors.lavenderFloral),
  markerDecoration: BoxDecoration(
    color: AppColors.skyMagenta,
    shape: BoxShape.circle,
  ),
);

HeaderStyle customHeaderStyle = HeaderStyle(
  formatButtonVisible: false,
  titleCentered: true,
  titleTextStyle: const TextStyle(
    color: AppColors.textPrimary,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  ),
  leftChevronIcon: const Icon(
    Icons.chevron_left,
    color: AppColors.argentinianBlue,
  ),
  rightChevronIcon: const Icon(
    Icons.chevron_right,
    color: AppColors.argentinianBlue,
  ),
);

DaysOfWeekStyle customDaysOfWeekStyle = DaysOfWeekStyle(
  weekdayStyle: const TextStyle(color: AppColors.textSecondary),
  weekendStyle: const TextStyle(color: AppColors.skyMagenta),
);
