import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:po_app/pages/payment_page.dart';
import '../models/purchase_order.dart';

class PurchaseOrderDetailPage extends StatefulWidget {
  final PurchaseOrder po;

  const PurchaseOrderDetailPage({super.key, required this.po});

  @override
  State<PurchaseOrderDetailPage> createState() =>
      _PurchaseOrderDetailPageState();
}

class _PurchaseOrderDetailPageState extends State<PurchaseOrderDetailPage> {
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
            Text("Nomor Order: ${widget.po.orderNumber}",
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Tanggal: ${widget.po.orderDate}"),
            Text("Status: ${widget.po.status}"),
            Text("Total: ${currencyFormatter.format(widget.po.total)}"),
            const SizedBox(height: 20),
            const Text("Detail Item:",
                style: TextStyle(fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: widget.po.items.length,
                itemBuilder: (context, index) {
                  final item = widget.po.items[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      title: Text(item.name),
                      subtitle: Text(
                          "${item.qty} x ${currencyFormatter.format(item.priceBuy)}"),
                      trailing: Text(
                        currencyFormatter.format(item.qty * item.priceBuy),
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
      bottomNavigationBar: widget.po.status != "paid"
          ? SafeArea(
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
                    onPressed: () async {
                      // Panggil PaymentPage
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

                        // Kirim PO yang diperbarui kembali ke halaman list
                        Navigator.pop(context, poAfterPayment);

                        // ScaffoldMessenger.of(context).showSnackBar(
                        //   const SnackBar(
                        //       content:
                        //           Text("Status PO diperbarui menjadi Paid")),
                        // );
                      }
                    },
                    child: const Text(
                      "Bayar Sekarang",
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
