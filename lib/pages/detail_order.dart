import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetailOrderPage extends StatelessWidget {
  final String orderId;

  const DetailOrderPage({Key? key, required this.orderId}) : super(key: key);

  Future<Map<String, dynamic>?> fetchOrderDetails() async {
    try {
      DocumentSnapshot orderSnapshot =
          await FirebaseFirestore.instance.collection('orderan').doc(orderId).get();

      if (!orderSnapshot.exists) return null;

      var orderData = orderSnapshot.data() as Map<String, dynamic>;
      String? customerId = orderData['customer']; // Menggunakan 'customer' sesuai Firestore

      // Ambil layanan dari array items
      List<dynamic> items = orderData['items'] ?? [];
      List<Map<String, dynamic>> services = items.map((item) {
        return {
          'name': item['name'],
          'price': item['price'],
          'quantity': item['quantity'],
          'subtotal': item['price'] * item['quantity'],
        };
      }).toList();

      String customerName = 'Tidak Diketahui';
      String address = '-';

      // Ambil data pelanggan jika ID tersedia
      if (customerId != null) {
        DocumentSnapshot customerSnapshot =
            await FirebaseFirestore.instance.collection('Pelanggan').doc(customerId).get();

        if (customerSnapshot.exists) {
          var customerData = customerSnapshot.data() as Map<String, dynamic>;
          customerName = customerData['namaPelanggan'] ?? 'Tanpa Nama';
          address =
              '${customerData['detailAlamat'] ?? '-'}, ${customerData['kecamatan'] ?? '-'}, ${customerData['kota'] ?? '-'}, ${customerData['provinsi'] ?? '-'} - ${customerData['kodePos'] ?? '-'}';
        }
      }

      return {
        'customerName': customerName,
        'status': orderData['status'] ?? '',
        'totalPrice': orderData['total_price']?.toString() ?? '0',
        'address': address,
        'services': services,
      };
    } catch (e) {
      print('Error fetching order details: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Order'),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: fetchOrderDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Order tidak ditemukan'));
          }

          var orderData = snapshot.data!;
          List<Map<String, dynamic>> services = orderData['services'];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nama Pelanggan: ${orderData['customerName']}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Status: ${orderData['status']}'),
                const SizedBox(height: 8),
                Text('Total Harga: Rp ${orderData['totalPrice']}'),
                const SizedBox(height: 8),
                Text('Alamat: ${orderData['address']}'),
                const SizedBox(height: 16),
                const Text(
                  'Detail Layanan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Layanan')),
                        DataColumn(label: Text('Harga')),
                        DataColumn(label: Text('Jumlah')),
                        DataColumn(label: Text('Subtotal')),
                      ],
                      rows: services.map((service) {
                        return DataRow(cells: [
                          DataCell(Text(service['name'])),
                          DataCell(Text('Rp ${service['price']}')),
                          DataCell(Text('${service['quantity']}')),
                          DataCell(Text('Rp ${service['subtotal']}')),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
