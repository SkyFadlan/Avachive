import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dashboard.dart';
import 'karyawan.dart';
import 'pelanggan.dart';
import 'pengaturan.dart';
import 'tambah_layanan.dart';
import 'edit_layanan.dart';
import 'laporan_bulanan.dart'; // Import halaman edit layanan
import 'package:intl/intl.dart';

class LayananPage extends StatefulWidget {
  const LayananPage({super.key});

  @override
  State<LayananPage> createState() => _LayananPageState();
}

class _LayananPageState extends State<LayananPage> {
  int _selectedIndex = 2;

  // Fungsi untuk menghapus layanan
  Future<void> _hapusLayanan(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('Layanan')
          .doc(docId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Layanan berhasil dihapus!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus: ${e.toString()}')),
      );
    }
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    Widget nextPage;
    switch (index) {
      case 0:
        nextPage = const AdminDashboardPage();
        break;
      case 1:
        nextPage = const KasirPage();
        break;
      case 2:
        nextPage = const LayananPage();
        break;
      case 3:
        nextPage = const AdminPelangganPage();
        break;
      case 4:
        nextPage = const LaporanBulananPage();
        break;
      case 5:
        nextPage = const PengaturanAdminPage();
        break;
      default:
        nextPage = const LayananPage();
        break;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => nextPage),
    );
  }

  String formatCurrency(int amount) {
    final formatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Daftar Layanan', style: TextStyle(color: Colors.white)),
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
                String docId = layananList[index].id;

                return Card(
                  color: Colors.grey[300],
                  child: ListTile(
                    leading: const Icon(Icons.local_laundry_service,
                        color: Colors.blue),
                    title: Text(
                      data['namaLayanan'] ?? 'Nama tidak tersedia',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "Harga: ${formatCurrency(data['Harga'] ?? 0)}  Paket: ${data['Paket'] ?? '-'}  Kategori: ${data['Kategori'] ?? '-'}",
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Tombol Edit
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditLayananPage(
                                  docId: docId,
                                  currentData: data,
                                ),
                              ),
                            );
                          },
                        ),
                        // Tombol Hapus
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Konfirmasi'),
                                  content: const Text(
                                      'Yakin ingin menghapus layanan ini?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Batal'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _hapusLayanan(docId);
                                      },
                                      child: const Text('Hapus',
                                          style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TambahLayananPage()),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home,
                color: _selectedIndex == 0 ? Colors.blue : Colors.grey),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people,
                color: _selectedIndex == 1 ? Colors.blue : Colors.grey),
            label: 'Karyawan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_laundry_service,
                color: _selectedIndex == 2 ? Colors.blue : Colors.grey),
            label: 'Layanan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people,
                color: _selectedIndex == 3 ? Colors.blue : Colors.grey),
            label: 'Pelanggan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart,
                color: _selectedIndex == 3 ? Colors.blue : Colors.grey),
            label: 'Data',
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
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
      ),
    );
  }
}
