import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:orca/core/themes/text_theme.dart';
import 'package:orca/core/utils/colors.dart';
import 'package:orca/features/auth/presentation/splash.dart';
import 'package:sizer/sizer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) => MaterialApp(
        title: 'ORCA',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          primaryColor: darkgreen,
          fontFamily: GoogleFonts.poppins().fontFamily,
          scaffoldBackgroundColor: darkgreen,
          appBarTheme: AppBarTheme(backgroundColor: green),
          textTheme: KTextTheme.lightTextTheme,
        ),
        home: const SplashScreen()
      ),
    );
  }
}