import 'package:flutter/material.dart';
import 'kasir.dart'; // Ganti dengan import halaman Kasir yang sesuai
import 'layanan.dart'; // Ganti dengan import halaman Layanan yang sesuai
import 'laporan_bulanan.dart'; // Ganti dengan import halaman Laporan Bulanan yang sesuai
import 'pengaturan.dart'; // Ganti dengan import halaman Pengaturan yang sesuai
import 'package:fl_chart/fl_chart.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _selectedIndex = 0;

  // Data Dummy untuk Grafik Statistik
  final List<FlSpot> _chartData = [
    const FlSpot(1, 120),
    const FlSpot(2, 110),
    const FlSpot(3, 130),
    const FlSpot(4, 125),
    const FlSpot(5, 135),
    const FlSpot(6, 140),
    const FlSpot(7, 150),
    const FlSpot(8, 145),
    const FlSpot(9, 148),
    const FlSpot(10, 152),
    const FlSpot(11, 155),
    const FlSpot(12, 160),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kotak Ringkasan
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryCard("Total Income", "Rp. 1.430.000", Colors.blue),
                _buildSummaryCard("Total Orders", "150", Colors.black),
                _buildSummaryCard("Total Users", "75", Colors.blue),
              ],
            ),
            const SizedBox(height: 20),

            // Grafik Statistik Pesanan
            const Text(
              "Statistik Pesanan",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          return Text(value.toInt().toString(),
                              style: const TextStyle(fontSize: 12));
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const months = [
                            "Jan", "Feb", "Mar", "Apr", "Mei", "Jun",
                            "Jul", "Aug", "Sep", "Okt", "Nov", "Des"
                          ];
                          return Text(months[value.toInt() - 1],
                              style: const TextStyle(fontSize: 12));
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _chartData,
                      isCurved: true,
                      barWidth: 3,
                      color: Colors.blue,
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withOpacity(0.2),
                      ),
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Tabel Pesanan Baru
            const Text(
              "Pesanan Baru-baru Ini",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildRecentOrdersTable(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // Widget Kotak Ringkasan
  Widget _buildSummaryCard(String title, String value, Color valueColor) {
    return Expanded(
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(
                value,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: valueColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget Tabel Pesanan
  Widget _buildRecentOrdersTable() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("No", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text("Nama", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text("Layanan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text("Harga", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text("Status", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const ListTile(
            leading: Text("1", style: TextStyle(fontWeight: FontWeight.bold)),
            title: Text("Aulia"),
            subtitle: Text("Cuci Kering - Baju (1Kg)"),
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("Rp. 40.000", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("Diproses", style: TextStyle(color: Colors.orange)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Bottom Navigation Bar
  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home, color: _selectedIndex == 0 ? Colors.blue : Colors.grey),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people, color: _selectedIndex == 1 ? Colors.blue : Colors.grey),
          label: 'Kasir',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.local_laundry_service, color: _selectedIndex == 2 ? Colors.blue : Colors.grey),
          label: 'Layanan',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart, color: _selectedIndex == 3 ? Colors.blue : Colors.grey),
          label: 'Laporan Bulanan',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings, color: _selectedIndex == 4 ? Colors.blue : Colors.grey),
          label: 'Pengaturan',
        ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      backgroundColor: Colors.white,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      iconSize: 20,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
        switch (index) {
          case 0:
            // Tetap di halaman Dashboard
            break;
          case 1:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const KasirPage()), // Ganti dengan halaman Kasir yang sesuai
            );
            break;
          case 2:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LayananPage()), // Ganti dengan halaman Layanan yang sesuai
            );
            break;
          case 3:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LaporanBulananPage()), // Ganti dengan halaman Laporan Bulanan yang sesuai
            );
            break;
          case 4:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PengaturanAdminPage()), // Ganti dengan halaman Pengaturan yang sesuai
            );
            break;
        }
      },
    );
  }
}