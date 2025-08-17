import 'package:flutter/material.dart';
import 'package:po_app/pages/purchase_order_detail_page.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/purchase_order_provider.dart';
import '../theme/app_colors.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PurchaseOrderProvider>(context, listen: false)
          .fetchOrders(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 3,
        backgroundColor: AppColors.primary,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/logo-bgn.png",
              height: 52,
              width: 52,
            ),
            const SizedBox(width: 8),
            const Text(
              "Dapur BGN Ciawigebang",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: "Refresh PO",
            onPressed: () async {
              final provider =
                  Provider.of<PurchaseOrderProvider>(context, listen: false);
              await provider.fetchOrders(context);
              setState(() {});
            },
          ),
        ],
      ),
      body: Consumer<PurchaseOrderProvider>(
        builder: (context, provider, _) {
          final totalPO = provider.orders.length;
          final pendingPO = provider.orders
              .where((po) => po.status.toLowerCase() == 'pending')
              .length;
          final recentPO = provider.orders.reversed.take(10).toList();

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                        color: Color.fromARGB(255, 45, 44, 44),
                      ),
                    ),
                  ),
                ),
                // Summary Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        title: "Total PO",
                        value: totalPO.toString(),
                        color: Colors.blueAccent,
                        icon: Icons.list_alt,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryCard(
                        title: "Pending PO",
                        value: pendingPO.toString(),
                        color: Colors.orange,
                        icon: Icons.pending_actions,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Recent PO
                const Text(
                  "Recent PO",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

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
                                title: Text(
                                  po.orderNumber,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text("Tanggal: ${po.orderDate}"),
                                trailing: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: po.status.toLowerCase() == "paid"
                                            ? Colors.green[100]
                                            : (po.status.toLowerCase() ==
                                                    "pending"
                                                ? Colors.orange[100]
                                                : Colors.red[100]),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        po.status,
                                        style: TextStyle(
                                          color:
                                              po.status.toLowerCase() == "paid"
                                                  ? Colors.green[800]
                                                  : (po.status.toLowerCase() ==
                                                          "pending"
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
                                      builder: (_) =>
                                          PurchaseOrderDetailPage(po: po),
                                    ),
                                  );
                                  if (updatedPO != null) {
                                    final index = provider.orders.indexWhere(
                                        (o) => o.id == updatedPO.id);
                                    if (index != -1) {
                                      provider.orders[index] = updatedPO;
                                      setState(() {});
                                    }
                                  }
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
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
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
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
