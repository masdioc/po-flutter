import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:po_app/config/app_config.dart';

class UpdateChecker {
  static Future<Map<String, dynamic>> isUpdateAvailable() async {
    try {
      // Ambil versi app yang terinstall di device
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String currentVersion = packageInfo.version; // ex: "1.0.0"

      // --- OPSI 1: Ambil versi terbaru dari server ---
      String baseUrl = AppConfig.apiUrl;
      var uri = Uri.parse("$baseUrl/last-versions");
      final response = await http.get(uri);

      if (response.statusCode != 200) {
        return {"neededUpdate": false, "updateUrl": ""};
      }

      final data = json.decode(response.body);
      String latestVersion = data["latest_version"]; // ex: "1.2.0"
      String updateUrl = data["update_url"]; // 🔹 ambil dari JSON

      bool neededUpdate = _isVersionNewer(currentVersion, latestVersion);

      return {
        "neededUpdate": neededUpdate,
        "updateUrl": updateUrl,
      };
    } catch (e) {
      print("UpdateChecker error: $e");
      return {"neededUpdate": false, "updateUrl": ""};
    }
  }

  /// ✅ helper buat bandingin versi
  static bool _isVersionNewer(String current, String latest) {
    List<int> currentParts =
        current.split(".").map((e) => int.tryParse(e) ?? 0).toList();
    List<int> latestParts =
        latest.split(".").map((e) => int.tryParse(e) ?? 0).toList();

    for (int i = 0; i < latestParts.length; i++) {
      int cur = (i < currentParts.length) ? currentParts[i] : 0;
      int lat = latestParts[i];
      if (lat > cur) return true; // ada versi lebih baru
      if (lat < cur) return false; // versi app lebih tinggi
    }
    return false; // sama
  }
}
