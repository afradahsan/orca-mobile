import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:orca/features/auth/data/auth_services.dart';

class AuthRepo {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn signIn = GoogleSignIn.instance;
  final AuthServices authServices;

  AuthRepo({required this.authServices});

  Future<User?> handleSignIn() async {
    try {
      await signIn.initialize(
          serverClientId:
              "966816861961-tva7k85opl4gjelj9it12vjs76n24lgg.apps.googleusercontent.com");

      final account = await signIn.authenticate();
      if (account == null) {
        debugPrint('null acc');
        return null;
      }

      final auth = await account.authentication;
      final credential = GoogleAuthProvider.credential(idToken: auth.idToken);
      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } on GoogleSignInException catch (e) {
      debugPrint(e.code == GoogleSignInExceptionCode.canceled
          ? 'Sign in aborted by user'
          : 'Sign in failed: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await GoogleSignIn.instance.signOut();
    await _auth.signOut();
  }
 
  Future<Map<String, dynamic>> login({
    String? email,
    String? phone,
    required String password,
  }) async {
    if (email != null && email.isNotEmpty) {
      return await authServices.loginWithEmail(
        email: email,
        password: password,
      );
    } else if (phone != null && phone.isNotEmpty) {
      return await authServices.loginWithPhone(
        phone: phone,
        password: password,
      );
    } else {
      throw Exception("Either email or phone must be provided");
    }
  }
}
