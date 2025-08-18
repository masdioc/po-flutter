import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../models/purchase_order.dart';
import '../services/payment_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

class PaymentPage extends StatefulWidget {
  final PurchaseOrder po;

  const PaymentPage({super.key, required this.po});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String? selectedMethod;
  String bankName = "";
  String bankAccount = "";
  String accountName = "";
  String note = "";
  bool isLoading = false;
  File? proofFile;

  final ImagePicker _picker = ImagePicker();
  final TextEditingController _amountController = TextEditingController();
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  @override
  void initState() {
    super.initState();
    _loadBankInfo();
    // Set default total bayar dari PO
    _amountController.text = _currencyFormat.format(widget.po.total);

    // Listener untuk update format saat mengetik
    _amountController.addListener(() {
      String text = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
      if (text.isEmpty) text = '0';
      final number = double.parse(text);
      final formatted = _currencyFormat.format(number);
      if (formatted != _amountController.text) {
        _amountController.value = TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      }
    });
  }

  Future<void> _loadBankInfo() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      bankName = prefs.getString("suplier_bank") ?? "";
      bankAccount = prefs.getString("suplier_norek") ?? "";
      accountName = prefs.getString("suplier_an_bank") ?? "";
    });
  }

  Future<void> _pickProof(ImageSource source) async {
    final XFile? pickedFile =
        await _picker.pickImage(source: source, imageQuality: 80);
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
      final amountText =
          _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
      final amount = double.tryParse(amountText) ?? widget.po.total;
      final result = await PaymentService.payOrder(
        purchaseOrderId: int.parse(widget.po.id.toString()),
        paymentDate: isoString,
        amount: amount,
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
            TextField(
              controller: _amountController,
              readOnly: true,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                // <--- warna teks
                color: Colors.red,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                labelText: "Total Bayar",
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.copy, color: Colors.blue),
                  onPressed: () {
                    // Ambil hanya angka (hapus simbol, huruf, spasi)
                    final onlyNumbers = _amountController.text
                        .replaceAll(RegExp(r'[^0-9]'), '');

                    Clipboard.setData(
                      ClipboardData(text: onlyNumbers),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text("Lakukan pembayaran via Transfer Bank:",
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

            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                labelText: "Catatan",
                // hintText: "Silahkan masukan catatan",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() => note = value);
              },
            ),
            const SizedBox(height: 20),
            // Bukti pembayaran
            if (selectedMethod == "transfer") ...[
              SizedBox(
                width: double.infinity,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Informasi Rekening",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text("🏦 Bank: $bankName",
                            style: const TextStyle(fontSize: 15)),
                        Text("💳 No. Rekening: $bankAccount",
                            style: const TextStyle(fontSize: 15)),
                        Text("👤 Atas Nama: $accountName",
                            style: const TextStyle(fontSize: 15)),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: bankAccount));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                    "Nomor rekening berhasil disalin ✅"),
                                backgroundColor: Colors.green[600],
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.copy),
                          label: const Text("Salin No. Rekening"),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Upload Bukti Pembayaran",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _pickProof(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                      label: const Text("Dari Galeri"),
                      style: ElevatedButton.styleFrom(
                        // backgroundColor: Colors.blue[600],
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _pickProof(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text("Kamera"),
                      style: ElevatedButton.styleFrom(
                        // backgroundColor: Colors.blueGrey,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (proofFile != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    proofFile!,
                    width: 180,
                    height: 180,
                    fit: BoxFit.cover,
                  ),
                ),
            ],

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  // backgroundColor: Colors.green,
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
