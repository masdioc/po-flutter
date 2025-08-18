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
        elevation: 3,
        backgroundColor: AppColors.primary,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/logo-bgn.png", height: 52, width: 52),
            const SizedBox(width: 8),
            const Text(
              "Dapur BGN Ciawigebang",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
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
          final paidPO = provider.orders
              .where((po) => po.status.toLowerCase() == 'paid')
              .length;
          final recentPO = provider.orders.reversed.take(10).toList();

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    "AKSES ROLE: ${(userRole ?? 'UNKNOWN').toUpperCase()}",
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 45, 44, 44)),
                  ),
                ),
                const SizedBox(height: 12),
                const Center(
                  child: Text(
                    "Supporting Mitra BGN",
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 45, 44, 44)),
                  ),
                ),
                const SizedBox(height: 16),

                // summary cards
                Row(
                  children: [
                    Expanded(
                        child: _SummaryCard(
                            title: "Total PO", value: totalPO.toString())),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _SummaryCard(
                            title: "Pending PO", value: pendingPO.toString())),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _SummaryCard(
                            title: "Paid", value: paidPO.toString())),
                  ],
                ),

                const SizedBox(height: 24),

                // Chart Summary
                ChartSummary(total: totalPO, pending: pendingPO, paid: paidPO),

                const SizedBox(height: 24),

                const Text("Recent PO",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),

                Expanded(
                  child: ListPO(
                    recentPO: recentPO,
                    provider: provider,
                    currencyFormatter: currencyFormatter,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;

  const _SummaryCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    final vStyle = Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w800,
          color: const Color(0xFF111827),
        );
    final tStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
          color: const Color(0xFF6B7280),
        );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 235, 233, 233),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: vStyle, maxLines: 2),
          const SizedBox(height: 2),
          Text(title, style: tStyle),
        ],
      ),
    );
  }
}
