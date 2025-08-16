import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/purchase_order.dart';
import '../services/payment_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentPage extends StatefulWidget {
  final PurchaseOrder po;

  const PaymentPage({super.key, required this.po});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String? selectedMethod;
  String note = "";
  bool isLoading = false;

  Future<void> _processPayment() async {
    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";

      final now = DateTime.now();
      final isoString = now.toIso8601String();

      final result = await PaymentService.payOrder(
        purchaseOrderId: int.parse(widget.po.id.toString()),
        paymentDate: isoString,
        amount: widget.po.total,
        method: selectedMethod!,
        note: note,
        token: token,
      );

      if (result["success"] == true) {
        widget.po.status = "paid"; // update status
        // Update status PO di memory menjadi 'paid'
        setState(() {
          widget.po.status = "paid";
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result["message"] ?? "Pembayaran berhasil")),
        );

        // Kirim PO yang diperbarui ke halaman sebelumnya
        Navigator.pop(context, widget.po);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result["message"] ?? "Pembayaran gagal")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Pembayaran"),
        backgroundColor: Colors.green,
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
            Text("Nomor Order: ${widget.po.orderNumber}",
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Total Bayar: ${currencyFormatter.format(widget.po.total)}",
                style: const TextStyle(fontSize: 18, color: Colors.red)),
            const SizedBox(height: 20),
            const Text("Pilih Metode Pembayaran:",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            RadioListTile<String>(
              title: const Text("Transfer Bank"),
              value: "transfer",
              groupValue: selectedMethod,
              onChanged: (value) {
                setState(() => selectedMethod = value);
              },
            ),
            RadioListTile<String>(
              title: const Text("E-Wallet (OVO, Dana, Gopay)"),
              value: "ewallet",
              groupValue: selectedMethod,
              onChanged: (value) {
                setState(() => selectedMethod = value);
              },
            ),
            RadioListTile<String>(
              title: const Text("COD (Bayar di Tempat)"),
              value: "cod",
              groupValue: selectedMethod,
              onChanged: (value) {
                setState(() => selectedMethod = value);
              },
            ),
            const SizedBox(height: 20),
            TextField(
              decoration: const InputDecoration(
                labelText: "Catatan",
                hintText: "Misal: Pembayaran DP 50%",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() => note = value);
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed:
                  selectedMethod == null || isLoading ? null : _processPayment,
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "Konfirmasi Pembayaran",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
