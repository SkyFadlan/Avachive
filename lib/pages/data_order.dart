import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dashboard.dart';
import 'pelanggan.dart';
import 'buat_order.dart';
import 'pengaturan.dart'; // Import halaman Pengaturan
import 'detail_order.dart'; // Import halaman Detail Order

class DataOrderPage extends StatefulWidget {
  const DataOrderPage({super.key});

  @override
  State<DataOrderPage> createState() => _DataOrderPageState();
}

class _DataOrderPageState extends State<DataOrderPage>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 3;
  late TabController _tabController;
  DateTime selectedDate = DateTime.now(); // Variabel untuk menyimpan tanggal yang dipilih

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardPage()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PelangganPage()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const BuatOrderPage()),
        );
        break;
      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  const PengaturanPage()), // Navigasi ke halaman Pengaturan
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Data Order',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.blue,
          labelColor: const Color.fromARGB(255, 0, 60, 255),
          unselectedLabelColor: Colors.white,
          tabs: const [
            Tab(text: "Diproses"),
            Tab(text: "Selesai"), // Ubah nama tab
            Tab(text: "Riwayat"), // Ubah nama tab
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrderList('Diproses'),
          _buildOrderList('Sudah Bisa Diambil'), // Ubah status
          _buildPickupOrders(), // Ganti dengan fungsi baru untuk tab Ambil
        ],
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
        selectedLabelStyle: TextStyle(fontSize:  12),
        unselectedLabelStyle: TextStyle(fontSize: 12),
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildOrderList(String status) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('orderan').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var orders = snapshot.data!.docs.map((doc) {
          var data = doc.data() as Map<String, dynamic>;
          return {
            'id': doc.id,
            'customer': data['customer'] ?? 'Tanpa Nama',
            'service': data['items'] != null
                ? (data['items'] as List).map((item) => item['name']).join(', ')
                : 'Tidak ada layanan',
            'date': data['timestamp'] != null
                ? (data['timestamp'] as Timestamp)
                    .toDate()
                    .toString()
                    .split(' ')[0]
                : 'Tanggal Tidak Ada',
            'price': 'Rp ${data['total_price'] ?? 0}',
            'status': data['status'] ?? 'Diproses',
            'address': data['address'] ?? 'Alamat tidak tersedia',
            'timestamp': data['timestamp'],
          };
        }).toList();

        // Filter berdasarkan status
        var filteredOrders = orders.where((order) => order['status'] == status).toList();

        return ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: filteredOrders.length,
          itemBuilder: (context, index) {
            var order = filteredOrders[index];
            return _buildOrderCard(order, status);
          },
        );
      },
    );
  }

  Widget _buildPickupOrders() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );
              if (pickedDate != null) {
                setState(() {
                  selectedDate = pickedDate;
                });
              }
            },
            child: Text("Pilih Tanggal: ${selectedDate.toLocal()}".split(' ')[0]),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('orderan').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              var orders = snapshot.data!.docs.map((doc) {
                var data = doc.data() as Map<String, dynamic>;
                return {
                  'id': doc.id,
                  'customer': data['customer'] ?? 'Tanpa Nama',
                  'service': data['items'] != null
                      ? (data['items'] as List)
                          .map((item) => item['name'])
                          .join(', ')
                      : 'Tidak ada layanan',
                  'date': data['timestamp'] != null
                      ? (data['timestamp'] as Timestamp)
                          .toDate()
                          .toString()
                          .split(' ')[0]
                      : 'Tanggal Tidak Ada',
                  'price': 'Rp ${data['total_price'] ?? 0}',
                  'status': data['status'] ?? 'Diproses',
                  'address': data['address'] ?? 'Alamat tidak tersedia',
                  'timestamp': data['timestamp'],
                };
              }).toList();

              // Filter untuk hanya menampilkan order yang sudah diambil
              var filteredOrders = orders.where((order) {
                return order['status'] == 'Sudah Di Ambil' &&
                       order['date'] == selectedDate.toLocal().toString().split(' ')[0];
              }).toList();

              int orderCount = filteredOrders.length;

              return Column(
                children: [
                  Text("Jumlah Orderan: $orderCount"),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(10),
                      itemCount: filteredOrders.length,
                      itemBuilder: (context, index) {
                        var order = filteredOrders[index];
                        return _buildOrderCard(order, 'Sudah Di Ambil'); // Ubah status
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order, String status) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailOrderPage(
              orderId: order['id'],
            ),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder
        (
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 3,
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.grey[300],
                    child: Icon(Icons.image, color: Colors.blue),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order['customer'],
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          order['date'],
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        order['price'],
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order['status'],
                        style: TextStyle(
                          color: order['status'] == 'Diproses'
                              ? const Color.fromARGB(255, 231, 43, 43) // Merah
                              : order['status'] == 'Sudah Bisa Diambil'
                                  ? Colors.blue // Biru
                                  : Colors.green, // Hijau
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (status == 'Sudah Di Ambil')
                ElevatedButton(
                  onPressed: () {
                    // Aksi jika diperlukan saat order sudah diambil
                  },
                  child: const Text("Detail"),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // void _updateOrderStatus(String orderId, String newStatus) {
  //   FirebaseFirestore.instance.collection('orderan').doc(orderId).update({
  //     'status': newStatus,
  //   }).then((_) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //           content: Text("Status order berhasil diubah menjadi $newStatus")),
  //     );

  //     // Jika status baru adalah 'Sudah Bisa Diambil', navigasi ke halaman yang sama
  //     if (newStatus == 'Sudah Bisa Diambil') {
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (context) => const DataOrderPage()),
  //       );
  //     }
  //   }).catchError((error) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Terjadi kesalahan: $error")),
  //     );
  //   });
  // }
}