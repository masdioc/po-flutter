import 'package:flutter/material.dart';
import 'package:po_app/pages/purchase_order_detail_page.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/purchase_order_provider.dart';
import '../theme/app_colors.dart';

import 'chart_summary.dart';
import 'list_po.dart';

class PoSummaryPage extends StatefulWidget {
  const PoSummaryPage({super.key});

  @override
  State<PoSummaryPage> createState() => _PoSummaryPageState();
}

class _PoSummaryPageState extends State<PoSummaryPage> {
  final currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  String searchQuery = "";
  String selectedStatus = "Semua"; // <-- filter status

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
            final totalPO = provider.orders.length;
            final pendingPO = provider.orders
                .where((po) => po.status.toLowerCase() == 'pending')
                .length;
            final paidPO = provider.orders
                .where((po) => po.status.toLowerCase() == 'paid')
                .length;

            // --- urutkan pending dulu + id desc ---
            final sortedOrders = [...provider.orders];
            sortedOrders.sort((a, b) {
              if (a.status.toLowerCase() == 'pending' &&
                  b.status.toLowerCase() != 'pending') return -1;
              if (a.status.toLowerCase() != 'pending' &&
                  b.status.toLowerCase() == 'pending') return 1;
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
                        child: _SummaryCard(
                          title: "Totsl",
                          value: totalPO.toString(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SummaryCard(
                          title: "Pending",
                          value: pendingPO.toString(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SummaryCard(
                          title: "Paid",
                          value: paidPO.toString(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Chart Summary
                  ChartSummary(
                      total: totalPO, pending: pendingPO, paid: paidPO),

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
                              value: "Pending", child: Text("Pending")),
                          DropdownMenuItem(value: "Paid", child: Text("Paid")),
                          DropdownMenuItem(
                              value: "Cancelled", child: Text("Cancelled")),
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
                                              : (po.status.toLowerCase() ==
                                                      "pending"
                                                  ? Colors.orange
                                                      .withOpacity(0.15)
                                                  : Colors.red
                                                      .withOpacity(0.15)),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                            color: po.status.toLowerCase() ==
                                                    "paid"
                                                ? Colors.green
                                                : (po.status.toLowerCase() ==
                                                        "pending"
                                                    ? Colors.orange
                                                    : Colors.red),
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
                                                          "pending"
                                                      ? Icons.access_time
                                                      : Icons.cancel),
                                              size: 16,
                                              color: po.status.toLowerCase() ==
                                                      "paid"
                                                  ? Colors.green
                                                  : (po.status.toLowerCase() ==
                                                          "pending"
                                                      ? Colors.orange
                                                      : Colors.red),
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
                                                            "pending"
                                                        ? Colors.orange[800]
                                                        : Colors.red[800]),
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
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;

  const _SummaryCard({required this.title, required this.value, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }
}
