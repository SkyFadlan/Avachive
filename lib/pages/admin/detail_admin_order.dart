import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class DetailAdminOrderPage extends StatelessWidget {
  final String orderId;

  const DetailAdminOrderPage({Key? key, required this.orderId}) : super(key: key);

  Future<Map<String, dynamic>?> fetchOrderDetails() async {
    try {
      DocumentSnapshot orderSnapshot =
          await FirebaseFirestore.instance.collection('orderan').doc(orderId).get();

      if (!orderSnapshot.exists) return null;

      var orderData = orderSnapshot.data() as Map<String, dynamic>;
      Map<String, dynamic>? customerData = orderData['customer'] as Map<String, dynamic>?;

      // Ambil layanan dari array items
      List<dynamic> items = orderData['items'] ?? [];
      List<Map<String, dynamic>> services = items.map((item) {
        return {
          'name': item['name'] ?? 'Tanpa Nama',
          'price': item['price'] ?? 0,
          'quantity': item['quantity'] ?? 1,
          'subtotal': (item['price'] ?? 0) * (item['quantity'] ?? 1),
          'kategori': item['kategori'] ?? 'Tidak Diketahui', // Ambil kategori layanan
        };
      }).toList();

      // Ambil waktu order
      Timestamp timestamp = orderData['timestamp'] ?? Timestamp.now();
      DateTime orderTime = timestamp.toDate();

      // Ambil waktu selesai dan diambil
      Timestamp? completedAt = orderData['completedAt'];
      Timestamp? pickedUpAt = orderData['pickedUpAt'];

      return {
        'customerName': customerData?['name'] ?? 'Tidak Diketahui',
        'noHandphone': customerData?['noHandphone'] ?? 'Tidak ada no handphone',
        'detailAlamat': customerData?['detailAlamat'] ?? 'Tidak ada detail alamat',
        'status': orderData['status'] ?? 'Diproses',
        'metodePembayaran': orderData['metodePembayaran'] ?? 'Diproses',
        'metodePengambilan': orderData['metodePengambilan'] ?? 'Tidak Diketahui', // Ambil metode pengambilan
        'totalPrice': orderData['total_price']?.toString() ?? '0',
        'address': '${customerData?['provinsi'] ?? '-'}, ${customerData?['kota'] ?? '-'}, ${customerData?['kecamatan'] ?? '-'}',
        'services': services,
        'orderTime': orderTime, // Tambahkan waktu order
        'completedAt': completedAt != null ? completedAt.toDate() : null, // Tambahkan waktu selesai
        'pickedUpAt': pickedUpAt != null ? pickedUpAt.toDate() : null, // Tambahkan waktu diambil
      };
    } catch (e) {
      print('Error fetching order details: $e');
      return null;
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
              pw.Text('No Handphone: ${orderData['noHandphone']}'),
              pw.Text('Alamat: ${orderData['address']}'),
              pw.Text('Detail Alamat: ${orderData['detailAlamat']}'),
              pw.Text('Metode Pengambilan: ${orderData['metodePengambilan']}', style: pw.TextStyle(fontSize: 16)), // Tambahkan metode pengambilan
              pw.SizedBox(height: 20),
              pw.Text('Detail Layanan', style: pw.TextStyle(fontSize: 24)),
              ...orderData['services'].map<pw.Widget>((service) {
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Nama: ${service['name']}'),
                    pw.Text('Kategori: ${service['kategori']}'), // Tambahkan kategori layanan
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
              pw.Text('Waktu Order: ${DateFormat('dd-MM-yyyy HH:mm').format(orderData['orderTime'])}'), // Format waktu order
              if (orderData['completedAt'] != null)
                pw.Text('Waktu Selesai: ${DateFormat('dd-MM-yyyy HH:mm').format(orderData['completedAt'])}'), // Format waktu selesai
              if (orderData['pickedUpAt'] != null)
                pw.Text('Waktu Diambil: ${DateFormat('dd-MM-yyyy HH:mm').format(orderData['pickedUpAt'])}'), // Format waktu diambil
            ],
          );
        },
      ),
    );

    // Mendapatkan direktori penyimpanan
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/order_$orderId.pdf';
    
    // Menyimpan file PDF
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    print('PDF disimpan di: $filePath');
  }

void sendWhatsAppMessage(Map<String, dynamic> orderData) async {
  String message = '''
📌 *Detail Pelanggan*  
Nama: ${orderData['customerName']}  
No Handphone: ${orderData['noHandphone']}  
Alamat: ${orderData['address']}  
Detail Alamat: ${orderData['detailAlamat']}  
Metode Pengambilan: ${orderData['metodePengambilan']}  

📌 *Detail Layanan*  
${orderData['services'].map((service) => 
  '   Nama Layanan: ${service['name']}\n'
  '   Kategori: ${service['kategori']}\n'
  '   Harga: Rp ${service['price']}\n'
  '   Jumlah: ${service['quantity']}\n'
  '   Subtotal: Rp ${service['subtotal']}\n'
).join('\n')}  

📌 *Status Order*  
${orderData['status']}  

📌 *Metode Pembayaran*  
${orderData['metodePembayaran']}  

📌 *Waktu Order*  
${DateFormat('dd-MM-yyyy HH:mm').format(orderData['orderTime'])}  

${orderData['completedAt'] != null ? '📌 *Waktu Selesai*  \n' + DateFormat('dd-MM-yyyy HH:mm').format(orderData['completedAt']) + '\n' : ''}  
${orderData['pickedUpAt'] != null ? '📌 *Waktu Diambil*  \n' + DateFormat('dd-MM-yyyy HH:mm').format(orderData['pickedUpAt']) + '\n' : ''}  
''';

  // Encode message to URI format
  final encodedMessage = Uri.encodeComponent(message);
  final phoneNumber = orderData['noHandphone'];
  final url = 'https://wa.me/$phoneNumber?text=$encodedMessage';

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
                Text('Detail Alamat: ${orderData['detailAlamat']}'),
                const SizedBox(height: 8),
                Text('Metode Pengambilan: ${orderData['metodePengambilan']}', style: TextStyle(fontWeight: FontWeight.bold)), // Tampilkan metode pengambilan
                const SizedBox(height: 8),
                Text('Waktu Order: ${DateFormat('dd-MM-yyyy HH:mm').format(orderData['orderTime'])}', style: TextStyle(fontWeight: FontWeight.bold)), // Tampilkan waktu order
                if (orderData['completedAt'] != null)
                  Text('Waktu Selesai: ${DateFormat('dd-MM-yyyy HH:mm').format(orderData['completedAt'])}', style: TextStyle(fontWeight: FontWeight.bold)), // Tampilkan waktu selesai
                if (orderData['pickedUpAt'] != null)
                  Text('Waktu Diambil: ${DateFormat('dd-MM-yyyy HH:mm').format(orderData['pickedUpAt'])}', style: TextStyle(fontWeight: FontWeight.bold)), // Tampilkan waktu diambil
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
                              Text('Kategori: ${service['kategori']}'), // Tampilkan kategori layanan
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () => savePdf(orderData),
                      child: const Text('Jadikan PDF'),
                    ),
                    ElevatedButton(
                      onPressed: () => sendWhatsAppMessage(orderData),
                      child: const Text('Kirim ke WhatsApp'),
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