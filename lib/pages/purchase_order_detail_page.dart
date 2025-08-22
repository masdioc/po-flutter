import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:po_app/config/app_config.dart';
import 'package:po_app/pages/payment_page.dart';
import 'package:po_app/theme/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../models/purchase_order.dart';
import '../providers/purchase_order_provider.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'dart:io';

class PurchaseOrderDetailPage extends StatefulWidget {
  final PurchaseOrder po;

  const PurchaseOrderDetailPage({super.key, required this.po});

  @override
  State<PurchaseOrderDetailPage> createState() =>
      _PurchaseOrderDetailPageState();
}

class _PurchaseOrderDetailPageState extends State<PurchaseOrderDetailPage> {
  String? userRole;
  late List<TextEditingController> buyControllers;
  late List<TextEditingController> sellControllers;
  late TextEditingController dueDateController;
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    _loadUserRole();

    buyControllers = widget.po.items
        .map((e) => TextEditingController(
            text: e.priceBuy % 1 == 0
                ? e.priceBuy.toInt().toString()
                : e.priceBuy.toString()))
        .toList();

    sellControllers = widget.po.items
        .map((e) => TextEditingController(
            text: e.priceSell % 1 == 0
                ? e.priceSell.toInt().toString()
                : e.priceSell.toString()))
        .toList();
    // init controller due_date
    dueDateController = TextEditingController(
      text: widget.po.dueDate ?? '', // ambil dari server
    );
  }

  Future<void> _showPaymentProof(int id) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final savePath = "${dir.path}/payment_proof_$id.jpg";
      final dio = Dio();
      String baseUrl = AppConfig.apiUrl;
      final response = await dio.get("$baseUrl/payment-proof/$id");

      if (response.statusCode == 200) {
        final url = response.data['url'];

        await dio.download(
          url,
          savePath,
          onReceiveProgress: (count, total) {
            print("Progress: ${(count / total * 100).toStringAsFixed(0)}%");
          },
        );

        await OpenFilex.open(savePath); // buka PDF
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal tampilkan bukti pembayaran')),
        );
      }
    }
  }

  Future<void> _downloadInvoice(int id) async {
    try {
      String baseUrl = AppConfig.apiUrl;
      final dir = await getApplicationDocumentsDirectory();
      final savePath = "${dir.path}/invoice_po.pdf";
      print(baseUrl);
      final dio = Dio();

      final response = await dio.get(
        "$baseUrl/invoice/$id", // ganti sesuai domain API
        options: Options(responseType: ResponseType.bytes),
      );

      final file = File(savePath);
      await file.writeAsBytes(response.data);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invoice berhasil diunduh: $savePath')),
        );
      }

      await OpenFilex.open(savePath);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal download invoice: $e')),
        );
      }
    }
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userRole = prefs.getString('userRole') ?? "";
    });
  }

  void _applyChangesToItems() {
    for (int i = 0; i < widget.po.items.length; i++) {
      final item = widget.po.items[i];
      item.priceBuy = double.tryParse(buyControllers[i].text) ?? 0;
      item.priceSell = double.tryParse(sellControllers[i].text) ?? 0;
    }
    // Update total harga jual lokal
    final totalSell = widget.po.items
        .fold<double>(0, (sum, item) => sum + (item.qty * item.priceSell));
    setState(() {
      widget.po.total = totalSell;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    // Hitung tanggal jatuh tempo untuk mitra
    DateTime? dueDate;
    if (userRole == "mitra") {
      try {
        final poDate = DateFormat('yyyy-MM-dd').parse(widget.po.orderDate);
        dueDate =
            poDate.add(const Duration(days: 7)); // misal 7 hari dari order date
      } catch (_) {
        dueDate = null;
      }
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("Detail PO ${widget.po.orderNumber}"),
        backgroundColor: AppColors.primary,
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
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Detail Purchase Order",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),

                    // No. PO
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("No. PO:",
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        Text(widget.po.orderNumber),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Tanggal PO
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Tanggal Order:",
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        Text(widget.po.orderDate),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Tanggal Jatuh Tempo
                    // Tanggal Jatuh Tempo
                    if (dueDateController.text.isNotEmpty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Tgl. Jatuh Tempo:",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          SizedBox(
                            width: 150, // lebar untuk field/tanggal
                            child: userRole == "mitra"
                                ? TextField(
                                    controller: dueDateController,
                                    readOnly: true,
                                    textAlign: TextAlign.right,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      isDense: true,
                                      suffixIcon: Icon(Icons.calendar_today),
                                    ),
                                    onTap: () async {
                                      DateTime initialDate = DateTime.tryParse(
                                              dueDateController.text) ??
                                          DateTime.now();
                                      DateTime firstDate = DateTime.now();
                                      DateTime lastDate = DateTime(2100);

                                      DateTime? picked = await showDatePicker(
                                        context: context,
                                        initialDate: initialDate,
                                        firstDate: firstDate,
                                        lastDate: lastDate,
                                      );

                                      if (picked != null) {
                                        dueDateController.text =
                                            DateFormat('yyyy-MM-dd')
                                                .format(picked);
                                        setState(() {});
                                      }
                                    },
                                  )
                                : Text(
                                    dueDateController.text,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                    textAlign: TextAlign.right,
                                  ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 8),

                    // Total Harga Jual
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total Harga Jual:",
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        Text(
                          currencyFormatter.format(
                            widget.po.items.fold<double>(
                              0,
                              (sum, item) => sum + (item.qty * item.priceSell),
                            ),
                          ),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text("Detail Item:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: widget.po.items.length,
                itemBuilder: (context, index) {
                  final item = widget.po.items[index];

                  // Hitung subtotal per item
                  final subtotal = item.qty * item.priceSell;

                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.name,
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          Text("Qty: ${item.qty}"),
                          const SizedBox(height: 10),
                          if (userRole == "mitra") ...[
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: buyControllers[index],
                                    decoration: const InputDecoration(
                                      labelText: "Harga Beli",
                                      prefixText: "Rp ",
                                      border: OutlineInputBorder(),
                                      isDense: true,
                                    ),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    controller: sellControllers[index],
                                    decoration: const InputDecoration(
                                      labelText: "Harga Jual",
                                      prefixText: "Rp ",
                                      border: OutlineInputBorder(),
                                      isDense: true,
                                    ),
                                    keyboardType: TextInputType.number,
                                    onChanged: (_) {
                                      setState(
                                          () {}); // update subtotal secara realtime
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ] else ...[
                            Text(
                              "Harga Jual: ${currencyFormatter.format(item.priceSell)}",
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              "Subtotal: ${currencyFormatter.format(subtotal)}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

// Total Harga Jual di bawah list
            // Container(
            //   padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            //   margin: const EdgeInsets.symmetric(vertical: 8),
            //   decoration: BoxDecoration(
            //     color: Colors.grey[100],
            //     borderRadius: BorderRadius.circular(12),
            //   ),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
            //       const Text(
            //         "Total Harga Jual:",
            //         style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            //       ),
            //       Text(
            //         currencyFormatter.format(
            //           widget.po.items.fold<double>(
            //             0,
            //             (sum, item) => sum + (item.qty * item.priceSell),
            //           ),
            //         ),
            //         style: const TextStyle(
            //             fontWeight: FontWeight.bold,
            //             fontSize: 16,
            //             color: Colors.blue),
            //       ),
            //     ],
            //   ),
            // ),
            // if (widget.po.status == "paid")
            //   SizedBox(
            //     width: double.infinity,
            //     height: 50,
            //     child: ElevatedButton.icon(
            //       icon: const Icon(Icons.receipt_long),
            //       label: const Text(
            //         "🧾 Tampilkan Bukti Pembayaran",
            //         style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            //       ),
            //       style: ElevatedButton.styleFrom(
            //         backgroundColor: Colors.blue,
            //         shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(12),
            //         ),
            //       ),
            //       onPressed: () async {
            //         await _showPaymentProof(int.parse(widget.po.id));
            //       },
            //     ),
            //   ),

            if (userRole == "mitra" && widget.po.status == "order")
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    // Terapkan perubahan lokal dulu agar controller terbaru terbaca
                    _applyChangesToItems();

                    // Cek apakah ada harga beli atau harga jual yang masih 0
                    final hasZeroPrice = widget.po.items.any(
                        (item) => item.priceBuy <= 0 || item.priceSell <= 0);

                    if (hasZeroPrice) {
                      // Tampilkan snackbar / alert
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Pastikan semua harga tidak 0!')),
                      );
                      return; // hentikan proses
                    }

                    // Tampilkan dialog konfirmasi
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Konfirmasi'),
                        content: const Text(
                            'Apakah semua data sudah benar? Jika ya, status akan berubah menjadi Invoice / Tagihan.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Batal'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Ya, Ubah Status'),
                          ),
                        ],
                      ),
                    );

                    if (confirm != true) return;

                    final payload = {
                      "supplier_id": widget.po.supplierId,
                      "order_number": widget.po.orderNumber,
                      "order_date": widget.po.orderDate,
                      "due_date": dueDateController.text,
                      "status": 'invoice',
                      "items":
                          widget.po.items.map((item) => item.toJson()).toList(),
                    };

                    setState(() => _isLoading = true);

                    try {
                      final provider = Provider.of<PurchaseOrderProvider>(
                          context,
                          listen: false);

                      // Update di server
                      await provider.updatePOOrder(
                          context, widget.po.id, payload);

                      // Update lokal provider
                      provider.updateLocalPO(int.parse(widget.po.id), payload);

                      // Update objek lokal agar UI detail page ikut berubah
                      setState(() {
                        widget.po.status = 'invoice';
                      });

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('PO berhasil diperbarui')),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Gagal update PO: $e')),
                        );
                      }
                    } finally {
                      if (mounted) setState(() => _isLoading = false);
                    }
                  },
                  child: const Text("💾 Simpan Perubahan",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: (widget.po.status == "invoice" ||
              widget.po.status == "paid")
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Tampilkan tombol Bayar kalau status = invoice & role = finance
                    if (widget.po.status == "invoice" && userRole == "finance")
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
                          onPressed: () async {
                            final poAfterPayment = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    PaymentPage(po: widget.po),
                              ),
                            );

                            if (poAfterPayment != null) {
                              setState(() {
                                widget.po.status = poAfterPayment.status;
                              });

                              Navigator.pop(context, poAfterPayment);
                            }
                          },
                          child: const Text(
                            "💳 Bayar Sekarang",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),

                    // Tombol download invoice selalu ada kalau status invoice/paid
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.picture_as_pdf),
                        label: const Text(
                          "📄 Download Invoice",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          await _downloadInvoice(int.parse(widget.po.id));
                        },
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Tombol tampilkan bukti pembayaran kalau status = paid
                    if (widget.po.status == "paid")
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.receipt_long),
                          label: const Text(
                            "🧾 Tampilkan Bukti Pembayaran",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            await _showPaymentProof(int.parse(widget.po.id));
                          },
                        ),
                      ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}
