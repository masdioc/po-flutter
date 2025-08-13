import 'package:flutter/material.dart';
import 'package:login_profile_app/pages/main_page.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'profile_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String errorMsg = "";

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: "Username"),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text("Login"),
              onPressed: () {
                auth.login(
                  _usernameController.text,
                  _passwordController.text,
                );

                if (auth.isLoggedIn) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const MainNavigation()),
                  );
                } else {
                  setState(() {
                    errorMsg = "Username atau password salah!";
                  });
                }
              },
            ),
            if (errorMsg.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child:
                    Text(errorMsg, style: const TextStyle(color: Colors.red)),
              )
          ],
        ),
      ),
    );
  }
}
