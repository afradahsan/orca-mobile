import 'package:flutter/material.dart';
import 'package:orca/features/auth/domain/auth_provider.dart';
import 'package:orca/features/home/presentation/bottomnav.dart';
import 'package:provider/provider.dart';
import 'package:orca/features/auth/presentation/login_page.dart';
import 'package:orca/features/fitness/presentations/gym_ownerpage.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    if (!auth.isLoggedIn) {
      return const LoginPage();
    }

    if (auth.role == "GymOwner") {
      return GymOwnerPage(token: auth.token,);
    } else if (auth.role == "Admin") {
      return LoginPage();
    } else {
      return const NavBarPage();
    }
  }
}
