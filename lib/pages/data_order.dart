import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dashboard.dart';
import 'pelanggan.dart';
import 'buat_order.dart';
import 'pengaturan.dart'; // Import halaman Pengaturan
import 'detail_order.dart'; // Import halaman Detail Order
import 'pelunasan.dart';

class DataOrderPage extends StatefulWidget {
  const DataOrderPage({super.key});

  @override
  State<DataOrderPage> createState() => _DataOrderPageState();
}

class _DataOrderPageState extends State<DataOrderPage>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 3;
  late TabController _tabController;
  DateTime selectedDate =
      DateTime.now(); // Variabel untuk menyimpan tanggal yang dipilih

  // Tambahkan ini ke dalam class
  String formatCurrency(int amount) {
    final formatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
    return formatter.format(amount);
  }

  String getStatusPembayaran(String waktuPembayaran) {
    if (waktuPembayaran == "Bayar Sekarang") {
      return "Sudah Dibayar";
    } else if (waktuPembayaran == "Bayar Nanti") {
      return "Belum Lunas";
    } else {
      return "-";
    }
  }

  Color getPembayaranColor(String waktuPembayaran) {
    if (waktuPembayaran == "Bayar Sekarang") {
      return Colors.green;
    } else if (waktuPembayaran == "Bayar Nanti") {
      return Colors.red;
    } else {
      return Colors.black;
    }
  }

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
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const DashboardPage()));
        break;
      case 1:
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const PelangganPage()));
        break;
      case 2:
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const BuatOrderPage()));
        break;
      case 3: // Handle Data Order
        // No action required since you're already on this page.
        break;
      case 4:
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const PengaturanPage()));
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
            Tab(text: "Selesai"),
            Tab(text: "Riwayat"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrderList('Diproses', true), // Tambahkan tombol selesai
          _buildOrderList(
              'Sudah Bisa Diambil', false), // Tambahkan tombol ambil
          _buildHistoryOrders(), // Ganti dengan fungsi baru untuk tab Riwayat
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
        selectedLabelStyle: TextStyle(fontSize: 12),
        unselectedLabelStyle: TextStyle(fontSize: 12),
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildOrderList(String status, bool isDiproses) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('orderan').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var orders = snapshot.data!.docs.map((doc) {
          var data = doc.data() as Map<String, dynamic>;

          // Pastikan 'items' adalah List
          List<dynamic> items = data['items'] ?? [];

          return {
            'id': doc.id,
            'customer': (data['customer'] is Map)
                ? data['customer']['name'] ?? 'Tanpa Nama'
                : 'Tanpa Nama',
            'service': items.isNotEmpty
                ? items.map((item) => item['name']).join(', ')
                : 'Tidak ada layanan',
            'date': data['timestamp'] != null
                ? DateFormat('dd-MM-yyyy')
                    .format((data['timestamp'] as Timestamp).toDate())
                : 'Tanggal Tidak Ada',
            'price': formatCurrency((data['total_price'] ?? 0) as int),
            'waktuPembayaran': data['waktuPembayaran'] ?? '',
            'status': data['status']?.toString() ?? 'Diproses',
            // Ambil status dari item pertama
            'address': data['address'] ?? 'Alamat tidak tersedia',
            'timestamp': data['timestamp'],
          };
        }).toList();

        // Filter berdasarkan status dalam items
        var filteredOrders =
            orders.where((order) => order['status'] == status).toList();

        return ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: filteredOrders.length,
          itemBuilder: (context, index) {
            var order = filteredOrders[index];
            return _buildOrderCard(order, status, isDiproses);
          },
        );
      },
    );
  }

  Widget _buildOrderCard(
    Map<String, dynamic> order, String status, bool isDiproses) {
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
      shape: RoundedRectangleBorder(
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
                  child: Icon(Icons.person, color: Colors.blue),
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
                    Text(
                      getStatusPembayaran(order['waktuPembayaran']),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: getPembayaranColor(order['waktuPembayaran']),
                      ),
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
            if (isDiproses) // Jika ini adalah tab Diproses
              ElevatedButton(
                onPressed: () {
                  _updateOrderStatus(order['id'], 'Sudah Bisa Diambil');
                },
                child: const Text("Selesai"),
              ),
            if (!isDiproses &&
                order['status'] == 'Sudah Bisa Diambil' &&
                order['waktuPembayaran'] != 'Bayar Nanti') // Tambahkan kondisi ini
              ElevatedButton(
                onPressed: () {
                  _updateOrderStatus(order['id'], 'Selesai');
                },
                child: const Text("Ambil"),
              ),
            if (order['waktuPembayaran'] == 'Bayar Nanti')
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                onPressed: () {
                  _updateWaktuPembayaran(order['id'], 'Bayar Sekarang');
                },
                child: const Text("Bayar Sekarang"),
              ),
          ],
        ),
      ),
    ),
  );
}

  void _updateOrderStatus(String orderId, String newStatus) async {
    try {
      Map<String, dynamic> updateData = {
        'status': newStatus,
      };

      // Tambahkan waktu saat status diubah
      if (newStatus == 'Selesai') {
        updateData['completedAt'] = FieldValue.serverTimestamp();
      } else if (newStatus == 'Ambil') {
        updateData['pickedUpAt'] = FieldValue.serverTimestamp();
      }

      await FirebaseFirestore.instance
          .collection('orderan')
          .doc(orderId)
          .update(updateData);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Order status berhasil diubah menjadi $newStatus')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengubah status order: $e')),
      );
    }
  }

  void _updateWaktuPembayaran(String orderId, String newWaktuPembayaran) async {
    try {
      await FirebaseFirestore.instance
          .collection('orderan')
          .doc(orderId)
          .update({
        'waktuPembayaran': newWaktuPembayaran,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Status pembayaran diubah menjadi $newWaktuPembayaran')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengubah status pembayaran: $e')),
      );
    }
  }

  Widget _buildHistoryOrders() {
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
            child:
                Text("Pilih Tanggal: ${selectedDate.toLocal()}".split(' ')[0]),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance.collection('orderan').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              var orders = snapshot.data!.docs.map((doc) {
                var data = doc.data() as Map<String, dynamic>;
                return {
                  'id': doc.id,
                  'customer': (data['customer'] is Map)
                      ? data['customer']['name'] ?? 'Tanpa Nama'
                      : 'Tanpa Nama',
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
                  'price': formatCurrency((data['total_price'] ?? 0) as int),
                  'waktuPembayaran': data['waktuPembayaran'] ?? '',
                  'status': data['status']?.toString() ?? 'Diproses',
                  'address': data['address'] ?? 'Alamat tidak tersedia',
                  'timestamp': data['timestamp'],
                };
              }).toList();

              // Filter untuk hanya menampilkan order yang sudah selesai
              var filteredOrders = orders.where((order) {
                return order['status'] == 'Selesai' &&
                    order['date'] ==
                        selectedDate.toLocal().toString().split(' ')[0];
              }).toList();

              // Count of completed orders
              int completedOrderCount = filteredOrders.length;

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Jumlah Orderan Selesai: $completedOrderCount',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(10),
                      itemCount: filteredOrders.length,
                      itemBuilder: (context, index) {
                        var order = filteredOrders[index];
                        return _buildHistoryOrderCard(order);
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

  Widget _buildHistoryOrderCard(Map<String, dynamic> order) {
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
        shape: RoundedRectangleBorder(
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
                    child: Icon(Icons.person, color: Colors.blue),
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
                      Text(
                        getStatusPembayaran(order['waktuPembayaran']),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: getPembayaranColor(order['waktuPembayaran']),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order['status'],
                        style: TextStyle(
                          color: Colors.green, // Hijau untuk status selesai
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  // Tindakan untuk melihat detail nota
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailOrderPage(
                        orderId: order['id'],
                      ),
                    ),
                  );
                },
                child: const Text("Detail Nota"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
