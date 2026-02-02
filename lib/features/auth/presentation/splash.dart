import 'package:flutter/material.dart';
import 'package:orca/core/utils/colors.dart';
import 'package:orca/features/auth/domain/auth_provider.dart';
import 'package:orca/features/auth/presentation/get_started.dart';
import 'package:orca/features/fitness/presentations/gym_ownerpage.dart';
import 'package:orca/features/home/presentation/bottomnav.dart';
import 'package:orca/features/home/presentation/home_page.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));

    final auth = Provider.of<AuthProvider>(context, listen: false);
    await auth.loadAuthData();

    if (!auth.isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const GetStarted()),
      );
      return;
    }

    switch (auth.role) {
      case "GymOwner":
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => GymOwnerPage(token: auth.token,)),
        );
        break;

      case "Admin":
        Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => NavBarPage(token: auth.token!,)),
      );
        break;

      default:
        Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => NavBarPage(token: auth.token!,)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("OS",
                style: TextStyle(
                    fontSize: 32,
                    color: green,
                    fontWeight: FontWeight.w800,
                    fontStyle: FontStyle.italic)),
            Text("CLUB",
                style: TextStyle(
                    fontSize: 32,
                    color: green,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.italic)),
          ],
        ),
      ),
    );
  }
}
