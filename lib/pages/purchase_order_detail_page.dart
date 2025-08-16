import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/purchase_order.dart';

class PurchaseOrderDetailPage extends StatelessWidget {
  final PurchaseOrder po;

  const PurchaseOrderDetailPage({super.key, required this.po});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("Detail PO ${po.orderNumber}"),
        backgroundColor: Colors.blueAccent,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Nomor Order: ${po.orderNumber}",
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Tanggal: ${po.orderDate}"),
            Text("Status: ${po.status}"),
            Text("Total: Rp ${po.total.toStringAsFixed(0)}"),
            const SizedBox(height: 20),
            const Text("Detail Item:",
                style: TextStyle(fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: po.items.length,
                itemBuilder: (context, index) {
                  final item = po.items[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      title: Text(item.name),
                      subtitle: Text(
                          "${item.qty} x Rp ${item.price.toStringAsFixed(0)}"),
                      trailing: Text(
                        "Rp ${(item.qty * item.price).toStringAsFixed(0)}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
