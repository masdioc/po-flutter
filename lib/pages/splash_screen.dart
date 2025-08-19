import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_page.dart';
import 'main_page.dart'; // ganti sesuai halaman utama setelah login
import '../services/update_checker.dart'; // pastikan file UpdateChecker ada
import 'package:url_launcher/url_launcher.dart'; // ✅ buat buka PlayStore

class SplashScreen extends StatefulWidget {
  final bool showUpdate; // ✅ tambahin properti
  const SplashScreen({super.key, this.showUpdate = false}); // ✅ default false

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    if (!widget.showUpdate) {
      Timer(const Duration(seconds: 3), () {
        _checkAuth();
      });
    }
    print(widget.showUpdate);
  }

  Future<void> _checkAuth() async {
    // if (widget.showUpdate) return;

    print(widget.showUpdate);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    // Cek apakah user sudah login sebelumnya
    await auth.tryAutoLogin();

    // Simulasi loading 2 detik
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return; // ✅ biar aman kalau widget disposed

    if (auth.isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigation()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  Future<void> _launchUpdateUrl() async {
    const url =
        "https://play.google.com/store/apps/details?id=com.example.app"; // ✅ sesuaikan
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.showUpdate) {
      // ✅ kalau update diperlukan
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.system_update, size: 80, color: Colors.blue),
              const SizedBox(height: 20),
              const Text(
                "Update tersedia!",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _launchUpdateUrl,
                child: const Text("Update Sekarang"),
              ),
            ],
          ),
        ),
      );
    }

    // ✅ splash default kalau gak ada update
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icon/logo_po.png',
              width: 100,
              height: 100,
            ),
            const SizedBox(height: 20),
            const Text(
              'Welcome PO App',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
