import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart';

class DetailOrderPage extends StatelessWidget {
  final String orderId;

  const DetailOrderPage({Key? key, required this.orderId}) : super(key: key);

  Future<Map<String, dynamic>?> fetchOrderDetails() async {
    try {
      DocumentSnapshot orderSnapshot = await FirebaseFirestore.instance
          .collection('orderan')
          .doc(orderId)
          .get();

      if (!orderSnapshot.exists) return null;

      var orderData = orderSnapshot.data() as Map<String, dynamic>;
      Map<String, dynamic>? customerData =
          orderData['customer'] as Map<String, dynamic>?;

      // Ambil layanan dari array items
      List<dynamic> items = orderData['items'] ?? [];
      List<Map<String, dynamic>> services = items.map((item) {
        return {
          'name': item['name'] ?? 'Tanpa Nama',
          'price': item['price'] ?? 0,
          'quantity': item['quantity'] ?? 1,
          'subtotal': (item['price'] ?? 0) * (item['quantity'] ?? 1),
          'kategori':
              item['kategori'] ?? 'Tidak Diketahui', // Ambil kategori layanan
        };
      }).toList();

      // Ambil waktu order
      Timestamp timestamp = orderData['timestamp'] ?? Timestamp.now();
      DateTime orderTime = timestamp.toDate();
      // Ambil waktu pembayaran
      Timestamp? paidAt = orderData['paidAt'];

      // Ambil waktu selesai dan diambil
      Timestamp? completedAt = orderData['completedAt'];
      Timestamp? pickedUpAt = orderData['pickedUpAt'];

      return {
        'customerName': customerData?['name'] ?? 'Tidak Diketahui',
        'noHandphone': customerData?['noHandphone'] ?? 'Tidak ada no handphone',
        'detailAlamat':
            customerData?['detailAlamat'] ?? 'Tidak ada detail alamat',
        'status': orderData['status'] ?? 'Diproses',
        'metodePembayaran': orderData['metodePembayaran'] ?? 'Diproses',
        'alamatLengkap':
            customerData?['alamatLengkap'] ?? 'Alamat Tidak Diketahui',
        'metodePengambilan': orderData['metodePengambilan'] ??
            'Tidak Diketahui', // Ambil metode pengambilan
        'waktuPembayaran': orderData['waktuPembayaran']?.toString() ?? '0',
        'totalPrice': orderData['total_price']?.toString() ?? '0',
        'uangDiberikan':
            orderData['uangDiberikan'] ?? 0, // Ambil uang yang diberikan
        'kembalian': orderData['kembalian'] ?? 0, // Ambil kembalian
        'paidAt': paidAt != null ? paidAt.toDate() : null,
        'address':
            '${customerData?['provinsi'] ?? '-'}, ${customerData?['kota'] ?? '-'}, ${customerData?['kecamatan'] ?? '-'}, ${customerData?['kodePos'] ?? '-'}, ${customerData?['rtRw'] ?? '-'}, ${customerData?['noRumah'] ?? '-'}',
        'services': services,
        'orderTime': orderTime, // Tambahkan waktu order
        'completedAt': completedAt != null
            ? completedAt.toDate()
            : null, // Tambahkan waktu selesai
        'pickedUpAt': pickedUpAt != null
            ? pickedUpAt.toDate()
            : null, // Tambahkan waktu diambil
      };
    } catch (e) {
      print('Error fetching order details: $e');
      return null;
    }
  }

  Future<void> _bukaGoogleMaps(BuildContext context, String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);

