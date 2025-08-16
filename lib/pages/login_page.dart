import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'main_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String errorMsg = "";
  bool _isLoading = false;
  bool _obscurePassword = true; // <-- untuk toggle show/hide

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
      errorMsg = "";
    });

    final auth = Provider.of<AuthProvider>(context, listen: false);

    try {
      await auth.login(
        _usernameController.text,
        _passwordController.text,
      );

      if (!mounted) return;

      if (auth.isLoggedIn) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainNavigation()),
        );
      } else {
        setState(() {
          errorMsg = "Login gagal. Pastikan username dan password Anda benar.";
        });
      }
    } on Exception {
      setState(() {
        errorMsg = "Terjadi kesalahan saat login. Silakan coba lagi.";
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.shopping_cart,
                size: 100,
                color: Colors.blueAccent,
              ),
              const SizedBox(height: 20),
              const Text(
                "Selamat Datang",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Silakan login untuk melanjutkan",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 30),

              // Username
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: "Username",
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // Password dengan toggle show/hide
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              if (errorMsg.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Text(
                    errorMsg,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text(
                          "Login",
                          style: TextStyle(fontSize: 18),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
