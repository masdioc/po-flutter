import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/purchase_order_provider.dart';
import '../theme/app_colors.dart';
import '../pages/add_purchase_order_page.dart' as add_po;

class PurchaseOrderPage extends StatefulWidget {
  const PurchaseOrderPage({super.key});

  @override
  State<PurchaseOrderPage> createState() => _PurchaseOrderPageState();
}

class _PurchaseOrderPageState extends State<PurchaseOrderPage> {
  @override
  void initState() {
    super.initState();
    // Fetch PO setelah frame pertama
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PurchaseOrderProvider>(context, listen: false)
          .fetchOrders(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Daftar PO"),
        centerTitle: true,
        backgroundColor: AppColors.primary,
      ),
      body: Consumer<PurchaseOrderProvider>(
        builder: (context, provider, _) {
          final poList = provider.orders;

          if (poList.isEmpty) {
            return const Center(
              child: Text(
                "Belum ada Purchase Order",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: poList.length,
            itemBuilder: (context, index) {
              final po = poList[index];
              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  title: Text(
                    po.orderNumber,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Tanggal: ${po.orderDate}"),
                      Text("Total: Rp ${po.total.toStringAsFixed(0)}"),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navigasi ke halaman add PO
          await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const add_po.AddPurchaseOrderPage()),
          );
          // Refresh PO list setelah kembali
          final provider =
              Provider.of<PurchaseOrderProvider>(context, listen: false);
          await provider.fetchOrders(context);
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add),
      ),
    );
  }
}
