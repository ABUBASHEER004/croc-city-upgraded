import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    final scheme = ColorScheme.fromSeed(seedColor: AppColors.primary, brightness: Brightness.light).copyWith(primary: AppColors.primary, secondary: AppColors.secondary, surface: Colors.white);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: GoogleFonts.poppinsTextTheme().apply(bodyColor: AppColors.black, displayColor: AppColors.black),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0, scrolledUnderElevation: 0, backgroundColor: Colors.transparent, foregroundColor: AppColors.black, titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.black)),
      cardTheme: CardThemeData(elevation: 0, color: Colors.white, margin: EdgeInsets.zero, surfaceTintColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22), side: const BorderSide(color: AppColors.border))),
      navigationBarTheme: NavigationBarThemeData(height: 76, elevation: 0, backgroundColor: Colors.white, indicatorColor: AppColors.primary.withOpacity(.10), labelTextStyle: WidgetStateProperty.all(const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)), iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(color: states.contains(WidgetState.selected) ? AppColors.primary : AppColors.muted)),),
      inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: Colors.white, contentPadding: const EdgeInsets.symmetric(horizontal: 17, vertical: 16), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.border)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.border)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primary, width: 1.5))),
      elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 54), backgroundColor: AppColors.primary, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), textStyle: const TextStyle(fontWeight: FontWeight.w800))),
      filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(minimumSize: const Size(0, 52), backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), textStyle: const TextStyle(fontWeight: FontWeight.w800))),
      chipTheme: ChipThemeData(backgroundColor: Colors.white, side: const BorderSide(color: AppColors.border), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), labelStyle: const TextStyle(fontWeight: FontWeight.w700)),
      dividerTheme: const DividerThemeData(color: AppColors.border, space: 1),
    );
  }
  static ThemeData get darkTheme {
    final scheme = ColorScheme.fromSeed(seedColor: AppColors.primary, brightness: Brightness.dark).copyWith(
      primary: AppColors.secondary,
      secondary: AppColors.secondary,
      surface: const Color(0xFF111827),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFF0B1220),
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: const Color(0xFF111827),
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22), side: BorderSide(color: Colors.white12)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 76,
        elevation: 0,
        backgroundColor: const Color(0xFF111827),
        indicatorColor: AppColors.secondary.withOpacity(.14),
        labelTextStyle: WidgetStateProperty.all(const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF111827),
        contentPadding: const EdgeInsets.symmetric(horizontal: 17, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.white12)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.white12)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.secondary, width: 1.5)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 52),
          backgroundColor: AppColors.secondary,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

}
