import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:po_app/pages/payment_page.dart';
import 'package:po_app/theme/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../models/purchase_order.dart';
import '../providers/purchase_order_provider.dart';

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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("No. PO:",
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        Text(widget.po.orderNumber),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Tanggal:",
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        Text(widget.po.orderDate),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Total Harga Jual:",
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

            if (userRole == "mitra")
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    _applyChangesToItems();

                    final payload = {
                      "supplier_id": widget.po.supplierId,
                      "order_number": widget.po.orderNumber,
                      "order_date": widget.po.orderDate,
                      "status": widget.po.status,
                      "items":
                          widget.po.items.map((item) => item.toJson()).toList(),
                    };

                    try {
                      await Provider.of<PurchaseOrderProvider>(context,
                              listen: false)
                          .updatePOOrder(context, widget.po.id, payload);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('PO berhasil diperbarui')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Gagal update PO: $e')),
                      );
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
      bottomNavigationBar: (widget.po.status != "paid" && userRole == "finance")
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      // backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      final poAfterPayment = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaymentPage(po: widget.po),
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
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }
}
