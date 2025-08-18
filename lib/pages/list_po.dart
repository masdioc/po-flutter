import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:po_app/pages/purchase_order_detail_page.dart';
import '../theme/app_colors.dart';
import '../providers/purchase_order_provider.dart';
import '../models/purchase_order.dart';

class ListPO extends StatelessWidget {
  final List<PurchaseOrder> recentPO;
  final PurchaseOrderProvider provider;
  final NumberFormat currencyFormatter;

  const ListPO({
    super.key,
    required this.recentPO,
    required this.provider,
    required this.currencyFormatter,
  });

  @override
  Widget build(BuildContext context) {
    if (recentPO.isEmpty) {
      return const Center(
        child: Text("Belum ada PO", style: TextStyle(color: Colors.grey)),
      );
    }
    final sortedPO = [...recentPO]..sort((a, b) => b.id.compareTo(a.id));
    return ListView.builder(
      itemCount: sortedPO.length,
      itemBuilder: (context, index) {
        final po = sortedPO[index];
        return Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 3,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.2),
              child: const Icon(Icons.list_alt, color: AppColors.primary),
            ),
            title: Text(
              po.orderNumber,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text("Tanggal: ${po.orderDate}"),
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: po.status.toLowerCase() == "paid"
                        ? Colors.green[100]
                        : (po.status.toLowerCase() == "pending"
                            ? Colors.orange[100]
                            : Colors.red[100]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    po.status,
                    style: TextStyle(
                      color: po.status.toLowerCase() == "paid"
                          ? Colors.green[800]
                          : (po.status.toLowerCase() == "pending"
                              ? Colors.orange[800]
                              : Colors.red[800]),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  currencyFormatter.format(po.total),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            onTap: () async {
              final updatedPO = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PurchaseOrderDetailPage(po: po),
                ),
              );
              if (updatedPO != null) {
                final idx =
                    provider.orders.indexWhere((o) => o.id == updatedPO.id);
                if (idx != -1) {
                  provider.orders[idx] = updatedPO;
                }
              }
            },
          ),
        );
      },
    );
  }
}
