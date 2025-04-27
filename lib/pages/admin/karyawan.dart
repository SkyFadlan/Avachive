import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dashboard.dart'; // Ganti dengan import halaman Dashboard Admin yang sesuai
import 'layanan.dart'; // Ganti dengan import halaman Layanan yang sesuai
import 'pelanggan.dart'; // Ganti dengan import halaman Pelanggan yang sesuai
import 'pengaturan.dart'; // Ganti dengan import halaman Pengaturan yang sesuai
import 'register.dart'; // Ganti dengan import halaman Register yang sesuai
import 'laporan_bulanan.dart'; // Ganti dengan import halaman Laporan Bulanan yang sesuai

class KasirPage extends StatefulWidget {
  const KasirPage({super.key});

  @override
  State<KasirPage> createState() => _KasirPageState();
}

class _KasirPageState extends State<KasirPage> {
  int _selectedIndex = 1;

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
        nextPage = const AdminPelangganPage(); // Halaman Pelanggan
        break;
      case 4:
        nextPage = const LaporanBulananPage(); // Halaman Laporan Bulanan
        break;
      case 5:
        nextPage = const PengaturanAdminPage(); // Halaman Pengaturan
        break;
      default:
        nextPage = const KasirPage(); // Halaman Kasir
        break;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => nextPage),
    );
  }

  Future<void> _deleteKasir(String uid) async {
    try {
      await FirebaseFirestore.instance.collection('Users').doc(uid).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Karyawan berhasil dihapus')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Karyawan', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Users')
              .where('role', whereIn: ['kasir', 'driver']) // Filter berdasarkan role kasir dan driver
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('Tidak ada karyawan terdaftar.'));
            }

            var kasirList = snapshot.data!.docs;

            return ListView.builder(
              itemCount: kasirList.length,
              itemBuilder: (context, index) {
                var data = kasirList[index].data() as Map<String, dynamic>;
                String uid = kasirList[index].id; // Ambil UID dari dokumen

                return Card(
                  color: Colors.grey[300],
                  child: ListTile(
                    leading: const Icon(Icons.person, color: Colors.blue),
                    title: Text(
                      data['username'] ?? 'Nama tidak tersedia',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(data['id_karyawan'] ?? 'ID tidak tersedia'),
                        Text(data['role'] ?? 'Role tidak tersedia'),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        // Konfirmasi sebelum menghapus
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Konfirmasi Hapus'),
                              content: const Text('Apakah Anda yakin ingin menghapus kasir ini?'),
                              actions: [
                                TextButton(
 onPressed: () {
                                    Navigator.of(context).pop(); // Tutup dialog
                                  },
                                  child: const Text('Batal'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    _deleteKasir(uid); // Hapus kasir
                                    Navigator.of(context).pop(); // Tutup dialog
                                  },
                                  child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            );
                          },
                        );
                      },
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
            MaterialPageRoute(builder: (context) => const RegisterPage()),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: _selectedIndex == 0 ? Colors.blue : Colors.grey),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people, color: _selectedIndex == 1 ? Colors.blue : Colors.grey),
            label: 'Karyawan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_laundry_service, color: _selectedIndex == 2 ? Colors.blue : Colors.grey),
            label: 'Layanan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people, color: _selectedIndex == 3 ? Colors.blue : Colors.grey),
            label: 'Pelanggan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart, color: _selectedIndex == 4 ? Colors.blue : Colors.grey),
            label: 'Data',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings, color: _selectedIndex == 5 ? Colors.blue : Colors.grey),
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