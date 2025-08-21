import 'package:flutter/material.dart';
import 'package:po_app/providers/product_provider.dart';
import 'package:po_app/providers/purchase_order_provider.dart';
import 'package:po_app/services/check_connection.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/update_provider.dart';
import 'pages/splash_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UpdateProvider()), // ✅ tambahin
        ChangeNotifierProvider(create: (_) => ConnectionService()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PurchaseOrderProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
