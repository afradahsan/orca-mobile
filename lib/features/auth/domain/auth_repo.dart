import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:orca/features/auth/data/auth_services.dart';

class GoogleSignInResult {
  final User? user;
  final String? errorMessage;
  final bool isCancelled;

  const GoogleSignInResult({
    this.user,
    this.errorMessage,
    this.isCancelled = false,
  });

  bool get isSuccess => user != null;
}

class AuthRepo {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn signIn = GoogleSignIn.instance;
  final AuthServices authServices;

  static bool _isGoogleInitialized = false;
  static const String serverClientId =
      "966816861961-tva7k85opl4gjelj9it12vjs76n24lgg.apps.googleusercontent.com";

  AuthRepo({required this.authServices});

  /// Initializes the GoogleSignIn v7 singleton once during startup or before first use.
  static Future<void> initializeGoogleSignIn() async {
    if (_isGoogleInitialized) return;
    try {
      await GoogleSignIn.instance.initialize(
        serverClientId: serverClientId,
      );
      _isGoogleInitialized = true;
      debugPrint('GoogleSignIn initialized successfully.');
    } catch (e) {
      debugPrint('GoogleSignIn initialization warning: $e');
    }
  }

  Future<GoogleSignInResult> handleSignIn() async {
    try {
      if (!_isGoogleInitialized) {
        await initializeGoogleSignIn();
      }

      final account = await signIn.authenticate();
      final auth = account.authentication;
      final idToken = auth.idToken;

      if (idToken == null || idToken.isEmpty) {
        return const GoogleSignInResult(
          errorMessage:
              'No ID token received from Google. Please ensure the Web Client ID and SHA fingerprints are configured in the Firebase Console.',
        );
      }

      final credential = GoogleAuthProvider.credential(
        idToken: idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      return GoogleSignInResult(user: userCredential.user);
    } on GoogleSignInException catch (e) {
      debugPrint('GoogleSignInException [code: ${e.code}]: ${e.description}');
      final codeString = e.code.toString().toLowerCase();
      final isCancel = codeString.contains('cancel');

      String readableMessage;
      if (isCancel) {
        readableMessage =
            'Google sign-in was cancelled or aborted. (Note: If the account picker opened and closed instantly, make sure your SHA-1 and SHA-256 fingerprints are added in the Firebase Console).';
      } else {
        readableMessage =
            'Google sign-in failed (${e.description ?? e.code.toString()}).';
      }

      return GoogleSignInResult(
        isCancelled: isCancel,
        errorMessage: readableMessage,
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException [${e.code}]: ${e.message}');
      return GoogleSignInResult(
        errorMessage: 'Firebase Authentication error [${e.code}]: ${e.message}',
      );
    } catch (e) {
      debugPrint('Google Sign-in Error: $e');
      return GoogleSignInResult(
        errorMessage: 'Sign-in error: $e',
      );
    }
  }

  Future<void> signOut() async {
    await signIn.signOut();
    await _auth.signOut();
  }

  Future<bool> checkUserExistence(String phone) async {
    debugPrint('checking user existence for phone: $phone');
    return await authServices.checkUserByPhone(phone);
  }

  Future<Map<String, dynamic>> login({
    String? email,
    String? phone,
    required String password,
  }) async {
    Map<String, dynamic> response;
    if (email != null && email.isNotEmpty) {
      response = await authServices.loginWithPhone(phone: email, password: password);
    } else if (phone != null && phone.isNotEmpty) {
      response = await authServices.loginWithPhone(phone: phone, password: password);
    } else {
      throw Exception("Phone number is required for login");
    }

    if (response['token'] == null) {
      final errorMsg = response['error'] ?? response['message'] ?? 'Incorrect password. Please try again.';
      throw Exception(errorMsg);
    }

    return response;
  }
}
