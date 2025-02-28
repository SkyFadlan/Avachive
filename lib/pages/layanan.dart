import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LayananPage extends StatefulWidget {
  const LayananPage({super.key});

  @override
  State<LayananPage> createState() => _LayananPageState();
}

class _LayananPageState extends State<LayananPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this); // Hanya satu tab
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Layanan',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ),
      body: _buildServiceList(), // Hanya menampilkan daftar layanan
    );
  }

  Widget _buildServiceList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('Layanan').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(
              child: Text('Terjadi kesalahan saat memuat data'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Tidak ada layanan tersedia'));
        }

        var services = snapshot.data!.docs;

        return ListView.builder(
          itemCount: services.length,
          itemBuilder: (context, index) {
            var service = services[index];
            var data = service.data() as Map<String, dynamic>;

            var namaLayanan = data['namaLayanan'] ?? 'Tanpa Nama';
            var harga = data['Harga'] ?? '0';
            var kategori = data['Kategori'] ?? 'Tanpa Kategori';
            var paket = data.containsKey('Paket') ? data['Paket'] : 'Tanpa Paket';

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: Text("${index + 1}."),
                title: Text(namaLayanan),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Kategori: $kategori"),
                    Text("Paket: $paket"),
                    Text("Harga: Rp $harga"),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
