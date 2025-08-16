import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
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
  File? proofFile;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickProof() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    if (pickedFile != null) {
      setState(() {
        proofFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _processPayment() async {
    if (selectedMethod == null) return;

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
        proofFile: proofFile,
      );

      if (result["success"] == true) {
        widget.po.status = "paid"; // update status
        setState(() => widget.po.status = "paid");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result["message"] ?? "Pembayaran berhasil")),
        );

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
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      body: SingleChildScrollView(
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
              title: const Text("Cash (Bayar di Tempat)"),
              value: "cash",
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
            const SizedBox(height: 20),
            // Bukti pembayaran
            if (selectedMethod == "transfer") ...[
              const Text("Upload Bukti Pembayaran:",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              proofFile != null
                  ? Image.file(proofFile!, height: 150)
                  : const Text("Belum ada bukti pembayaran"),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _pickProof,
                icon: const Icon(Icons.camera_alt),
                label: const Text("Ambil Foto Bukti"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: selectedMethod == null || isLoading
                    ? null
                    : _processPayment,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Konfirmasi Pembayaran",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
