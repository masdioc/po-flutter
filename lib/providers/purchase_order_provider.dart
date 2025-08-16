import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'auth_provider.dart';
import '../models/purchase_order.dart';
import 'package:provider/provider.dart';
import 'package:login_profile_app/pages/main_page.dart';

class PurchaseOrderProvider with ChangeNotifier {
  final String baseUrl = 'https://stagingappku.my.id/po-api/api';
  final List<PurchaseOrder> _orders = [];

  List<PurchaseOrder> get orders => _orders;

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
      // Refresh list
      await fetchOrders(context);
    } else {
      throw Exception('Gagal menambah PO: ${response.body}');
    }
  }

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
}
