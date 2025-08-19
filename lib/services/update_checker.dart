import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:convert';

import 'package:po_app/config/app_config.dart';

class UpdateChecker extends ChangeNotifier {
  bool needsUpdate = false;

  Future<bool> checkForUpdate() async {
    try {
      String baseUrl = AppConfig.apiUrl;
      var uri = Uri.parse("$baseUrl/last-versions");
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        String lastVersion = data['latest_version'];
        final packageInfo = await PackageInfo.fromPlatform();
        String currentVersion = packageInfo.version;
        // const currentVersion = "1.1"; // ganti dengan package_info_plus nanti

        print("Latest version BE: $lastVersion");

        if (lastVersion != currentVersion) {
          needsUpdate = true;
          notifyListeners();
        } else {
          needsUpdate = false;
          notifyListeners();
        }

        notifyListeners(); // ✅ baru dipanggil setelah set
        print("needsUpdate: $needsUpdate");
        return needsUpdate;
      }
    } catch (e) {
      debugPrint("Update check failed: $e");
    }

    return false; // fallback biar gak null
  }
}
