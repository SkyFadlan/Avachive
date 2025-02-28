import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dashboard.dart'; // Ganti dengan import halaman Dashboard Admin yang sesuai
import 'kasir.dart'; // Ganti dengan import halaman Kasir yang sesuai
import 'layanan.dart'; // Ganti dengan import halaman Layanan yang sesuai
import 'pengaturan.dart'; // Ganti dengan import halaman Pengaturan yang sesuai

class LaporanBulananPage extends StatefulWidget {
  const LaporanBulananPage({super.key});

  @override
  State<LaporanBulananPage> createState() => _LaporanBulananPageState();
}

class _LaporanBulananPageState extends State<LaporanBulananPage> {
  int _selectedIndex = 3; // Indeks untuk Laporan Bulanan

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    Widget nextPage;
    switch (index) {
      case 0:
        nextPage = const AdminDashboardPage(); // Halaman Dashboard Admin
        break;
      case 1:
        nextPage = const KasirPage(); // Halaman Kasir
        break;
      case 2:
        nextPage = const LayananPage(); // Halaman Layanan
        break;
      case 3:
        nextPage = const LaporanBulananPage(); // Halaman Laporan Bulanan
        break;
      case 4:
        nextPage = const PengaturanAdminPage(); // Halaman Pengaturan
        break;
      default:
        nextPage = const LaporanBulananPage(); // Halaman Laporan Bulanan
        break;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => nextPage),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Bulanan', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('orderan').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('Tidak ada laporan bulan ini.'));
            }

            var laporanList = snapshot.data!.docs;

            return ListView.builder(
              itemCount: laporanList.length,
              itemBuilder: (context, index) {
                var data = laporanList[index].data() as Map<String, dynamic>;

                return Card(
                  color: Colors.grey[300],
                  child: ListTile(
                    leading: Icon(Icons.receipt, color: Colors.blue),
                    title: Text(
                      'Pelanggan: ${data['namaPelanggan'] ?? 'Tidak tersedia'}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Total: Rp ${data['totalHarga'] ?? '0'}\nTanggal: ${data['tanggal'] ?? 'Tidak tersedia'}',
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
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
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
      ),
    );
  }
}