import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> requestStoragePermission() async {
  var status = await Permission.storage.status;
  if (!status.isGranted) {
    await Permission.storage.request();
  }
}

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
        'alamatLengkap': customerData?['alamatLengkap'] ?? 'Tidak Diketahui',
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

  Future<void> savePdf(Map<String, dynamic> orderData) async {
    try {
      final pdf = pw.Document();
      final formatter = NumberFormat.currency(
          locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

      pdf.addPage(
        pw.MultiPage(
          margin: const pw.EdgeInsets.all(24),
          build: (pw.Context context) => [
            pw.Center(
              child: pw.Text(
                'DETAIL ORDERAN',
                style:
                    pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Divider(),

            // Section Detail Pelanggan
            pw.Text('📌 Detail Pelanggan',
                style:
                    pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.Bullet(text: 'Nama: ${orderData['customerName']}'),
            pw.Bullet(text: 'No Handphone: ${orderData['noHandphone']}'),
            pw.Bullet(text: 'Alamat: ${orderData['address']}'),
            pw.Bullet(text: 'Alamat Lengkap: ${orderData['detailAlamat']}'),
            pw.Bullet(
                text: 'Metode Pengambilan: ${orderData['metodePengambilan']}'),
            pw.Bullet(
                text: 'Metode Pembayaran: ${orderData['metodePembayaran']}'),
            pw.SizedBox(height: 16),

            pw.Divider(),

            // Section Layanan
            pw.Text('📌 Daftar Layanan',
                style:
                    pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.Table.fromTextArray(
              border: pw.TableBorder.all(color: PdfColors.grey),
              headers: ['Nama', 'Kategori', 'Harga', 'Jumlah', 'Subtotal'],
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
              cellAlignment: pw.Alignment.centerLeft,
              cellStyle: pw.TextStyle(fontSize: 10),
              data: (orderData['services'] as List<Map<String, dynamic>>)
                  .map((service) {
                return [
                  service['name'] ?? '',
                  service['kategori'] ?? '',
                  formatter.format(service['price'] ?? 0),
                  service['quantity'].toString(),
                  formatter.format(service['subtotal'] ?? 0),
                ];
              }).toList(),
            ),
            pw.SizedBox(height: 16),

            pw.Divider(),

            // Section Pembayaran
            pw.Text('📌 Pembayaran',
                style:
                    pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.Bullet(
                text:
                    'Total Harga: ${formatter.format(orderData['totalPrice'])}'),
            pw.Bullet(
                text:
                    'Uang Diberikan: ${formatter.format(orderData['uangDiberikan'])}'),
            pw.Bullet(
                text: 'Kembalian: ${formatter.format(orderData['kembalian'])}'),
            pw.Bullet(
                text: 'Waktu Pembayaran: ${orderData['waktuPembayaran']}'),
            pw.SizedBox(height: 16),

            pw.Divider(),

            // Section Status Orderan
            pw.Text('📌 Status Orderan',
                style:
                    pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.Bullet(text: 'Status: ${orderData['status']}'),
            pw.Bullet(
                text:
                    'Waktu Order: ${DateFormat('dd-MM-yyyy HH:mm').format(orderData['orderTime'])}'),
            if (orderData['completedAt'] != null)
              pw.Bullet(
                  text:
                      'Waktu Selesai: ${DateFormat('dd-MM-yyyy HH:mm').format(orderData['completedAt'])}'),
            if (orderData['pickedUpAt'] != null)
              pw.Bullet(
                  text:
                      'Waktu Diambil: ${DateFormat('dd-MM-yyyy HH:mm').format(orderData['pickedUpAt'])}'),
            if (orderData['paidAt'] != null)
              pw.Bullet(
                  text:
                      'Waktu Pembayaran: ${DateFormat('dd-MM-yyyy HH:mm').format(orderData['paidAt'])}'),
          ],
        ),
      );

      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/Order_$orderId.pdf';
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      print('✅ PDF berhasil disimpan di: $filePath');
    } catch (e) {
      print('Error saving PDF: $e');
    }
  }

  void sendWhatsAppMessage(Map<String, dynamic> orderData) async {
    final services = orderData['services'] as List<Map<String, dynamic>>;
    final totalHarga =
        services.fold<num>(0, (sum, item) => sum + (item['subtotal'] ?? 0));

    final formatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    String message = '''
📌 *Detail Pelanggan*  
Nama: ${orderData['customerName']}  
No Handphone: ${orderData['noHandphone']}  
Alamat: ${orderData['address']}  
Alamat Lengkap: ${orderData['alamatLengkap']}  
Metode Pengambilan: ${orderData['metodePengambilan']}  

📌 *Detail Layanan*  
${services.map((service) => '   Nama Layanan: ${service['name']}\n'
            '   Kategori: ${service['kategori']}\n'
            '   Harga: ${formatter.format(service['price'])}\n'
            '   Jumlah: ${service['quantity']}\n'
            '   Subtotal: ${formatter.format(service['subtotal'])}\n').join('\n')}  

📌 *Waktu Pembayaran*  
${orderData['waktuPembayaran']}

📌 *Total Harga*  
${formatter.format(totalHarga)}  

📌 *Uang Diberikan*  
${formatter.format(orderData['uangDiberikan'])}  

📌 *Kembalian*  
${formatter.format(orderData['kembalian'])}  

📌 *Status Order*  
${orderData['status']}  

📌 *Metode Pembayaran*  
${orderData['metodePembayaran']}  

📌 *Waktu Order*  
${DateFormat('dd-MM-yyyy HH:mm').format(orderData['orderTime'])}  

${orderData['completedAt'] != null ? '📌 *Waktu Selesai*  \n' + DateFormat('dd-MM-yyyy HH:mm').format(orderData['completedAt']) + '\n' : ''}  
${orderData['pickedUpAt'] != null ? '📌 *Waktu Diambil*  \n' + DateFormat('dd-MM-yyyy HH:mm').format(orderData['pickedUpAt']) + '\n' : ''}  
${orderData['paidAt'] != null ? '📌 *Waktu Pembayaran*  \n' + DateFormat('dd-MM-yyyy HH:mm').format(orderData['paidAt']) + '\n' : ''}
''';

    final encodedMessage = Uri.encodeComponent(message);
    final phoneNumber = orderData['noHandphone'].replaceAll(RegExp(r'\D'), '');
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
                  mainAxisSize: MainAxisSize.min, // Tambahkan ini!
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        await requestStoragePermission(); // Meminta izin
                        await savePdf(orderData);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('PDF berhasil disimpan'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text('Download PDF'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        sendWhatsAppMessage(orderData);
                      },
                      icon: const Icon(Icons.chat),
                      label: const Text('Kirim WhatsApp'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
