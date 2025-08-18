import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import "../config/app_config.dart";

class AuthProvider with ChangeNotifier {
  final String baseUrl = AppConfig.apiUrl;
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
      // ✅ simpan role user ke SharedPreferences
      if (data['user']['role'] != null) {
        await prefs.setString('userRole', data['user']['role'].toString());
      }
      if (data['user']['suplier_norek'] != null) {
        await prefs.setString(
            'suplier_norek', data['user']['suplier_norek'].toString());
        await prefs.setString(
            'suplier_bank', data['user']['suplier_bank'].toString());
        await prefs.setString(
            'suplier_an_bank', data['user']['suplier_an_bank'].toString());
      }
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
    final storedRole = prefs.getString('userRole'); // ✅ ambil role

    if (storedToken != null && storedUser != null) {
      _token = storedToken;
      _user = User.fromJson(json.decode(storedUser));

      if (storedRole != null) {
        // bisa tambahkan ke user object atau pakai variabel terpisah
        print("Role tersimpan: $storedRole");
      }

      notifyListeners();
    }
  }

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/change-password"),
        headers: {
          "Authorization": "Bearer $token",
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          "old_password": oldPassword,
          "new_password": newPassword,
          "new_password_confirmation": newPassword,
        }),
      );

      print("Status: ${response.statusCode}");
      print("Body: ${response.body}");

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("Error changePassword: $e");
      return false;
    }
  }
}
