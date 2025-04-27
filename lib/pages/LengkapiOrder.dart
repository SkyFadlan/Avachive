import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LengkapiOrderPage extends StatefulWidget {
  final List<Map<String, dynamic>> layananTerpilih;

  const LengkapiOrderPage({super.key, required this.layananTerpilih});

  @override
  State<LengkapiOrderPage> createState() => _LengkapiOrderPageState();
}

class _LengkapiOrderPageState extends State<LengkapiOrderPage> {
  String? selectedPelanggan;
  String? selectedMetodePembayaran;
  String? selectedMetodePengambilan;
  DateTime? waktuPembayaran;

  final _formKey = GlobalKey<FormState>();

  List<DropdownMenuItem<String>> _pelangganItems = [];

  @override
  void initState() {
    super.initState();
    fetchPelanggan();
  }

  Future<void> fetchPelanggan() async {
    final snapshot = await FirebaseFirestore.instance.collection('pelanggan').get();
    setState(() {
      _pelangganItems = snapshot.docs
          .map((doc) => DropdownMenuItem<String>(
                value: doc.id,
                child: Text(doc['nama']),
              ))
          .toList();
    });
  }

  void simpanOrder() async {
    if (_formKey.currentState!.validate() && waktuPembayaran != null) {
      await FirebaseFirestore.instance.collection('orderan').add({
        'layanan': widget.layananTerpilih,
        'pelanggan': selectedPelanggan,
        'metode_pembayaran': selectedMetodePembayaran,
        'metode_pengambilan': selectedMetodePengambilan,
        'waktu_pembayaran': waktuPembayaran,
        'status': 'Diproses',
        'created_at': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Order berhasil disimpan!'),
      ));

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Lengkapi Order')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Pilih pelanggan
              DropdownButtonFormField<String>(
                value: selectedPelanggan,
                items: _pelangganItems,
                onChanged: (val) => setState(() => selectedPelanggan = val),
                decoration: InputDecoration(labelText: 'Pilih Pelanggan'),
                validator: (value) => value == null ? 'Wajib pilih pelanggan' : null,
              ),
              SizedBox(height: 16),

              // Metode Pembayaran
              DropdownButtonFormField<String>(
                value: selectedMetodePembayaran,
                items: ['Cash', 'Transfer']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => setState(() => selectedMetodePembayaran = val),
                decoration: InputDecoration(labelText: 'Metode Pembayaran'),
                validator: (value) => value == null ? 'Wajib pilih metode pembayaran' : null,
              ),
              SizedBox(height: 16),

              // Metode Pengambilan
              DropdownButtonFormField<String>(
                value: selectedMetodePengambilan,
                items: ['Diantar', 'Ambil Sendiri']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => setState(() => selectedMetodePengambilan = val),
                decoration: InputDecoration(labelText: 'Metode Pengambilan'),
                validator: (value) => value == null ? 'Wajib pilih metode pengambilan' : null,
              ),
              SizedBox(height: 16),

              // Waktu Pembayaran
              ListTile(
                title: Text(waktuPembayaran == null
                    ? 'Pilih Waktu Pembayaran'
                    : waktuPembayaran.toString()),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2023),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) {
                    setState(() => waktuPembayaran = picked);
                  }
                },
              ),
              if (waktuPembayaran == null)
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Text("Wajib pilih waktu pembayaran", style: TextStyle(color: Colors.red)),
                ),
              SizedBox(height: 32),

              ElevatedButton(
                onPressed: simpanOrder,
                child: Text('Simpan Order'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
