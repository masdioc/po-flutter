import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:po_app/config/app_config.dart';
import 'dart:convert';
import 'auth_provider.dart';
import '../models/purchase_order.dart';
import 'package:provider/provider.dart';

class PurchaseOrderProvider with ChangeNotifier {
  // final String baseUrl = 'http://192.168.0.108/po-api/api';
  final String baseUrl = AppConfig.apiUrl;
  final List<PurchaseOrder> _orders = [];
  List<Map<String, dynamic>> _products = []; // <- list produk dari API

  List<PurchaseOrder> get orders => _orders;
  List<Map<String, dynamic>> get products => _products;

  /// Fetch list PO
  Future<void> fetchOrders(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;
    if (token == null) throw Exception('Token tidak ditemukan');

    final url = Uri.parse('$baseUrl/po');
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    });

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      _orders.clear();
      _orders.addAll(data.map((item) => PurchaseOrder.fromJson(item)));
      notifyListeners();
    } else {
      throw Exception('Gagal mengambil data PO: ${response.body}');
    }
  }

  /// Fetch list produk dari API /products
  /// Fetch list produk dari API /products
  Future<List<Map<String, dynamic>>> fetchProducts() async {
    final url = Uri.parse('$baseUrl/products');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        // Response langsung berupa array JSON
        final List<dynamic> data = json.decode(response.body);
        _products = List<Map<String, dynamic>>.from(data);
        notifyListeners();
        return _products;
      } else {
        throw Exception('Gagal fetch products: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetchProducts: $e');
      throw e;
    }
  }

  /// Tambah PO
  Future<void> addOrder(
      BuildContext context, Map<String, dynamic> payload) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;
    if (token == null) throw Exception('Token tidak ditemukan');

    final url = Uri.parse('$baseUrl/po');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode(payload),
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      _orders.add(PurchaseOrder.fromJson(data));
      notifyListeners();
      await fetchOrders(context); // refresh list PO
    } else {
      throw Exception('Gagal menambah PO: ${response.body}');
    }
  }

  /// Update PO
  Future<void> updateOrder(
      BuildContext context, String id, Map<String, dynamic> payload) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;
    if (token == null) throw Exception('Token tidak ditemukan');

    final url = Uri.parse('$baseUrl/po/$id');
    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(payload),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final index = _orders.indexWhere((po) => po.id == id);
      if (index != -1) {
        _orders[index] = PurchaseOrder.fromJson(data);
        notifyListeners();
      }
    } else {
      throw Exception('Gagal update PO: ${response.body}');
    }
  }

  Future<void> updatePOOrder(
      BuildContext context, String id, Map<String, dynamic> payload) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;
    if (token == null) throw Exception('Token tidak ditemukan');

    final url = Uri.parse('$baseUrl/poupdate/$id');
    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(payload),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final index = _orders.indexWhere((po) => po.id == id);
      if (index != -1) {
        _orders[index] = PurchaseOrder.fromJson(data);
        notifyListeners();
      }
    } else {
      throw Exception('Gagal update PO: ${response.body}');
    }
  }

  /// Update item PO
  Future<bool> updateItem(BuildContext context, PurchaseOrderItem item) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;
    if (token == null) throw Exception("Token tidak ditemukan");

    try {
      final response = await http.put(
        Uri.parse("$baseUrl/purchase-order-items/${item.id}"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: json.encode(item.toJson()),
      );

      if (response.statusCode == 200) {
        // Update state lokal di orders
        for (var order in _orders) {
          final index = order.items.indexWhere((e) => e.id == item.id);
          if (index != -1) {
            order.items[index] = item;
            break;
          }
        }
        notifyListeners();
        return true;
      } else {
        debugPrint("Update gagal: ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint("Error updateItem: $e");
      return false;
    }
  }
}
