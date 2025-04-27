import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dashboard.dart';
import 'pengaturan.dart';
import 'detail_order.dart';

class PesananPage extends StatefulWidget {
  final String? orderId;

  const PesananPage({Key? key, this.orderId}) : super(key: key);

  @override
  State<PesananPage> createState() => _PesananPageState();
}

class _PesananPageState extends State<PesananPage> {
  int _currentIndex = 1;
  DateTime? selectedDate;

  void _onItemTapped(int index) {
    if (index == 1) return;
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardDriverPage()),
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedDate == null
                      ? 'Pilih Tanggal'
                      : 'Tanggal: ${selectedDate!.toLocal()}'.split(' ')[0],
                  style: const TextStyle(fontSize: 16),
                ),
                ElevatedButton(
                  onPressed: () => _selectDate(context),
                  child: const Text('Pilih Tanggal'),
                ),
              ],
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
                    'price': data['total_price'] ?? 0,
                    'waktuPembayaran': data['waktuPembayaran'] ?? '',
                    'status': data['status']?.toString() ?? 'Diproses',
                    'metodePengambilan':
                        data['metodePengambilan'] ?? 'Tidak Diketahui',
                    'completedAt': data['completedAt'] != null
                        ? (data['completedAt'] as Timestamp).toDate()
                        : null,
                  };
                }).toList();

                // Tetap filter berdasarkan metode dan status dulu
                orders = orders.where((order) {
                  bool isDiantar =
                      order['metodePengambilan'] == 'Diantar ke Alamat';
                  bool isSelesai = order['status'] == 'Selesai';

                  DateTime orderDate = order['completedAt'] ?? DateTime.now();
                  DateTime today = DateTime.now();

                  // Cek apakah orderDate == hari ini
                  bool isToday = orderDate.year == today.year &&
                      orderDate.month == today.month &&
                      orderDate.day == today.day;

                  if (selectedDate != null) {
                    bool isSameSelectedDate =
                        orderDate.year == selectedDate!.year &&
                            orderDate.month == selectedDate!.month &&
                            orderDate.day == selectedDate!.day;
                    return isDiantar && isSelesai && isSameSelectedDate;
                  }

                  // Kalau tidak pilih tanggal, filter hari ini
                  return isDiantar && isSelesai && isToday;
                }).toList();

                return ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    var order = orders[index];
                    return _buildOrderCard(order);
                  },
                );
              },
            ),
          ),
        ],
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
                        order['status'] == 'Selesai'
                            ? 'Sudah Diantar'
                            : 'Belum Diantar',
                        style: TextStyle(
                          color: order['status'] == 'Selesai'
                              ? Colors.green
                              : Colors.red,
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
            ],
          ),
        ),
      ),
    );
  }
}
