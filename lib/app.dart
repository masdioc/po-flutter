import 'package:flutter/material.dart';
import 'pages/splash_screen.dart';
import 'services/check_connection.dart';
import 'package:provider/provider.dart';

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
                        fontStyle: FontStyle.italic,
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
