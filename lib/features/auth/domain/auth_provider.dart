import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  String? _role;
  String? _userName;

  String? get token => _token;
  String? get role => _role;
  String? get userName => _userName;

  bool get isLoggedIn => _token != null;

  Future<void> loadAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString("token");
    debugPrint('statement: Loaded token from prefs: $_token');
    _role = prefs.getString("role");
    _userName = prefs.getString("user_name");
    notifyListeners();
  }

  Future<void> login(String token, String role, {String? userName}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", token);
    await prefs.setString("role", role);

    _token = token;
    _role = role;

    if (userName != null && userName.isNotEmpty) {
      await prefs.setString("user_name", userName);
      _userName = userName;
    }

    notifyListeners();
  }

  Future<void> updateUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("user_name", name);
    _userName = name;
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
    await prefs.remove("role");
    await prefs.remove("gym_token");
    await prefs.remove("user_name");

    _token = null;
    _role = null;
    _userName = null;
    notifyListeners();
  }
}
