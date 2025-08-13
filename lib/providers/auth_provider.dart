import 'package:flutter/material.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  User? _user;

  User? get user => _user;
  bool get isLoggedIn => _user != null;

  void login(String username, String password) {
    if (username == "admin" && password == "1234") {
      _user = User(username: username, email: "\$username@example.com");
      notifyListeners();
    }
  }

  void logout() {
    _user = null;
    notifyListeners();
  }
}
