import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DataOrderTahunPage extends StatefulWidget {
  const DataOrderTahunPage({super.key});

  @override
  _DataOrderTahunPageState createState() => _DataOrderTahunPageState();
}

class _DataOrderTahunPageState extends State<DataOrderTahunPage> {
  List<int> jumlahOrderBulanan = List.filled(12, 0);
  int totalOrder = 0;
  bool isLoading = true;

  int indexBulanTertinggi = -1;

  @override
  void initState() {
    super.initState();
    _getOrderTahunIni();
  }

  Future<void> _getOrderTahunIni() async {
    DateTime now = DateTime.now();
    DateTime firstDayOfYear = DateTime(now.year, 1, 1);
    DateTime lastDayOfYear = DateTime(now.year, 12, 31, 23, 59, 59);

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('orderan')
        .where('timestamp',
            isGreaterThanOrEqualTo: Timestamp.fromDate(firstDayOfYear))
        .where('timestamp',
            isLessThanOrEqualTo: Timestamp.fromDate(lastDayOfYear))
        .get();

    for (var doc in snapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      DateTime orderDate = (data['timestamp'] as Timestamp).toDate();
      int month = orderDate.month;
      jumlahOrderBulanan[month - 1] += 1;
    }

    totalOrder = jumlahOrderBulanan.reduce((a, b) => a + b);
    indexBulanTertinggi = jumlahOrderBulanan.indexWhere(
      (e) => e == jumlahOrderBulanan.reduce((a, b) => a > b ? a : b),
    );

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Data Orderan Tahun Ini"),
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
                            "Total Order Tahun Ini",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "$totalOrder order",
                            style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Grafik Jumlah Order per Bulan",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      width: 1000,
                      height: 300,
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
                          groupsSpace: 20,
                          maxY: (jumlahOrderBulanan
                                  .reduce((a, b) => a > b ? a : b)).toDouble() +
                              2,
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                                getTitlesWidget: (value, meta) {
                                  final monthNames = [
                                    "Jan",
                                    "Feb",
                                    "Mar",
                                    "Apr",
                                    "Mei",
                                    "Jun",
                                    "Jul",
                                    "Agu",
                                    "Sep",
                                    "Okt",
                                    "Nov",
                                    "Des"
                                  ];
                                  return Text(
                                    monthNames[value.toInt()],
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  );
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 5,
                                reservedSize: 40,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    value.toInt().toString(),
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 10,
                                    ),
                                  );
                                },
                              ),
                            ),
                            rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                          ),
                          barTouchData: BarTouchData(
                            enabled: true,
                            touchTooltipData: BarTouchTooltipData(
                              tooltipBgColor: Colors.black87,
                              tooltipPadding: const EdgeInsets.all(8),
                              tooltipMargin: 8,
                              getTooltipItem:
                                  (group, groupIndex, rod, rodIndex) {
                                final monthNames = [
                                  "Jan",
                                  "Feb",
                                  "Mar",
                                  "Apr",
                                  "Mei",
                                  "Jun",
                                  "Jul",
                                  "Agu",
                                  "Sep",
                                  "Okt",
                                  "Nov",
                                  "Des"
                                ];
                                String month = monthNames[group.x];
                                String value = rod.toY.toInt().toString();
                                return BarTooltipItem(
                                  '$month\n$value order',
                                  const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups:
                              jumlahOrderBulanan.asMap().entries.map((e) {
                            bool isTertinggi = e.key == indexBulanTertinggi;
                            return BarChartGroupData(
                              x: e.key,
                              barRods: [
                                BarChartRodData(
                                  toY: e.value.toDouble(),
                                  color: isTertinggi
                                      ? Colors.orange
                                      : Colors.blueAccent,
                                  width: 24,
                                  borderRadius: BorderRadius.circular(4),
                                )
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    "Rincian Bulanan",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Divider(thickness: 1.2),
                  const SizedBox(height: 8),
                  ...jumlahOrderBulanan.asMap().entries.map((entry) {
                    final monthName = DateFormat('MMMM', 'id_ID')
                        .format(DateTime(0, entry.key + 1));
                    final isTertinggi = entry.key == indexBulanTertinggi;

                    return ListTile(
                      leading: Icon(
                        isTertinggi ? Icons.star : Icons.calendar_today,
                        color: isTertinggi ? Colors.orange : Colors.blueAccent,
                      ),
                      title: Text(
                        "Bulan $monthName",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isTertinggi
                              ? Colors.orange.shade800
                              : Colors.black,
                        ),
                      ),
                      trailing: Text(
                        "${entry.value} order",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isTertinggi
                              ? Colors.orange.shade800
                              : Colors.black,
                        ),
                      ),
                      subtitle: isTertinggi
                          ? const Text("Jumlah order tertinggi tahun ini 🔥",
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
