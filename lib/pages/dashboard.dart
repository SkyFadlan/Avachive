import 'package:flutter/material.dart';
import 'pelanggan.dart';
import 'buat_order.dart';
import 'data_order.dart';
import 'layanan.dart'; // Tambahkan import untuk halaman layanan
import 'pengaturan.dart'; // Import halaman Pengaturan

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardPage(),
    const PelangganPage(),
    const BuatOrderPage(),
    const DataOrderPage(),
    const PengaturanPage(), // Tambahkan halaman Pengaturan
  ];

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
        // Hapus bagian actions untuk menghilangkan ikon pengaturan
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
                          children: const [
                            Text(
                              'Pendapatan Hari Ini',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.lightBlue,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Rp 40.000',
                              style: TextStyle(
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
                          children: const [
                            Text(
                              'Order Hari Ini',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.lightBlue,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '2',
                              style: TextStyle(
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
                                // Navigasi ke halaman Layanan
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LayananPage(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.shopping_bag),
                              color: Colors.blue,
                              iconSize: 40,
                            ),
                            const Text('Layanan'),
                          ],
                        ),
                        Column(
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const PelangganPage(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.people),
                              color: Colors.blue,
                              iconSize: 40,
                            ),
                            const Text('Pelanggan'),
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
        iconSize: 20, // Ukuran ikon yang lebih kecil
        selectedLabelStyle:
            TextStyle(fontSize: 12), // Ukuran label yang lebih kecil
        unselectedLabelStyle:
            TextStyle(fontSize: 12), // Ukuran label yang lebih kecil
        onTap: _onItemTapped,
      ),
    );
  }
}