import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import 'pelanggan.dart';
import 'buat_order.dart';
import 'data_order.dart';
import 'layanan.dart';
import 'pengaturan.dart';
import 'package:intl/intl.dart'; // Import untuk format tanggal

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  int _jumlahPelanggan = 0;
  int _jumlahLayanan = 0;
  int _pendapatanHariIni = 0;
  int _orderHariIni = 0;
  bool _hasNewService = false; // Status untuk layanan baru

  @override
  void initState() {
    super.initState();
    _getJumlahPelanggan();
    _getJumlahLayanan();
    _getPendapatanDanOrderHariIni();
    _checkForNewService(); // Cek status layanan baru
  }

  String formatCurrency(int amount) {
    final formatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
    return formatter.format(amount);
  }

  void _getJumlahPelanggan() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('Pelanggan').get();
      setState(() {
        _jumlahPelanggan = snapshot.docs.length;
      });
    } catch (e) {
      print('Gagal mengambil jumlah pelanggan: $e');
    }
  }

  void _getJumlahLayanan() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('Layanan').get();
      setState(() {
        _jumlahLayanan = snapshot.docs.length;
      });

      // Cek apakah ada layanan baru ditambahkan dalam 24 jam terakhir
      DateTime now = DateTime.now();
      bool hasNewService = false;

      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        var createdAt = (data['createdAt'] as Timestamp?)?.toDate();
        if (createdAt != null && now.difference(createdAt).inHours < 24) {
          hasNewService = true;
          break;
        }
      }

      // Simpan status layanan baru di SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasNewService', hasNewService);
      setState(() {
        _hasNewService = hasNewService;
      });
    } catch (e) {
      print('Gagal mengambil jumlah layanan: $e');
    }
  }

  void _getPendapatanDanOrderHariIni() async {
    try {
      DateTime today = DateTime.now();
      String todayString =
          DateFormat('yyyy-MM-dd').format(today); // Format YYYY-MM-DD

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('orderan')
          .where('timestamp',
              isGreaterThanOrEqualTo: Timestamp.fromDate(
                  DateTime(today.year, today.month, today.day)))
          .where('timestamp',
              isLessThan: Timestamp.fromDate(
                  DateTime(today.year, today.month, today.day + 1)))
          .get();

      int totalPendapatan = 0;
      int totalOrder = snapshot.docs.length;

      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        if (data['total_price'] != null) {
          totalPendapatan += (data['total_price'] as num).toInt();
        }
      }

      setState(() {
        _pendapatanHariIni = totalPendapatan;
        _orderHariIni = totalOrder;
      });

      print('Pendapatan Hari Ini: ${formatCurrency(_pendapatanHariIni)}');
      print('Order Hari Ini: $_orderHariIni');
    } catch (e) {
      print('Gagal mengambil pendapatan dan order hari ini: $e');
    }
  }

  void _checkForNewService() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _hasNewService =
          prefs.getBool('hasNewService') ?? false; // Cek status layanan baru
    });
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => _pages[index]),
      );
    }
  }

  final List<Widget> _pages = [
    const DashboardPage(),
    const PelangganPage(),
    const BuatOrderPage(),
    const DataOrderPage(),
    const PengaturanPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Avachive',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Ringkasan Laporan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(thickness: 1),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text(
                              'Pendapatan Hari Ini',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.lightBlue,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              formatCurrency(_pendapatanHariIni),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const VerticalDivider(
                          thickness: 1,
                          width: 1,
                          color: Colors.grey,
                        ),
                        Column(
                          children: [
                            const Text(
                              'Order Hari Ini',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.lightBlue,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$_orderHariIni',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Kelola Laundry',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            IconButton(
                              onPressed: () {
                                // Hapus status layanan baru
                                SharedPreferences.getInstance().then((prefs) {
                                  prefs.setBool('hasNewService', false);
                                  setState(() {
                                    _hasNewService = false; // Update state
                                  });
                                });

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LayananPage(),
                                  ),
                                );
                              },
                              icon: Stack(
                                children: [
                                  const Icon(Icons.shopping_bag),
                                  if (_hasNewService)
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Text(
                                          'New',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              color: Colors.blue,
                              iconSize: 40,
                            ),
                            const Text('Layanan'),
                            const SizedBox(height: 8),
                            Text(
                              'Jumlah: $_jumlahLayanan',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            IconButton(
                              onPressed: () {
                                // Tindakan jika ingin menampilkan daftar pelanggan
                              },
                              icon: const Icon(Icons.people),
                              color: Colors.blue,
                              iconSize: 40,
                            ),
                            const Text('Pelanggan'),
                            const SizedBox(height: 8),
                            Text(
                              'Jumlah: $_jumlahPelanggan',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const DataOrderPage(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.list_alt),
                              color: Colors.blue,
                              iconSize: 40,
                            ),
                            const Text('Data Order'),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home,
                color: _selectedIndex == 0 ? Colors.blue : Colors.grey),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person,
                color: _selectedIndex == 1 ? Colors.blue : Colors.grey),
            label: 'Pelanggan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart,
                color: _selectedIndex == 2 ? Colors.blue : Colors.grey),
            label: 'Buat Order',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.checklist,
                color: _selectedIndex == 3 ? Colors.blue : Colors.grey),
            label: 'Data Order',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings,
                color: _selectedIndex == 4 ? Colors.blue : Colors.grey),
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
        selectedLabelStyle: TextStyle(fontSize: 12),
        unselectedLabelStyle: TextStyle(fontSize: 12),
        onTap: _onItemTapped,
      ),
    );
  }
}
