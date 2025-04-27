import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'pesanan.dart'; // pastikan file ini ada
import 'pengaturan.dart';
import 'detail_order.dart';

class DashboardDriverPage extends StatefulWidget {
  const DashboardDriverPage({Key? key}) : super(key: key);

  @override
  _DashboardDriverPageState createState() => _DashboardDriverPageState();
}

class _DashboardDriverPageState extends State<DashboardDriverPage> {
  int _currentIndex = 0;

  void _onItemTapped(int index) {
    if (index == 0) return;
    if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PesananPage()),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PengaturanDriverPage()),
      );
    }
  }

  String getStatusPembayaran(String waktuPembayaran) {
    if (waktuPembayaran == "Bayar Sekarang") {
      return "Sudah Dibayar";
    } else if (waktuPembayaran == "Bayar Nanti") {
      return "Belum Dibayar";
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

  Future<void> _updateOrderStatus(String orderId) async {
  try {
    await FirebaseFirestore.instance
        .collection('orderan')
        .doc(orderId)
        .update({
      'status': 'Selesai',
      'completedAt': Timestamp.now(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Status order berhasil diubah menjadi Selesai')),
    );

    // Navigate to PesananPage after updating the order status
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PesananPage(orderId: orderId), // Pass the orderId
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Gagal mengubah status order: $e')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pesanan'),
        backgroundColor: Colors.teal,
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('orderan').snapshots(),
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
              'price': data['total_price'] ?? 0,
              'waktuPembayaran': data['waktuPembayaran'] ?? '',
              'status': data['status']?.toString() ?? 'Diproses',
              'metodePengambilan':
                  data['metodePengambilan'] ?? 'Tidak Diketahui',
            };
          }).toList();

          // Filter untuk hanya menampilkan order yang sudah bisa diambil dan diantar ke alamat
          var filteredOrders = orders.where((order) {
            return order['status'] == 'Sudah Bisa Diambil' &&
                order['metodePengambilan'] == 'Diantar ke Alamat';
          }).toList();

          return Column(
            children: [
              _buildHeader(filteredOrders.length), // Add header with motorcycle icon
              Expanded (
                child: ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: filteredOrders.length,
                  itemBuilder: (context, index) {
                    var order = filteredOrders[index];
                    return _buildOrderCard(order);
                  },
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.teal,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Pesanan'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Pengaturan'),
        ],
      ),
    );
  }

  Widget _buildHeader(int orderCount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.motorcycle, color: Colors.white, size: 30),
              const SizedBox(width: 8),
              Text(
                'Jumlah Orderan: $orderCount',
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
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
                    child: Icon(Icons.person, color: Colors.teal),
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
                        'Rp ${order['price']}',
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        order['status'] == 'Sudah Bisa Diambil'
                            ? 'Belum Diantar'
                            : 'Sudah Diantar',
                        style: TextStyle(
                          color: order['status'] == 'Sudah Bisa Diambil'
                              ? Colors.red
                              : Colors.green,
                        ),
                      ),
                      Text(
                        getStatusPembayaran(order['waktuPembayaran']),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: getPembayaranColor(order['waktuPembayaran']),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Metode Pengambilan: ${order['metodePengambilan']}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (order['status'] ==
                  'Sudah Bisa Diambil') // Tombol untuk mengubah status
                ElevatedButton(
                  onPressed: () {
                    _updateOrderStatus(order['id']);
                  },
                  child: const Text('Sudah Diantar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}