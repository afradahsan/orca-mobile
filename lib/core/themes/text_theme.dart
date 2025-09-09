import 'package:flutter/material.dart';
import 'package:orca/core/utils/colors.dart';
import 'package:sizer/sizer.dart';

class KTextTheme {
  KTextTheme._();

  static TextTheme dottedDark = TextTheme(
    headlineLarge: const TextStyle().copyWith(
        fontSize: 32.sp, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Doto'),
    headlineMedium: const TextStyle().copyWith(
        fontSize: 28.sp, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Doto'),
    headlineSmall: const TextStyle().copyWith(
        fontSize: 24.sp, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Doto'),
    titleLarge: const TextStyle().copyWith(
        fontSize: 22.sp, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Doto'),
    titleMedium: const TextStyle().copyWith(
        fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Doto'),
    titleSmall: const TextStyle().copyWith(
        fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Doto'),
    bodyLarge: const TextStyle().copyWith(
        fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Doto'),
    bodyMedium: const TextStyle().copyWith(
        fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.white, fontFamily: 'Doto'),
    bodySmall: const TextStyle().copyWith(
        fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Doto'),
    labelLarge: const TextStyle().copyWith(
        fontSize: 12.sp, fontWeight: FontWeight.w500, color: Colors.white, fontFamily: 'Doto'),
    labelMedium: const TextStyle().copyWith(
        fontSize: 12.sp, fontWeight: FontWeight.normal, color: Colors.white, fontFamily: 'Doto'),
  );

  static TextTheme lightTextTheme = TextTheme(
    headlineLarge: const TextStyle().copyWith(
        fontSize: 32.sp, fontWeight: FontWeight.bold, color: darkgreen ),
    headlineMedium: const TextStyle().copyWith(
        fontSize: 24.sp, fontWeight: FontWeight.bold, color: darkgreen),
    headlineSmall: const TextStyle().copyWith(
        fontSize: 24.sp, fontWeight: FontWeight.bold, color: darkgreen),
    titleLarge: const TextStyle().copyWith(
        fontSize: 24.sp, fontWeight: FontWeight.bold, color: darkgreen),
    titleMedium: const TextStyle().copyWith(
        fontSize: 20.sp, fontWeight: FontWeight.bold, color: darkgreen),
    titleSmall: const TextStyle().copyWith(
        fontSize: 18.sp, fontWeight: FontWeight.bold, color: darkgreen),
    bodyLarge: const TextStyle().copyWith(
        fontSize: 16.sp, fontWeight: FontWeight.bold, color: darkgreen),
    bodyMedium: const TextStyle().copyWith(
        fontSize: 16.sp, fontWeight: FontWeight.w600, color: darkgreen),
    bodySmall: const TextStyle().copyWith(
        fontSize: 14.sp, fontWeight: FontWeight.w600, color: darkgreen),
    labelLarge: const TextStyle().copyWith(
        fontSize: 12.sp, fontWeight: FontWeight.w500, color: darkgreen),
    labelMedium: const TextStyle().copyWith(
        fontSize: 12.sp, fontWeight: FontWeight.normal, color: darkgreen),
  );

  static TextTheme darkTextTheme = TextTheme(
    headlineLarge: const TextStyle().copyWith(
        fontSize: 32.sp, fontWeight: FontWeight.bold, color: white),
    headlineMedium: const TextStyle().copyWith(
        fontSize: 24.sp, fontWeight: FontWeight.bold, color: white),
    headlineSmall: const TextStyle().copyWith(
        fontSize: 24.sp, fontWeight: FontWeight.bold, color: white),
    titleLarge: const TextStyle().copyWith(
        fontSize: 20.sp, fontWeight: FontWeight.bold, color: green),
    titleMedium: const TextStyle().copyWith(
        fontSize: 18.sp, fontWeight: FontWeight.w600, color: green),
    titleSmall: const TextStyle().copyWith(
        fontSize: 18.sp, fontWeight: FontWeight.w600, color: green),
    bodyLarge: const TextStyle().copyWith(
        fontSize: 16.sp, fontWeight: FontWeight.w600, color: green),
    bodyMedium: const TextStyle().copyWith(
        fontSize: 16.sp, fontWeight: FontWeight.w600, color: green),
    bodySmall: const TextStyle().copyWith(
        fontSize: 14.sp, fontWeight: FontWeight.w600, color: green),
    labelLarge: const TextStyle().copyWith(
        fontSize: 12.sp, fontWeight: FontWeight.w600, color: white),
    labelMedium: const TextStyle().copyWith(
        fontSize: 12.sp, fontWeight: FontWeight.normal, color: white),
  );
}
