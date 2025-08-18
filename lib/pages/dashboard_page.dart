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
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(
              140), // tinggi lebih besar biar semua teks muat
          child: AppBar(
            elevation: 2,
            backgroundColor: AppColors.primary,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            centerTitle: true,
            flexibleSpace: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 16), // kasih jarak atas
                  Image.asset("assets/logo-bgn.png", height: 52, width: 52),
                  const SizedBox(height: 6),
                  const Text(
                    "Dapur BGN Ciawigebang",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "AKSES ROLE: ${(userRole ?? 'UNKNOWN').toUpperCase()}",
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    "Mitra BGN",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                tooltip: "Refresh ",
                onPressed: () async {
                  final provider = Provider.of<PurchaseOrderProvider>(context,
                      listen: false);
                  await provider.fetchOrders(context);
                  setState(() {});
                },
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
                        child: _buildSummaryCard(
                          title: "Pending PO",
                          value: pendingPO.toString(),
                          color: Colors.orange,
                          icon: Icons.pending_actions,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSummaryCard(
                          title: "Paid PO",
                          value: paidPO.toString(),
                          color: Colors.blueAccent,
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
                                          color:
                                              po.status.toLowerCase() == "paid"
                                                  ? Colors.green[100]
                                                  : (po.status.toLowerCase() ==
                                                          "pending"
                                                      ? Colors.orange[100]
                                                      : Colors.red[100]),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          po.status,
                                          style: TextStyle(
                                            color: po.status.toLowerCase() ==
                                                    "paid"
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
            CircleAvatar(
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, color: color),
            ),
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
