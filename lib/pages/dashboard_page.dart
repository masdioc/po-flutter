import 'package:flutter/material.dart';
import 'package:po_app/pages/purchase_order_detail_page.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/purchase_order_provider.dart';
import '../theme/app_colors.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String searchQuery = "";
  String selectedStatus = "Semua"; // <-- filter status
  final currencyFormatter = NumberFormat.currency(
    locale: 'id_ID', // format Rupiah
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  String? userRole;

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userRole = prefs.getString('userRole') ?? "";
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PurchaseOrderProvider>(context, listen: false)
          .fetchOrders(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 2,
          backgroundColor: AppColors
              .primary, // atau AppColors.primary kalau mau pakai warna utama
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
          ),
          automaticallyImplyLeading: false,
          titleSpacing: 16,
          toolbarHeight: 90, // 👉 kontrol tinggi AppBar biar lega
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo kiri
              Image.asset(
                "assets/logo-bgn.png",
                height: 52,
                width: 52,
              ),

              const SizedBox(width: 12),

              // Teks kanan logo
              Expanded(
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // 👉 benar2 center vertikal
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Dapur BGN Ciawigebang",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis, // biar ga kepanjangan
                    ),
                    Text(
                      "AKSES ROLE: ${(userRole ?? 'UNKNOWN').toUpperCase()}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Text(
                      "Mitra BGN",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: Consumer<PurchaseOrderProvider>(
          builder: (context, provider, _) {
            // final totalPO = provider.orders.length;
            final orderPO = provider.orders
                .where((po) => po.status.toLowerCase() == 'order')
                .length;
            final invoicePO = provider.orders
                .where((po) => po.status.toLowerCase() == 'invoice')
                .length;
            final paidPO = provider.orders
                .where((po) => po.status.toLowerCase() == 'paid')
                .length;

            // --- urutkan pending dulu + id desc ---
            final sortedOrders = [...provider.orders];
            sortedOrders.sort((a, b) {
              String sa = a.status.toLowerCase();
              String sb = b.status.toLowerCase();

              // Prioritas status "order"
              if (sa == 'order' && sb != 'order') return -1;
              if (sa != 'order' && sb == 'order') return 1;

              // Prioritas status "invoice"
              if (sa == 'invoice' && sb != 'invoice') return -1;
              if (sa != 'invoice' && sb == 'invoice') return 1;

              // Kalau sama2 order/invoice/atau status lain, urutkan berdasarkan id desc
              return b.id.compareTo(a.id);
            });

            // --- filter by search & status ---
            final filteredOrders = sortedOrders.where((po) {
              final matchesSearch = po.orderNumber
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase());

              final matchesStatus = selectedStatus == "Semua"
                  ? true
                  : po.status.toLowerCase() == selectedStatus.toLowerCase();

              return matchesSearch && matchesStatus;
            }).toList();

            final recentPO = filteredOrders.take(10).toList();

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // summary cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          title: "Order",
                          value: orderPO.toString(),
                          color: Colors.orange,
                          icon: Icons.pending_actions,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSummaryCard(
                          title: "Invoice",
                          value: invoicePO.toString(),
                          color: Colors.blue,
                          icon: Icons.pending_actions,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSummaryCard(
                          title: "Paid",
                          value: paidPO.toString(),
                          color: Colors.green,
                          icon: Icons.list_alt,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Search + Filter
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: "Cari nomor PO...",
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                          onChanged: (value) {
                            setState(() {
                              searchQuery = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      DropdownButton<String>(
                        value: selectedStatus,
                        items: const [
                          DropdownMenuItem(
                              value: "Semua", child: Text("Semua")),
                          DropdownMenuItem(
                              value: "order", child: Text("order")),
                          DropdownMenuItem(
                              value: "invoice", child: Text("invoice")),
                          DropdownMenuItem(value: "Paid", child: Text("Paid")),
                          DropdownMenuItem(
                              value: "cancel", child: Text("cancel")),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedStatus = value!;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Recent PO",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon:
                            const Icon(Icons.refresh, color: AppColors.primary),
                        onPressed: () {
                          Provider.of<PurchaseOrderProvider>(context,
                                  listen: false)
                              .fetchOrders(context);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

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
                                          color: po.status.toLowerCase() ==
                                                  "paid"
                                              ? Colors.green.withOpacity(0.15)
                                              : (po
                                                          .status
                                                          .toLowerCase() ==
                                                      "order"
                                                  ? Colors.orange
                                                      .withOpacity(0.15)
                                                  : (po
                                                              .status
                                                              .toLowerCase() ==
                                                          "invoice"
                                                      ? Colors.blue
                                                          .withOpacity(0.15)
                                                      : Colors.red
                                                          .withOpacity(0.15))),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                            color: po.status.toLowerCase() ==
                                                    "paid"
                                                ? Colors.green
                                                : (po.status.toLowerCase() ==
                                                        "order"
                                                    ? Colors.orange
                                                    : (po.status.toLowerCase() ==
                                                            "invoice"
                                                        ? Colors.blue
                                                        : Colors.red)),
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              po.status.toLowerCase() == "paid"
                                                  ? Icons.check_circle
                                                  : (po.status.toLowerCase() ==
                                                          "order"
                                                      ? Icons.shopping_cart
                                                      : (po.status.toLowerCase() ==
                                                              "invoice"
                                                          ? Icons.receipt_long
                                                          : Icons.cancel)),
                                              size: 16,
                                              color: po.status.toLowerCase() ==
                                                      "paid"
                                                  ? Colors.green
                                                  : (po.status.toLowerCase() ==
                                                          "order"
                                                      ? Colors.orange
                                                      : (po.status.toLowerCase() ==
                                                              "invoice"
                                                          ? Colors.blue
                                                          : Colors.red)),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              po.status.toUpperCase(),
                                              style: TextStyle(
                                                color: po.status
                                                            .toLowerCase() ==
                                                        "paid"
                                                    ? Colors.green[800]
                                                    : (po.status.toLowerCase() ==
                                                            "order"
                                                        ? Colors.orange[800]
                                                        : (po.status.toLowerCase() ==
                                                                "invoice"
                                                            ? Colors.blue[800]
                                                            : Colors.red[800])),
                                                fontWeight: FontWeight.w700,
                                                fontSize: 13,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        currencyFormatter.format(po.total),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                            fontSize: 12),
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
        ));
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // CircleAvatar(
            //   backgroundColor: color.withOpacity(0.2),
            //   child: Icon(icon, color: color),
            // ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500)),
                Text(value,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: color)),
              ],
            )
          ],
        ),
      ),
    );
  }
}
