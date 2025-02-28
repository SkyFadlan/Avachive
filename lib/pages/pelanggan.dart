import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dashboard.dart';
import 'buat_order.dart';
import 'data_order.dart';
import 'tambah_pelanggan.dart';
import 'pengaturan.dart'; // Import halaman Pengaturan
import 'detail_pelanggan.dart';

class PelangganPage extends StatefulWidget {
  const PelangganPage({super.key});

  @override
  State<PelangganPage> createState() => _PelangganPageState();
}

class _PelangganPageState extends State<PelangganPage> {
  int _selectedIndex = 1;
  final TextEditingController _searchController = TextEditingController();

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return; // Jangan reload halaman yang sama

    Widget nextPage;
    switch (index) {
      case 0:
        nextPage = const DashboardPage();
        break;
      case 1:
        nextPage = const PelangganPage();
        break;
      case 2:
        nextPage = const BuatOrderPage();
        break;
      case 3:
        nextPage = const DataOrderPage();
        break;
      case 4:
        nextPage = const PengaturanPage(); // Navigasi ke halaman Pengaturan
        break;
      default:
        nextPage = const PelangganPage();
        break;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => nextPage),
    );
  }

  void _hapusPelanggan(String pelangganId) async {
    try {
      await FirebaseFirestore.instance
          .collection('Pelanggan')
          .doc(pelangganId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pelanggan berhasil dihapus')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus pelanggan: $e')),
      );
    }
  }

  void _editPelanggan(String pelangganId, Map<String, dynamic> data) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TambahPelangganPage(
          pelangganId: pelangganId,
          initialData: data,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pelanggan',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari Pelanggan',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('Pelanggan')
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                        child: Text('Tidak ada data pelanggan.'));
                  }

                  var pelangganList = snapshot.data!.docs;

                  var filteredList = pelangganList.where((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    String nama =
                        data['namaPelanggan']?.toString().toLowerCase() ?? '';
                    return nama.contains(_searchController.text.toLowerCase());
                  }).toList();

                  return ListView.builder(
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      var data =
                          filteredList[index].data() as Map<String, dynamic>;
                      String pelangganId = filteredList[index].id;

                      return Card(
                        color: Colors.grey[300],
                        child: ListTile(
                          leading: Text('${index + 1}.'),
                          title: Text(
                            data['namaPelanggan']?.toString() ??
                                'Nama tidak tersedia',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(data['noHandphone']?.toString() ??
                              'No HP tidak tersedia'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit,
                                    color: Colors.orange),
                                onPressed: () =>
                                    _editPelanggan(pelangganId, data),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  _hapusPelanggan(pelangganId);
                                },
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.info, color: Colors.blue),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DetailPelangganPage(
                                        namaPelanggan: data['namaPelanggan'] ??
                                            'Nama tidak tersedia',
                                        noHandphone: data['noHandphone'] ??
                                            'No HP tidak tersedia',
                                        provinsi: data['provinsi'] ??
                                            'Provinsi tidak tersedia',
                                        kota: data['kota'] ??
                                            'Kota tidak tersedia',
                                        kecamatan: data['kecamatan'] ??
                                            'Kecamatan tidak tersedia',
                                        detailAlamat: data['detailAlamat'] ??
                                            'Detail alamat tidak tersedia',
                                      ),
                                    ),
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
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const TambahPelangganPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                'Tambah Data Pelanggan',
                style: TextStyle(color: Colors.white),
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
