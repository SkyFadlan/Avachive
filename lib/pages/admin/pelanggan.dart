import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dashboard.dart';
import 'karyawan.dart';
import 'layanan.dart';
import 'tambah_pelanggan.dart';
import 'pengaturan.dart';
import 'detail_pelanggan.dart';
import 'laporan_bulanan.dart';

class AdminPelangganPage extends StatefulWidget {
  const AdminPelangganPage({super.key});

  @override
  State<AdminPelangganPage> createState() => _AdminPelangganPageState();
}

class _AdminPelangganPageState extends State<AdminPelangganPage> {
  int _selectedIndex = 3;
  final TextEditingController _searchController = TextEditingController();

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return; // Jangan reload halaman yang sama

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
        nextPage = const AdminPelangganPage();
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
        builder: (context) => TambahAdminPelangganPage(
          pelangganId: pelangganId,
          initialData: data,
        ),
      ),
    );
  }

  void _tampilkanDialogKonfirmasi(String pelangganId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi'),
          content:
              const Text('Apakah Anda yakin ingin menghapus pelanggan ini?'),
          actions: [
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Hapus'),
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
                _hapusPelanggan(pelangganId); // Jalankan fungsi hapus
              },
            ),
          ],
        );
      },
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

                  // Mengurutkan daftar pelanggan berdasarkan nama
                  filteredList.sort((a, b) {
                    var namaA =
                        (a.data() as Map<String, dynamic>)['namaPelanggan']
                                ?.toString()
                                .toLowerCase() ??
                            '';
                    var namaB =
                        (b.data() as Map<String, dynamic>)['namaPelanggan']
                                ?.toString()
                                .toLowerCase() ??
                            '';
                    return namaA.compareTo(namaB);
                  });

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
                                  _tampilkanDialogKonfirmasi(pelangganId);
                                },
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.info, color: Colors.blue),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          DetailAdminPelangganPage(
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
                                        rtRw: data['rtRw'] ??
                                            'Rt dan Rw tidak tersedia',
                                        noRumah: data['No Rumah'] ??
                                            'Nomer Rumah tidak tersedia',
                                        kodePos: data['kodePos'] ??
                                            'Kode Pos tidak tersedia',
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
                      builder: (context) => const TambahAdminPelangganPage()),
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
                color: _selectedIndex == 4 ? Colors.blue : Colors.grey),
            label: 'Data',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings,
                color: _selectedIndex == 5 ? Colors.blue : Colors.grey),
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
