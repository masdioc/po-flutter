import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
import 'login_page.dart';
import '../theme/app_colors.dart';

// Warna tema utama
const primaryColor = Colors.teal;

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  Map<String, dynamic>? user;

  @override
  void initState() {
    super.initState();
    _loadUserFromPrefs();
  }

  Future<void> _loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString("user");

    if (userString != null) {
      setState(() {
        user = json.decode(userString);
      });
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("user"); // hapus data user

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Akun Saya"),
        backgroundColor: AppColors.primary,
      ),
      body: Center(
        child: (user == null)
            ? const Text(
                "Tidak ada data user",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              )
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/logo-bgn.png',
                          height: 80,
                          width: 80,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "${user!['name'] ?? '-'}",
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "Email: ${user!['email'] ?? '-'}",
                          style:
                              const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            // backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: _logout,
                          icon: const Icon(Icons.logout),
                          label: const Text("Logout"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
