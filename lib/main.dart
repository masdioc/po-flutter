import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:po_app/providers/purchase_order_provider.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'pages/splash_screen.dart';
import 'services/check_connection.dart'; // bikin file baru

void main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  // await dotenv.load(fileName: ".env"); // Load file .env
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => ConnectionService()), // ✅ Tambah koneksi global
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
      title: 'PO App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Stack(
        children: [
          const SplashScreen(),
          Consumer<ConnectionService>(
            builder: (context, connection, child) {
              if (!connection.isOnline) {
                return Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    color: Colors.red,
                    padding: const EdgeInsets.all(8),
                    child: const Text(
                      "Tidak ada koneksi internet",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontStyle: FontStyle.italic, // kalau mau miring
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}
