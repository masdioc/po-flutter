import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/update_provider.dart';
import 'login_page.dart';
import 'main_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:install_plugin/install_plugin.dart';
import 'package:permission_handler/permission_handler.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    final updateProvider = Provider.of<UpdateProvider>(context, listen: false);

    // cek update dulu
    await updateProvider.checkUpdate();

    if (!mounted) return;

    // kalau perlu update → jangan lanjut auth
    if (updateProvider.neededUpdate) return;

    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    await auth.tryAutoLogin();

    if (!mounted) return;

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

  // Future<void> _launchUpdateUrl(String url) async {
  //   if (url.isEmpty) return;
  //   if (await canLaunchUrl(Uri.parse(url))) {
  //     await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  //   }
  // }
  // Future<void> _launchUpdateUrl(String url) async {
  //   if (url.isEmpty) return;
  //   final uri = Uri.parse(url);

  //   try {
  //     await launchUrl(
  //       uri,
  //       mode: LaunchMode.externalApplication, // buka browser default
  //     );
  //   } catch (e) {
  //     debugPrint("Gagal buka url: $e");
  //     // fallback ke WebView dalam aplikasi
  //     await launchUrl(uri, mode: LaunchMode.inAppWebView);
  //   }
  // }

  Future<void> _downloadAndInstallApk(BuildContext context, String url) async {
    if (url.isEmpty) return;

    try {
      // 1️⃣ Minta izin storage
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Izin storage ditolak")),
          );
        }
        return;
      }

      // 2️⃣ Lokasi simpan APK -> folder aplikasi sendiri (lebih aman)
      Directory dir;
      if (Platform.isAndroid) {
        dir = (await getExternalStorageDirectory())!;
      } else {
        dir = await getApplicationDocumentsDirectory();
      }

      final savePath = "${dir.path}/update_app.apk";

      // pastikan folder ada
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }

      // 3️⃣ Download APK
      final dio = Dio();
      await dio.download(
        url,
        savePath,
        onReceiveProgress: (count, total) {
          final progress = (count / total * 100).toStringAsFixed(0);
          debugPrint("Download progress: $progress%");
        },
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Download selesai, membuka installer...")),
        );
      }

      // 4️⃣ Install APK
      await InstallPlugin.installApk(
        savePath,
        appId: 'com.example.po_app', // ganti dengan package name kamu
      ).catchError((e) {
        debugPrint("Install error: $e");
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Install APK gagal: $e")),
          );
        }
      });
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal download APK: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final updateProvider = Provider.of<UpdateProvider>(context);

    if (updateProvider.neededUpdate) {
      // kalau butuh update
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
                onPressed: () {
                  _downloadAndInstallApk(
                    context,
                    updateProvider.updateUrl,
                  );
                },
                child: const Text("Update Aplikasi"),
              ),
            ],
          ),
        ),
      );
    }

    // splash default
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
