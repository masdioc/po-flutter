import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ChartSummary extends StatelessWidget {
  final int total;
  final int order;
  final int invoice;
  final int paid;

  const ChartSummary({
    super.key,
    required this.total,
    required this.order,
    required this.invoice,
    required this.paid,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 220,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 160,
            child: BarChart(
              BarChartData(
                barGroups: [
                  makeGroupData(0, total.toDouble(), order.toDouble(),
                      invoice.toDouble(), paid.toDouble()),
                ],
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        switch (value.toInt()) {
                          case 0:
                            return const Text("PO Summary");
                        }
                        return const Text("");
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: true),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: true),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LegendItem(color: Colors.brown, text: "Total"),
              SizedBox(width: 16),
              LegendItem(color: Colors.orange, text: "Order"),
              SizedBox(width: 16),
              LegendItem(color: Colors.blue, text: "Invoice"),
              SizedBox(width: 16),
              LegendItem(color: Colors.green, text: "Paid"),
            ],
          ),
        ],
      ),
    );
  }

  BarChartGroupData makeGroupData(
      int x, double total, double order, double invoice, double paid) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(toY: total, color: Colors.brown, width: 12),
        BarChartRodData(toY: order, color: Colors.orange, width: 12),
        BarChartRodData(toY: invoice, color: Colors.blue, width: 12),
        BarChartRodData(toY: paid, color: Colors.green, width: 12),
      ],
      barsSpace: 4,
    );
  }
}

class LegendItem extends StatelessWidget {
  final Color color;
  final String text;

  const LegendItem({super.key, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 16, height: 16, color: color),
        const SizedBox(width: 6),
        Text(text),
      ],
    );
  }
}
