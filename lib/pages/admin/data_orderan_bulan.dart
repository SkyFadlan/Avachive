import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DataOrderBulan extends StatefulWidget {
  const DataOrderBulan({super.key});

  @override
  _DataOrderBulanState createState() => _DataOrderBulanState();
}

class _DataOrderBulanState extends State<DataOrderBulan> {
  List<int> jumlahOrderMingguan = List.filled(4, 0);
  int totalOrderan = 0;
  bool isLoading = true;
  int indexMingguTertinggi = -1;

  @override
  void initState() {
    super.initState();
    _getJumlahOrderanBulanIni();
  }

  Future<void> _getJumlahOrderanBulanIni() async {
    DateTime now = DateTime.now();
    DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
    DateTime lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('orderan')
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(firstDayOfMonth))
        .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(lastDayOfMonth))
        .get();

    for (var doc in snapshot.docs) {
      DateTime orderDate = (doc['timestamp'] as Timestamp).toDate();
      int weekOfMonth = ((orderDate.day - 1) / 7).floor();

      if (weekOfMonth < 4) {
        jumlahOrderMingguan[weekOfMonth]++;
      }
    }

    totalOrderan = jumlahOrderMingguan.reduce((a, b) => a + b);

    indexMingguTertinggi = jumlahOrderMingguan.indexWhere(
      (e) => e == jumlahOrderMingguan.reduce((a, b) => a > b ? a : b),
    );

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Orderan Bulan Ini"),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Total Orderan Bulan Ini",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "$totalOrderan order",
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.w600, color: Colors.green),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Grafik Jumlah Order per Minggu",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 250,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 6)],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: (jumlahOrderMingguan.reduce((a, b) => a > b ? a : b)).toDouble() + 1,
                        barTouchData: BarTouchData(enabled: true),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: true, reservedSize: 40),
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
                        barGroups: jumlahOrderMingguan.asMap().entries.map((e) {
                          return BarChartGroupData(
                            x: e.key,
                            barRods: [
                              BarChartRodData(
                                toY: e.value.toDouble(),
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
                  ...jumlahOrderMingguan.asMap().entries.map((entry) {
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
                          color: isTertinggi ? Colors.orange.shade800 : Colors.black,
                        ),
                      ),
                      trailing: Text(
                        "${entry.value} order",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isTertinggi ? Colors.orange.shade800 : Colors.black,
                        ),
                      ),
                      subtitle: isTertinggi
                          ? const Text("Jumlah orderan tertinggi minggu ini 🔥",
                              style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12))
                          : null,
                    );
                  }).toList(),
                ],
              ),
            ),
    );
  }
}
