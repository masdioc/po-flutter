import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:po_app/config/app_config.dart';
import 'dart:convert';
import 'auth_provider.dart';
import 'package:provider/provider.dart';

class ProductProvider with ChangeNotifier {
  final String baseUrl = AppConfig.apiUrl;
  List<Map<String, dynamic>> _products = [];

  List<Map<String, dynamic>> get products => _products;

  /// Ambil semua produk
  Future<void> fetchProducts(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;
    if (token == null) throw Exception("Token tidak ditemukan");

    final url = Uri.parse("$baseUrl/products");
    final response = await http.get(url, headers: {
      "Authorization": "Bearer $token",
      "Accept": "application/json",
      "Content-Type": "application/json",
    });

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      _products = List<Map<String, dynamic>>.from(data);
      notifyListeners();
    } else {
      throw Exception("Gagal fetch produk: ${response.body}");
    }
  }

  Future<void> addProduct(
      BuildContext context, Map<String, dynamic> payload) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;
    if (token == null) throw Exception("Token tidak ditemukan");

    try {
      final url = Uri.parse("$baseUrl/products");
      final response = await http.post(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: json.encode(payload),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);

        // Pastikan id produk selalu integer
        final newProduct = {
          ...Map<String, dynamic>.from(data),
          "id": int.tryParse(data["id"].toString()),
        };

        _products.add(newProduct);
        notifyListeners();

        // Snackbar langsung dari sini juga bisa, tapi lebih bagus di page
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Produk berhasil ditambahkan")),
          );
        }
      } else {
        throw Exception("Gagal tambah produk: ${response.body}");
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
      rethrow;
    }
  }

  /// Update produk
  Future<void> updateProduct(
      BuildContext context, int id, Map<String, dynamic> payload) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;
    if (token == null) throw Exception("Token tidak ditemukan");

    final url = Uri.parse("$baseUrl/products/$id");
    final response = await http.put(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: json.encode(payload),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final index = _products.indexWhere((p) => p["id"] == id);
      if (index != -1) {
        _products[index] = data;
        notifyListeners();
      }
    } else {
      throw Exception("Gagal update produk: ${response.body}");
    }
  }

  /// Hapus produk
  Future<void> deleteProduct(BuildContext context, int id) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;
    if (token == null) throw Exception("Token tidak ditemukan");

    final url = Uri.parse("$baseUrl/products/$id");
    final response = await http.delete(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );

    if (response.statusCode == 200) {
      _products.removeWhere((p) => p["id"] == id);
      notifyListeners();
    } else {
      throw Exception("Gagal hapus produk: ${response.body}");
    }
  }
}
