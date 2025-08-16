import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/purchase_order_provider.dart';
import '../theme/app_colors.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PurchaseOrderProvider>(
      builder: (context, provider, _) {
        final totalPO = provider.orders.length;
        final pendingPO = provider.orders
            .where((po) => po.status.toLowerCase() == 'pending')
            .length;
        final totalSuppliers = provider.orders
            .map((po) => po.supplierId)
            .toSet()
            .length; // jumlah supplier unik

        final recentPO = provider.orders.reversed.take(5).toList();

        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nama Dapur
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      // Logo di kiri
                      Image.asset(
                        "assets/logo-bgn.png", // ganti sesuai path logo kamu
                        height: 52,
                        width: 52,
                      ),
                      const SizedBox(width: 12),

                      // Teks di tengah
                      const Expanded(
                        child: Text(
                          "Dapur BGN Ciawigebang",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Nama Supplier
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  child: const Center(
                    child: Text(
                      "Suplier CV. ALi Jaya Logistik",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 45, 44, 44)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Summary Cards
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSummaryCard(
                      title: "Total PO",
                      value: totalPO.toString(),
                      color: Colors.blueAccent,
                      icon: Icons.list_alt,
                    ),
                    _buildSummaryCard(
                      title: "Pending PO",
                      value: pendingPO.toString(),
                      color: Colors.orange,
                      icon: Icons.pending_actions,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Recent PO Title
                const Text(
                  "Recent PO",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                // List recent PO
                Expanded(
                  child: recentPO.isEmpty
                      ? const Center(
                          child: Text(
                            "Belum ada PO",
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: recentPO.length,
                          itemBuilder: (context, index) {
                            final po = recentPO[index];
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 3,
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor:
                                      AppColors.primary.withOpacity(0.2),
                                  child: const Icon(Icons.list_alt,
                                      color: AppColors.primary),
                                ),
                                title: Text(po.orderNumber,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Tanggal: ${po.orderDate}"),
                                  ],
                                ),
                                trailing: Text(
                                  "Rp ${po.total.toStringAsFixed(0)}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87),
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
      },
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
    double width = 160,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 14, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
