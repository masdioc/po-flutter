import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  final String baseUrl = 'https://stagingappku.my.id/po-api/api';

  User? _user;
  String? _token;

  User? get user => _user;
  bool get isLoggedIn => _user != null;
  String? get token => _token;

  // Login via API
  Future<void> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');
    // print("Login proses");
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      body: json.encode({'email': email, 'password': password}),
    );
    // print("status response: ${response.statusCode}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // Ambil user dan token dari response
      _token = data['token'];
      _user = User.fromJson(data['user']);
      notifyListeners();

      // Simpan token di SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);
      await prefs.setString('user', json.encode(data['user']));
    } else {
      throw Exception('Login gagal: ${response.body}');
    }
  }

  // Logout
  Future<void> logout() async {
    _user = null;
    _token = null;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
  }

  // Cek apakah user sudah login sebelumnya
  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('token')) return;

    final storedToken = prefs.getString('token');
    final storedUser = prefs.getString('user');
    if (storedToken != null && storedUser != null) {
      _token = storedToken;
      _user = User.fromJson(json.decode(storedUser));
      notifyListeners();
    }
  }
}
