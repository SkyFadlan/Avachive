import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class LunasiPembayaranPage extends StatefulWidget {
  final String orderId;
  final int totalAmount; // Total yang harus dibayar

  const LunasiPembayaranPage({
    Key? key,
    required this.orderId,
    required this.totalAmount,
  }) : super(key: key);

  @override
  _LunasiPembayaranPageState createState() => _LunasiPembayaranPageState();
}

class _LunasiPembayaranPageState extends State<LunasiPembayaranPage> {
  String? selectedPaymentMethod; // Menyimpan metode pembayaran yang dipilih
  num? uangDiberikan; // Menggunakan num untuk menyimpan nominal uang yang diberikan
  num sisaPembayaran = 0; // Menggunakan num untuk menyimpan sisa pembayaran

  List<String> paymentMethods = [
    "Tunai",
    "Non Tunai",
  ];

  @override
  void initState() {
    super.initState();
    sisaPembayaran = widget.totalAmount; // Set sisa pembayaran ke total yang harus dibayar
    print('Total yang harus dibayar: $sisaPembayaran'); // Tambahkan log ini
  }

  void _lunasiOrder() async {
    if (selectedPaymentMethod == "Tunai" && (uangDiberikan == null || uangDiberikan! < sisaPembayaran)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Uang yang diberikan tidak cukup")),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('orderan').doc(widget.orderId).update({
        'status': 'Selesai',
        'waktuPembayaran': 'Bayar Sekarang',
        'uangDiberikan': selectedPaymentMethod == "Tunai" ? uangDiberikan : null,
        'kembalian': selectedPaymentMethod == "Tunai" ? (uangDiberikan! - sisaPembayaran).clamp(0, double.infinity) : null,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pembayaran berhasil dilunasi!")),
      );

      Navigator.pop(context); // Kembali ke halaman sebelumnya
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lunasi Pembayaran'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total yang harus dibayar: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(sisaPembayaran)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Pilih Metode Pembayaran',
                border: OutlineInputBorder(),
              ),
              value: selectedPaymentMethod,
              items: paymentMethods.map((method) {
                return DropdownMenuItem<String>(
                  value: method,
                  child: Text(method),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedPaymentMethod = value;
                  uangDiberikan = null; // Reset uangDiberikan saat metode pembayaran berubah
                });
              },
              hint: const Text("Pilih Metode Pembayaran"),
            ),
            const SizedBox(height: 16),
            if (selectedPaymentMethod == "Tunai") ...[
              TextField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Nominal Uang Diberikan',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    uangDiberikan = num.tryParse(value); // Menggunakan num
                  });
                },
              ),
              const SizedBox(height: 16),
            ],
            ElevatedButton(
              onPressed: _lunasiOrder,
              child: const Text ("Lunas"),
            ),
          ],
        ),
      ),
    );
  }
} 