import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dashboard.dart'; // Ganti dengan import halaman Dashboard Admin yang sesuai
import 'kasir.dart'; // Ganti dengan import halaman Kasir yang sesuai
import 'laporan_bulanan.dart'; // Ganti dengan import halaman Laporan Bulanan yang sesuai
import 'pengaturan.dart'; // Ganti dengan import halaman Pengaturan yang sesuai

class LayananPage extends StatefulWidget {
  const LayananPage({super.key});

  @override
  State<LayananPage> createState() => _LayananPageState();
}

class _LayananPageState extends State<LayananPage> {
  int _selectedIndex = 2; // Indeks untuk Layanan

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
        nextPage = const LayananPage(); // Halaman Layanan
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
        title: const Text('Daftar Layanan', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('Layanan').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('Tidak ada layanan tersedia.'));
            }

            var layananList = snapshot.data!.docs;

            return ListView.builder(
              itemCount: layananList.length,
              itemBuilder: (context, index) {
                var data = layananList[index].data() as Map<String, dynamic>;

                return Card(
                  color: Colors.grey[300],
                  child: ListTile(
                    leading: Icon(Icons.cleaning_services, color: Colors.blue),
                    title: Text(
                      data['namaLayanan'] ?? 'Nama tidak tersedia',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "Harga: Rp ${data['Harga'] ?? '0'} | Kategori: ${data['Kategori'] ?? '-'}",
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