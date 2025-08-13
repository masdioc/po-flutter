import 'package:flutter/material.dart';
import '../models/purchase_order.dart';
import 'dart:math';

class PurchaseOrderProvider with ChangeNotifier {
  final List<PurchaseOrder> _orders = [];

  List<PurchaseOrder> get orders => _orders;

  void addOrder(String title, String description) {
    final newOrder = PurchaseOrder(
      id: Random().nextInt(999999).toString(),
      title: title,
      description: description,
    );
    _orders.add(newOrder);
    notifyListeners();
  }

  void updateOrder(String id, String title, String description) {
    final index = _orders.indexWhere((po) => po.id == id);
    if (index != -1) {
      _orders[index] =
          PurchaseOrder(id: id, title: title, description: description);
      notifyListeners();
    }
  }

  void deleteOrder(String id) {
    _orders.removeWhere((po) => po.id == id);
    notifyListeners();
  }
}
