import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:po_app/pages/change_password_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart'; // ✅ import
import 'package:url_launcher/url_launcher.dart';
import 'login_page.dart';
import '../providers/update_provider.dart';

// Warna tema utama
const primaryColor = Colors.teal;

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  Map<String, dynamic>? user;
  String currentVersion = ""; // ✅ simpan versi aplikasi

  @override
  void initState() {
    super.initState();
    _loadUserFromPrefs();
    _loadAppVersion(); // ✅ ambil versi app
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final updateProvider =
          Provider.of<UpdateProvider>(context, listen: false);
      updateProvider.checkUpdate(); // fetch versi terbaru
    });
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

  Future<void> _loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() {
      currentVersion = "${info.version}+${info.buildNumber}";
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("user");

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  Future<void> _launchUpdateUrl(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.parse(url);

    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint("Gagal buka url: $e");
      await launchUrl(uri, mode: LaunchMode.inAppWebView);
    }
  }

  @override
  Widget build(BuildContext context) {
    final updateProvider = Provider.of<UpdateProvider>(context);

    return Scaffold(
      body: (user == null)
          ? const Center(
              child: Text(
                "Tidak ada data user",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox.expand(
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
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
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Email: ${user!['email'] ?? '-'}",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color.fromARGB(255, 63, 63, 63),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // ✅ tampilkan versi
                        Text(
                          "App Version: $currentVersion",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color.fromARGB(255, 63, 63, 63),
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (updateProvider.neededUpdate)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: ElevatedButton.icon(
                              onPressed: () =>
                                  _launchUpdateUrl(updateProvider.updateUrl),
                              icon: const Icon(Icons.system_update, size: 24),
                              label: const Text(
                                "Update Sekarang ke versi terbaru",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 50),
                                backgroundColor: Colors.deepOrange,
                                elevation: 6, // shadow lebih jelas
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),

                        const SizedBox(height: 12),
                        // Tombol Ganti Password
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ChangePasswordPage(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.lock_reset),
                          label: const Text("Ganti Password"),
                        ),

                        const SizedBox(height: 12),

                        // Tombol Logout
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
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
