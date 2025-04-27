import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DetailOrderanTahunPage extends StatefulWidget {
  const DetailOrderanTahunPage({super.key});

  @override
  _DetailOrderanTahunPageState createState() => _DetailOrderanTahunPageState();
}

class _DetailOrderanTahunPageState extends State<DetailOrderanTahunPage> {
  List<double> pendapatanBulanan = List.filled(12, 0);
  double totalPendapatan = 0;
  bool isLoading = true;

  String formatCurrency(int amount) {
    final formatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
    return formatter.format(amount);
  }

  int indexBulanTertinggi = -1;

  @override
  void initState() {
    super.initState();
    _getPendapatanTahunIni();
  }

  Future<void> _getPendapatanTahunIni() async {
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
      double totalPrice = (data['total_price'] as num).toDouble();
      DateTime orderDate = (data['timestamp'] as Timestamp).toDate();
      int month = orderDate.month;
      pendapatanBulanan[month - 1] += totalPrice;
    }

    totalPendapatan = pendapatanBulanan.reduce((a, b) => a + b);
    indexBulanTertinggi = pendapatanBulanan.indexWhere(
      (e) => e == pendapatanBulanan.reduce((a, b) => a > b ? a : b),
    );

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Pendapatan Tahun Ini"),
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
                            "Total Pendapatan Tahun Ini",
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
                    "Grafik Pendapatan per Bulan",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      width: 1000, // Lebar total grafik, bisa disesuaikan
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
                          maxY: pendapatanBulanan
                                  .reduce((a, b) => a > b ? a : b) +
                              100000,
                          barTouchData: BarTouchData(
                            enabled: true,
                            touchTooltipData: BarTouchTooltipData(
                              tooltipBgColor: Colors.black87,
                              tooltipPadding: const EdgeInsets.all(8),
                              tooltipMargin:
                                  8, // Atur margin agar tidak terlalu dekat dengan bar
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
                                String value = formatCurrency(rod.toY.toInt());
                                return BarTooltipItem(
                                  '$month\n$value',
                                  const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: pendapatanBulanan.asMap().entries.map((e) {
                            bool isTertinggi = e.key == indexBulanTertinggi;
                            return BarChartGroupData(
                              x: e.key,
                              barRods: [
                                BarChartRodData(
                                  toY: e.value,
                                  color: isTertinggi
                                      ? Colors.orange
                                      : Colors.deepPurple,
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
                  ...pendapatanBulanan.asMap().entries.map((entry) {
                    final monthName = DateFormat('MMMM', 'id_ID')
                        .format(DateTime(0, entry.key + 1));
                    final isTertinggi = entry.key == indexBulanTertinggi;

                    return ListTile(
                      leading: Icon(
                        isTertinggi ? Icons.star : Icons.calendar_month,
                        color: isTertinggi ? Colors.orange : Colors.deepPurple,
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
                        formatCurrency(entry.value.toInt()),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isTertinggi
                              ? Colors.orange.shade800
                              : Colors.black,
                        ),
                      ),
                      subtitle: isTertinggi
                          ? const Text("Pendapatan tertinggi tahun ini 🔥",
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
