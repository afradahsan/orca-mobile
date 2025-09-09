import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:orca/core/themes/text_theme.dart';
import 'package:orca/core/utils/colors.dart';
import 'package:orca/features/auth/presentation/splash.dart';
import 'package:orca/features/ecom/domain/cart_provider.dart';
import 'package:orca/features/fitness/data/role_provider.dart';
import 'package:orca/features/home/presentation/home_page.dart';
import 'package:orca/firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => RoleProvider()),
    ChangeNotifierProvider(create: (_) => CartProvider())
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<Widget> pageNotifier = ValueNotifier(HomePage());
    return Sizer(
        builder: (context, orientation, deviceType) => ValueListenableBuilder(
            valueListenable: pageNotifier,
            builder: (context, value, _) => MaterialApp(
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
                home: const SplashScreen())));
  }
}
