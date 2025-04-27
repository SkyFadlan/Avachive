import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DetailOrderanBulanPage extends StatefulWidget {
  const DetailOrderanBulanPage({super.key});

  @override
  _DetailOrderanBulanPageState createState() => _DetailOrderanBulanPageState();
}

class _DetailOrderanBulanPageState extends State<DetailOrderanBulanPage> {
  List<double> pendapatanMingguan = List.filled(4, 0);
  double totalPendapatan = 0;
  bool isLoading = true;
  int indexMingguTertinggi = -1; // Tambahkan ini

  String formatCurrency(int amount) {
    final formatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
    return formatter.format(amount);
  }

  @override
  void initState() {
    super.initState();
    _getPendapatanBulanIni();
  }

  Future<void> _getPendapatanBulanIni() async {
    DateTime now = DateTime.now();
    DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
    DateTime lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('orderan')
        .where('timestamp',
            isGreaterThanOrEqualTo: Timestamp.fromDate(firstDayOfMonth))
        .where('timestamp',
            isLessThanOrEqualTo: Timestamp.fromDate(lastDayOfMonth))
        .get();

    for (var doc in snapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      double totalPrice = (data['total_price'] as num).toDouble();
      DateTime orderDate = (data['timestamp'] as Timestamp).toDate();
      int weekOfMonth = ((orderDate.day - 1) / 7).floor();

      if (weekOfMonth < 4) {
        pendapatanMingguan[weekOfMonth] += totalPrice;
      }
    }

    totalPendapatan = pendapatanMingguan.reduce((a, b) => a + b);

    indexMingguTertinggi = pendapatanMingguan.indexWhere(
      (e) => e == pendapatanMingguan.reduce((a, b) => a > b ? a : b),
    );

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Pendapatan Bulan Ini"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Total Pendapatan Bulan Ini",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            formatCurrency(totalPendapatan.toInt()),
                            style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: Colors.green),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Grafik Pendapatan per Minggu",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 250,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(color: Colors.grey.shade300, blurRadius: 6)
                      ],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY:
                            pendapatanMingguan.reduce((a, b) => a > b ? a : b) +
                                50000,
                        barTouchData: BarTouchData(enabled: true),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles:
                                SideTitles(showTitles: true, reservedSize: 40),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                List<String> minggu = ["M1", "M2", "M3", "M4"];
                                return Text(minggu[value.toInt()]);
                              },
                              interval: 1,
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: pendapatanMingguan.asMap().entries.map((e) {
                          return BarChartGroupData(
                            x: e.key,
                            barRods: [
                              BarChartRodData(
                                toY: e.value,
                                color: Colors.blueAccent,
                                width: 20,
                                borderRadius: BorderRadius.circular(4),
                              )
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    "Rincian Mingguan",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Divider(thickness: 1.2),
                  const SizedBox(height: 8),
                  ...pendapatanMingguan.asMap().entries.map((entry) {
                    final isTertinggi = entry.key == indexMingguTertinggi;

                    return ListTile(
                      leading: Icon(
                        isTertinggi ? Icons.star : Icons.calendar_today,
                        color: isTertinggi ? Colors.orange : Colors.indigo,
                      ),
                      title: Text(
                        "Minggu ke-${entry.key + 1}",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isTertinggi
                              ? Colors.orange.shade800
                              : Colors.black,
                        ),
                      ),
                      trailing: Text(
                        formatCurrency(entry.value.toInt()),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isTertinggi
                              ? Colors.orange.shade800
                              : Colors.black,
                        ),
                      ),
                      subtitle: isTertinggi
                          ? const Text("Pendapatan tertinggi minggu ini 🔥",
                              style: TextStyle(
                                  fontStyle: FontStyle.italic, fontSize: 12))
                          : null,
                    );
                  }).toList(),
                ],
              ),
            ),
    );
  }
}
