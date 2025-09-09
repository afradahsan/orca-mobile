import 'package:flutter/material.dart';

class RoleProvider with ChangeNotifier {
  String _role = '';

  String get role => _role;

  void setRole(String newRole) {
    _role = newRole;
    notifyListeners();
  }
  
  bool get isMember => _role == 'Gym Member';
}