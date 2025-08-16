import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class ConnectionService with ChangeNotifier {
  bool _isOnline = true;
  bool get isOnline => _isOnline;

  ConnectionService() {
    _initConnectionListener();
  }

  void _initConnectionListener() {
    Connectivity().onConnectivityChanged.listen((result) async {
      bool hasInternet = await InternetConnectionChecker().hasConnection;
      _isOnline = hasInternet;
      notifyListeners(); // bisa dipakai di UI pakai Provider/Consumer
    });
  }
}
