import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  static const Color primaryBlue = Color(0xFF1877F2);
  static const Color lightBlue = Color(0xFFE7F3FF);
  static const Color bgGrey = Color(0xFFF0F2F5);
  static const Color lightGrey = Color(0xFFE1E2E4);
  static const Color borderColor = Color(0xFFDDDFE2);
  static const Color textDark = Color(0xFF050505);
  static const Color textGrey = Color(0xFF65676B);
  static const Color white = Colors.white;
  static const Color reactionLike = Color(0xFF1877F2);
  static const Color reactionLove = Color(0xFFE0245E);
  static const Color reactionHaha = Color(0xFFF7B125);
  static const Color reactionWow = Color(0xFFF7B125);
  static const Color reactionSad = Color(0xFFF7B125);
  static const Color reactionAngry = Color(0xFFE9710F);

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryBlue,
          primary: primaryBlue,
          surface: white,
          surfaceContainerHighest: bgGrey,
        ),
        scaffoldBackgroundColor: bgGrey,
        appBarTheme: const AppBarTheme(
          backgroundColor: white,
          elevation: 0,
          scrolledUnderElevation: 0.5,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          titleTextStyle: TextStyle(
              color: textDark,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              fontFamily: 'Roboto'),
          iconTheme: IconThemeData(color: textDark),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryBlue,
            foregroundColor: white,
            minimumSize: const Size(double.infinity, 48),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            textStyle:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            elevation: 0,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primaryBlue,
            minimumSize: const Size(double.infinity, 48),
            side: const BorderSide(color: borderColor),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            textStyle:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: bgGrey,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: const BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: const BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: const BorderSide(color: primaryBlue, width: 1.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        cardTheme: CardThemeData(
          color: white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
          margin: EdgeInsets.zero,
        ),
        dividerTheme: const DividerThemeData(
            color: borderColor, thickness: 0.5, space: 0),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: white,
          indicatorColor: Colors.transparent,
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                  fontSize: 11,
                  color: primaryBlue,
                  fontWeight: FontWeight.w600);
            }
            return const TextStyle(fontSize: 11, color: textGrey);
          }),
        ),
      );
}
