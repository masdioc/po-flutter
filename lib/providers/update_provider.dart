// lib/providers/update_provider.dart
import 'package:flutter/foundation.dart';
import '../services/update_checker.dart';

class UpdateProvider with ChangeNotifier {
  bool _neededUpdate = false;
  bool get neededUpdate => _neededUpdate;

  String _updateUrl = "";
  String get updateUrl => _updateUrl;

  Future<void> checkUpdate() async {
    final result = await UpdateChecker.isUpdateAvailable();
    _neededUpdate = result["neededUpdate"] ?? false;
    _updateUrl = result["updateUrl"] ?? "";
    notifyListeners();
  }
}
