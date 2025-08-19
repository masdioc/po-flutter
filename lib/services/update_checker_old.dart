import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:po_app/config/app_config.dart';

class UpdateChecker {
  static Future<bool> checkForUpdate(BuildContext context) async {
    // final response = await http.get(Uri.parse("http://yourapi.com/last-version"));
    String baseUrl = AppConfig.apiUrl;
    var uri = Uri.parse("$baseUrl/last-versions");
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final packageInfo = await PackageInfo.fromPlatform();
      String currentVersion = packageInfo.version;
      String minSupported = data["min_supported_version"];
      String latestVersion = data["latest_version"];
      String updateUrl = data["update_url"];

      // Cek kalau versi sekarang < min_supported → wajib update
      if (_isVersionLower(currentVersion, minSupported)) {
        _showForceUpdateDialog(context, updateUrl, data["notes"]);
        return true; // wajib update
      }

      // Kalau cuma ada versi terbaru (tidak wajib), bisa kasih optional dialog
      if (_isVersionLower(currentVersion, latestVersion)) {
        _showOptionalUpdateDialog(context, updateUrl, data["notes"]);
      }
    }
    return false; // tidak wajib update
  }

  static bool _isVersionLower(String current, String target) {
    List<int> c = current.split(".").map(int.parse).toList();
    List<int> t = target.split(".").map(int.parse).toList();

    for (int i = 0; i < c.length; i++) {
      if (c[i] < t[i]) return true;
      if (c[i] > t[i]) return false;
    }
    return false;
  }

  static void _showForceUpdateDialog(
      BuildContext context, String url, String notes) {
    showDialog(
      context: context,
      barrierDismissible: false, // ❌ tidak bisa dismiss
      builder: (_) => AlertDialog(
        title: const Text("Update Diperlukan"),
        content: Text(notes ?? "Silakan update aplikasi ke versi terbaru."),
        actions: [
          TextButton(
            onPressed: () {
              // buka Play Store
              // launchUrl(Uri.parse(url));
            },
            child: const Text("Update Sekarang"),
          ),
        ],
      ),
    );
  }

  static void _showOptionalUpdateDialog(
      BuildContext context, String url, String notes) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Update Tersedia"),
        content: Text(notes ?? "Versi terbaru tersedia."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Nanti"),
          ),
          TextButton(
            onPressed: () {
              // launchUrl(Uri.parse(url));
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }
}
