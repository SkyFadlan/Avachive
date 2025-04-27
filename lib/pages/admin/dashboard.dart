import 'data_bulanan.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Import untuk format tanggal
import 'karyawan.dart'; // Ganti dengan import halaman Kasir yang sesuai
import 'layanan.dart'; // Ganti dengan import halaman Layanan yang sesuai
import 'pelanggan.dart';
import 'pengaturan.dart'; // Ganti dengan import halaman Pengaturan yang sesuai
import 'package:fl_chart/fl_chart.dart';
import 'laporan_bulanan.dart';
import 'detail_pendapatan_bulan.dart'; // Import halaman detail_orderan_bulan.dart
import 'detail_pendapatan_tahun.dart';
import 'data_orderan_bulan.dart';
import 'data_orderan_tahun.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _selectedIndex = 0;

  List<Map<String, dynamic>> _todayOrders = []; // Menyimpan pesanan hari ini
  int _totalIncomeYear = 0;
  int _totalOrdersYear = 0;
  int _totalIncomeMonth = 0;
  int _totalOrdersMonth = 0;
  int _totalCustomers = 0;
  int _totalServices = 0;

  // Data untuk Grafik Statistik
  List<FlSpot> _chartData = [];
  bool _isLoading = true; // Menandakan apakah data sedang dimuat

  @override
  void initState() {
    super.initState();
    _loadData(); // Memuat data saat inisialisasi
  }

  Future<void> _loadData() async {
    await Future.wait([
      _getTodayOrders(),
      _getTotalIncomeAndOrders(),
      _getTotalCustomersAndServices(),
      _getMonthlyOrderData(),
    ]);
    setState(() {
      _isLoading = false; // Data telah dimuat
    });
  }

  String formatCurrency(int amount) {
    final formatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
    return formatter.format(amount);
  }

  Future<void> _getTodayOrders() async {
    DateTime now = DateTime.now();

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('orderan')
        .where('timestamp',
            isGreaterThanOrEqualTo:
                Timestamp.fromDate(DateTime(now.year, now.month, now.day)))
        .where('timestamp',
            isLessThan:
                Timestamp.fromDate(DateTime(now.year, now.month, now.day + 1)))
        .get();

    setState(() {
      _todayOrders = snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        return {
          'customer': (data['customer'] is Map)
              ? data['customer']['name'] ?? 'Tanpa Nama'
              : 'Tanpa Nama',
          'service': data['items'] != null
              ? (data['items'] as List).map((item) => item['name']).join(', ')
              : 'Tidak ada layanan',
          'price': formatCurrency(data['total_price'] ?? 0),
          'status': data['status']?.toString() ?? 'Diproses',
        };
      }).toList();
    });
  }

  Future<void> _getTotalIncomeAndOrders() async {
    DateTime now = DateTime.now();

    // Ambil total pendapatan dan orderan tahun ini
    QuerySnapshot yearSnapshot = await FirebaseFirestore.instance
        .collection('orderan')
        .where('timestamp',
            isGreaterThanOrEqualTo:
                Timestamp.fromDate(DateTime(now.year, 1, 1)))
        .where('timestamp',
            isLessThan: Timestamp.fromDate(DateTime(now.year + 1, 1, 1)))
        .get();

    int totalIncomeYear = 0;
    int totalOrdersYear = yearSnapshot.docs.length;

    for (var doc in yearSnapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      if (data['total_price'] != null) {
        totalIncomeYear += (data['total_price'] as num).toInt();
      }
    }

    // Ambil total pendapatan dan orderan bulan ini
    QuerySnapshot monthSnapshot = await FirebaseFirestore.instance
        .collection('orderan')
 .where('timestamp',
            isGreaterThanOrEqualTo:
                Timestamp.fromDate(DateTime(now.year, now.month, 1)))
        .where('timestamp',
            isLessThan:
                Timestamp.fromDate(DateTime(now.year, now.month + 1, 1)))
        .get();

    int totalIncomeMonth = 0;
    int totalOrdersMonth = monthSnapshot.docs.length;

    for (var doc in monthSnapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      if (data['total_price'] != null) {
        totalIncomeMonth += (data['total_price'] as num).toInt();
      }
    }

    setState(() {
      _totalIncomeYear = totalIncomeYear;
      _totalOrdersYear = totalOrdersYear;
      _totalIncomeMonth = totalIncomeMonth;
      _totalOrdersMonth = totalOrdersMonth;
    });
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    setState(() {
      _selectedIndex = index; // Update the selected index
    });

    final pages = [
      const AdminDashboardPage(),
      const KasirPage(),
      const LayananPage(),
      const AdminPelangganPage(),
      const LaporanBulananPage(), // This should be the Data page
      const PengaturanAdminPage(),
    ];

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => pages[index]),
    );
  }

  Future<void> _getTotalCustomersAndServices() async {
    try {
      QuerySnapshot customerSnapshot =
          await FirebaseFirestore.instance.collection('Pelanggan').get();
      QuerySnapshot serviceSnapshot =
          await FirebaseFirestore.instance.collection('Layanan').get();

      setState(() {
        _totalCustomers = customerSnapshot.docs.length;
        _totalServices = serviceSnapshot.docs.length;
      });
    } catch (e) {
      print('Gagal mengambil total pelanggan dan layanan: $e');
    }
  }

  Future<void> _getMonthlyOrderData() async {
    // Ambil data order bulanan untuk grafik
    List<FlSpot> monthlyData = [];
    for (int month = 1; month <= 12; month++) {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('orderan')
          .where('timestamp',
              isGreaterThanOrEqualTo:
                  Timestamp.fromDate(DateTime(DateTime.now().year, month, 1)))
          .where('timestamp',
              isLessThan: Timestamp.fromDate(
                  DateTime(DateTime.now().year, month + 1, 1)))
          .get();

      int totalOrders = snapshot.docs.length; // Hitung jumlah orderan
      monthlyData.add(FlSpot(month.toDouble(),
          totalOrders.toDouble())); // Tambahkan ke data grafik
    }

    setState(() {
      _chartData = monthlyData; // Update data grafik
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator()) // Menampilkan loading indicator
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Di dalam method build
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      DetailOrderanTahunPage(), // Halaman detail_orderan_bulan.dart
                                ),
                              );
                            },
                            child: _buildSummaryCard("Pendapatan Tahun Ini",
                                formatCurrency(_totalIncomeYear), Colors.green),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      DetailOrderanBulanPage(), // Halaman detail_orderan_bulan.dart
                                ),
                              );
                            },
                            child: _buildSummaryCard("Pendapatan Bulan Ini",
                                formatCurrency(_totalIncomeMonth), Colors.green),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => DataOrderTahunPage()),
                              );
                            },
                            child: _buildSummaryCard(
                              "Orderan Tahun Ini", "$_totalOrdersYear", Colors.blue),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => DataOrderBulan()),
                              );
                            },
                            child: _buildSummaryCard(
                              "Orderan Bulan Ini", "$_totalOrdersMonth", Colors.blue),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Grafik Statistik Pesanan
                  const Text(
                    "Statistik Pesanan Tahun Ini",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal, // Mengizinkan scroll horizontal
                    child: SizedBox(
                      height: 200,
                      width: 600, // Atur lebar grafik agar cukup untuk menampilkan semua bulan
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
                                    "Jan",
                                    "Feb",
                                    "Mar",
                                    "Apr",
                                    "Mei",
                                    "Jun",
                                    "Jul",
                                    "Aug",
                                    "Sep",
                                    "Okt",
                                    "Nov",
                                    "Des"
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
                  ),
                  const SizedBox(height: 20),

                  // Tabel Pesanan Hari Ini
                  const Text(
                    "Pesanan Hari Ini",
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
    return Container(
      width: 150, // Atur lebar kotak ringkasan
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(8.0), // Mengurangi padding
          child: Column(
            children: [
              Text(
                title,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold), // Ukuran teks lebih kecil
              ),
              const SizedBox(height: 5),
              Text(
                value,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: valueColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget Tabel Pesanan Hari Ini
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
                Text("No",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                Text("Nama",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                Text("Layanan",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                Text("Harga",
                    style: TextStyle(
                        color: Color.fromRGBO(255, 255, 255, 1),
                        fontWeight: FontWeight.bold)),
                Text("Status",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          // Menampilkan pesanan hari ini
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _todayOrders.length,
            itemBuilder: (context, index) {
              var order = _todayOrders[index];
              return ListTile(
                title: Text(order['customer']),
                subtitle: Text(order['service']),
                trailing: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(order['price'],
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(order['status'],
                        style: TextStyle(color: Colors.orange)),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Bottom Navigation Bar
  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      iconSize: 24,
      selectedLabelStyle: const TextStyle(fontSize: 12),
      unselectedLabelStyle: const TextStyle(fontSize: 12),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: 'Karyawan',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.local_laundry_service),
          label: 'Layanan',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: 'Pelanggan',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart),
          label: 'Data',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Pengaturan',
        ),
      ],
    );
  }
}