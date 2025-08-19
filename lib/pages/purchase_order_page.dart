import 'package:flutter/material.dart';
import 'package:po_app/pages/purchase_order_detail_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/purchase_order_provider.dart';
import '../theme/app_colors.dart';
import '../pages/add_purchase_order_page.dart' as add_po;
import '../models/purchase_order.dart';
import 'package:intl/intl.dart';

class PurchaseOrderPage extends StatefulWidget {
  const PurchaseOrderPage({super.key});

  @override
  State<PurchaseOrderPage> createState() => _PurchaseOrderPageState();
}

class _PurchaseOrderPageState extends State<PurchaseOrderPage> {
  final currencyFormatter =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  final dateFormatter = DateFormat("dd MMM yyyy");
  String? userRole; // role user dari SharedPreferences
  String filterType = "Semua"; // Semua, Bulan, Tahun
  String? selectedMonth;
  String? selectedYear;

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userRole = prefs.getString('userRole') ?? ""; // default kosong
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

  List<PurchaseOrder> _applyFilter(List<PurchaseOrder> orders) {
    if (filterType == "Semua") return orders;

    return orders.where((po) {
      final date = DateTime.tryParse(po.orderDate);
      if (date == null) return false;

      if (filterType == "Bulan" && selectedMonth != null) {
        return date.month.toString() == selectedMonth;
      } else if (filterType == "Tahun" && selectedYear != null) {
        return date.year.toString() == selectedYear;
      }
      return true;
    }).toList();
  }

  /// ✅ Helper: styling status label
  Widget _buildStatusBadge(String status) {
    final statusLower = status.toLowerCase();

    // Mapping warna & ikon sesuai status
    final Map<String, Map<String, dynamic>> statusStyles = {
      "paid": {
        "bg": Colors.green[100],
        "text": Colors.green[800],
        "icon": Icons.check_circle,
      },
      "order": {
        "bg": Colors.orange[100],
        "text": Colors.orange[800],
        "icon": Icons.shopping_cart,
      },
      "invoice": {
        "bg": Colors.blue[100],
        "text": Colors.blue[800],
        "icon": Icons.receipt_long,
      },
      "pending": {
        "bg": Colors.amber[100],
        "text": Colors.amber[800],
        "icon": Icons.access_time,
      },
      "cancel": {
        "bg": Colors.red[100],
        "text": Colors.red[800],
        "icon": Icons.cancel,
      },
    };

    final style = statusStyles[statusLower] ??
        {
          "bg": Colors.grey[200],
          "text": Colors.grey[800],
          "icon": Icons.help_outline,
        };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: style["bg"],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            style["icon"],
            size: 16,
            color: style["text"],
          ),
          const SizedBox(width: 6),
          Text(
            status.toUpperCase(), // Selalu UPPERCASE
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: style["text"],
              fontSize: 13,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
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
        title: const Text(
          "📑 Daftar Purchase Order",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: "Refresh",
            onPressed: () async {
              final provider =
                  Provider.of<PurchaseOrderProvider>(context, listen: false);
              await provider.fetchOrders(context);
              setState(() {}); // pastikan UI diperbarui
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list_rounded, color: Colors.white),
            color: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (val) {
              setState(() {
                filterType = val;
                selectedMonth = null;
                selectedYear = null;
              });
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: "Semua",
                child: Row(
                  children: [
                    Icon(Icons.all_inbox, color: Colors.blueAccent),
                    SizedBox(width: 10),
                    Text("Semua Data"),
                  ],
                ),
              ),
              PopupMenuItem(
                value: "Bulan",
                child: Row(
                  children: [
                    Icon(Icons.calendar_month, color: Colors.green),
                    SizedBox(width: 10),
                    Text("Filter Bulan"),
                  ],
                ),
              ),
              PopupMenuItem(
                value: "Tahun",
                child: Row(
                  children: [
                    Icon(Icons.date_range, color: Colors.deepOrange),
                    SizedBox(width: 10),
                    Text("Filter Tahun"),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<PurchaseOrderProvider>(
        builder: (context, provider, _) {
          List<PurchaseOrder> poList = _applyFilter(provider.orders);

          if (poList.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.inbox_outlined, size: 60, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    "Belum ada Purchase Order",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              if (filterType == "Bulan")
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButtonFormField<String>(
                    value: selectedMonth,
                    decoration: const InputDecoration(
                      labelText: "Pilih Bulan",
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: List.generate(12, (i) {
                      final month = (i + 1).toString();
                      return DropdownMenuItem(
                        value: month,
                        child: Text("Bulan $month"),
                      );
                    }),
                    onChanged: (val) => setState(() => selectedMonth = val),
                  ),
                ),
              if (filterType == "Tahun")
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButtonFormField<String>(
                    value: selectedYear,
                    decoration: const InputDecoration(
                      labelText: "Pilih Tahun",
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: List.generate(5, (i) {
                      final year = DateTime.now().year - i;
                      return DropdownMenuItem(
                        value: year.toString(),
                        child: Text(year.toString()),
                      );
                    }),
                    onChanged: (val) => setState(() => selectedYear = val),
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: poList.length,
                  itemBuilder: (context, index) {
                    final po = poList[index];
                    final date =
                        DateTime.tryParse(po.orderDate) ?? DateTime.now();

                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary.withOpacity(0.2),
                          child: const Icon(Icons.list_alt,
                              color: AppColors.primary),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        title: Text(
                          po.orderNumber,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Tanggal: ${dateFormatter.format(date)}"),
                            Text(
                                "Total: ${currencyFormatter.format(po.total)}"),
                          ],
                        ),
                        trailing: _buildStatusBadge(po.status),
                        onTap: () async {
                          final updatedPO = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PurchaseOrderDetailPage(po: po),
                            ),
                          );
                          if (updatedPO != null) {
                            final index = provider.orders
                                .indexWhere((e) => e.id == updatedPO.id);
                            if (index != -1) {
                              provider.orders[index] =
                                  updatedPO; // update list lokal
                              provider.notifyListeners();
                            }
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: (userRole == "mitra" || userRole == "dapur")
          ? FloatingActionButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const add_po.AddPurchaseOrderPage()),
                );
                final provider =
                    Provider.of<PurchaseOrderProvider>(context, listen: false);
                await provider.fetchOrders(context);
              },
              backgroundColor: Colors.blueAccent,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