      if (locations.isNotEmpty) {
        final location = locations.first;
        final googleMapsUrl =
            'https://www.google.com/maps/search/?api=1&query=${location.latitude},${location.longitude}';

        if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
          await launchUrl(Uri.parse(googleMapsUrl),
              mode: LaunchMode.externalApplication);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tidak dapat membuka Google Maps.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lokasi tidak ditemukan.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> savePdf(Map<String, dynamic> orderData) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text('Detail Pelanggan', style: pw.TextStyle(fontSize: 24)),
              pw.Text('Nama Pelanggan: ${orderData['customerName']}'),
              pw.Text('No Handphone: ${orderData['no Handphone']}'),
              pw.Text('Alamat: ${orderData['address']}'),
              pw.Text('Alamat Lengkap: ${orderData['alamatLengkap']}'),
              pw.Text('Metode Pengambilan: ${orderData['metodePengambilan']}',
                  style: pw.TextStyle(fontSize: 16)),
              pw.Text('Waktu Pembayaran: ${orderData['waktuPembayaran']}'),
              pw.SizedBox(height: 20),
              pw.Text('Detail Layanan', style: pw.TextStyle(fontSize: 24)),
              ...orderData['services'].map<pw.Widget>((service) {
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Nama: ${service['name']}'),
                    pw.Text('Kategori: ${service['kategori']}'),
                    pw.Text('Harga: Rp ${service['price']}'),
                    pw.Text('Jumlah: ${service['quantity']}'),
                    pw.Text('Subtotal: Rp ${service['subtotal']}'),
                    pw.SizedBox(height: 10),
                  ],
                );
              }).toList(),
              pw.SizedBox(height: 20),
              pw.Text('Metode Pembayaran: ${orderData['metodePembayaran']}'),
              pw.Text('Status: ${orderData['status']}'),
              pw.Text(
                  'Waktu Order: ${DateFormat('dd-MM-yyyy HH:mm').format(orderData['orderTime'])}'),
              if (orderData['completedAt'] != null)
                pw.Text(
                    'Waktu Selesai: ${DateFormat('dd-MM-yyyy HH:mm').format(orderData['completedAt'])}'),
              if (orderData['pickedUpAt'] != null)
                pw.Text(
                    'Waktu Diambil: ${DateFormat('dd-MM-yyyy HH:mm').format(orderData['pickedUpAt'])}'),
              if (orderData['paidAt'] != null)
                pw.Text(
                    'Waktu Pembayaran: ${DateFormat('dd-MM-yyyy HH:mm').format(orderData['paidAt'])}'),
            ],
          );
        },
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/order_$orderId.pdf';

    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    print('PDF disimpan di: $filePath');
  }

  void sendWhatsAppMessage(String phoneNumber) async {
    final formattedPhoneNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');
    final url = 'https://wa.me/$formattedPhoneNumber';

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Tidak dapat membuka URL: $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Order'),
        backgroundColor: Colors.teal,
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
                const Text(
                  'Detail Pelanggan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Nama Pelanggan: ${orderData['customerName']}'),
                const SizedBox(height: 8),
                Text('No Handphone: ${orderData['noHandphone']}'),
                const SizedBox(height: 8),
                Text('Alamat: ${orderData['address']}'),
                const SizedBox(height: 8),
                Text('Alamat Lengkap: ${orderData['alamatLengkap']}'),
                const SizedBox(height: 8),
                Text('Metode Pengambilan: ${orderData['metodePengambilan']}',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Metode Pembayaran: ${orderData['metodePembayaran']}',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Waktu Pembayaran: ${orderData['waktuPembayaran']}',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                    'Waktu Order: ${DateFormat('dd-MM-yyyy HH:mm').format(orderData['orderTime'])}',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                if (orderData['completedAt'] != null)
                  Text(
                      'Waktu Selesai: ${DateFormat('dd-MM-yyyy HH:mm').format(orderData['completedAt'])}',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                if (orderData['paidAt'] != null)
                  Text(
                      'Waktu Pembayaran: ${DateFormat('dd-MM-yyyy HH:mm').format(orderData['paidAt'])}',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                if (orderData['pickedUpAt'] != null)
                  Text(
                      'Waktu Diambil: ${DateFormat('dd-MM-yyyy HH:mm').format(orderData['pickedUpAt'])}',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                const Text(
                  'Detail Layanan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: services.length,
                    itemBuilder: (context, index) {
                      final service = services[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          title: Text(service['name']),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Kategori: ${service['kategori']}'),
                              Text('Harga: Rp ${service['price']}'),
                              Text('Jumlah: ${service['quantity']}'),
                              Text('Subtotal: Rp ${service['subtotal']}'),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Text('Total Harga: Rp ${orderData['totalPrice']}'),
                Text('Uang Diberikan: Rp ${orderData['uangDiberikan']}'),
                Text('Kembalian: Rp ${orderData['kembalian']}'),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        sendWhatsAppMessage(orderData['noHandphone']);
                      },
                      icon: const Icon(Icons.chat),
                      label: const Text('Kirim WhatsApp'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.map),
                      label: const Text("Buka Maps"),
                      onPressed: () =>
                          _bukaGoogleMaps(context, orderData['alamatLengkap']),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
