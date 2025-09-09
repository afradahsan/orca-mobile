import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final GoogleSignIn signIn = GoogleSignIn.instance;

  Future<User?> handleSignIn() async {
    try {
      await signIn.initialize(serverClientId: "966816861961-tva7k85opl4gjelj9it12vjs76n24lgg.apps.googleusercontent.com");
      final account = await signIn.authenticate();

      if (account == null) {
        debugPrint('null acc');
        return null;
      }

      final auth = account.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: auth.idToken,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      debugPrint('statement IS $userCredential');
      final user = userCredential.user;
      return user;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        debugPrint('Sign in aborted by user');
      } else {
        debugPrint('Sign in failed: $e');
      }
      return null;
    }
  }

  Future<void> signOut() async {
    await GoogleSignIn.instance.signOut();
    await _auth.signOut();
  }
}
