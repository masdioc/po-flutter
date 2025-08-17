class Supplier {
  final String id;
  final String name;
  final String address;
  final String phone;
  final String email;

  Supplier({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
  });

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
    );
  }
}

class Item {
  final String id;
  final String purchaseOrderId;
  final String productName;
  final int quantity;
  final double priceBuy;
  final double priceSell;

  Item({
    required this.id,
    required this.purchaseOrderId,
    required this.productName,
    required this.quantity,
    required this.priceBuy,
    required this.priceSell,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'].toString(),
      purchaseOrderId: json['purchase_order_id'].toString(),
      productName: json['product_name'] ?? '',
      quantity: int.tryParse(json['quantity'].toString()) ?? 0,
      priceBuy: double.tryParse(json['price_buy'].toString()) ?? 0.0,
      priceSell: double.tryParse(json['price_sell'].toString()) ?? 0.0,
    );
  }
}

class Payment {
  final String id;
  final String purchaseOrderId;
  final String paymentDate;
  final double amount;
  final String method;
  final String status;
  final String note;

  Payment({
    required this.id,
    required this.purchaseOrderId,
    required this.paymentDate,
    required this.amount,
    required this.method,
    required this.status,
    required this.note,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'].toString(),
      purchaseOrderId: json['purchase_order_id'].toString(),
      paymentDate: json['payment_date'] ?? '',
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      method: json['method'] ?? '',
      status: json['status'] ?? '',
      note: json['note'] ?? '',
    );
  }
}

class PurchaseOrder {
  final String id;
  final String supplierId;
  final String orderNumber;
  final String orderDate;
  String status; // tetap string
  final double total;
  final Supplier? supplier;
  final List<PurchaseOrderItem> items;
  final List<Payment> payments;

  PurchaseOrder({
    required this.id,
    required this.supplierId,
    required this.orderNumber,
    required this.orderDate,
    required this.status,
    required this.total,
    this.supplier,
    required this.items,
    required this.payments,
  });

  bool get isPaid {
    final s = status.toLowerCase();
    return s == "paid" || s == "lunas" || s == "1" || s == "completed";
  }

  factory PurchaseOrder.fromJson(Map<String, dynamic> json) {
    return PurchaseOrder(
      id: json['id'].toString(),
      supplierId: json['supplier_id'].toString(),
      orderNumber: json['order_number'] ?? '',
      orderDate: json['order_date'] ?? '',
      status: json['status']?.toString() ?? '',
      total: double.tryParse(json['total'].toString()) ?? 0.0,
      supplier:
          json['supplier'] != null ? Supplier.fromJson(json['supplier']) : null,
      items: json['items'] != null
          ? List<PurchaseOrderItem>.from(
              json['items'].map((x) => PurchaseOrderItem.fromJson(x)))
          : [],
      payments: json['payments'] != null
          ? List<Payment>.from(json['payments'].map((x) => Payment.fromJson(x)))
          : [],
    );
  }
}

class PurchaseOrderItem {
  final String name;
  final int qty;
  final double priceBuy;
  final double priceSell;

  PurchaseOrderItem({
    required this.name,
    required this.qty,
    required this.priceBuy,
    required this.priceSell,
  });

  factory PurchaseOrderItem.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderItem(
      name: json['product_name'] ?? '',
      qty: int.tryParse(json['quantity'].toString()) ?? 0,
      priceBuy: double.tryParse(json['price_but'].toString()) ?? 0.0,
      priceSell: double.tryParse(json['price_sell'].toString()) ?? 0.0,
    );
  }
}
