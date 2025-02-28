import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TambahPelangganPage extends StatefulWidget {
  final String? pelangganId;
  final Map<String, dynamic>? initialData;

  const TambahPelangganPage({Key? key, this.pelangganId, this.initialData})
      : super(key: key);

  @override
  _TambahPelangganPageState createState() => _TambahPelangganPageState();
}

class _TambahPelangganPageState extends State<TambahPelangganPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _hpController = TextEditingController();
  final TextEditingController _provinsiController = TextEditingController();
  final TextEditingController _kotaController = TextEditingController();
  final TextEditingController _kecamatanController = TextEditingController();
  final TextEditingController _detailAlamatController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _namaController.text = widget.initialData!['namaPelanggan'] ?? '';
      _hpController.text = widget.initialData!['noHandphone'] ?? '';
      _provinsiController.text = widget.initialData!['provinsi'] ?? '';
      _kotaController.text = widget.initialData!['kota'] ?? '';
      _kecamatanController.text = widget.initialData!['kecamatan'] ?? '';
      _detailAlamatController.text = widget.initialData!['detailAlamat'] ?? '';
    }
  }

  void _simpanData() async {
    if (_formKey.currentState!.validate()) {
      final pelangganData = {
        'namaPelanggan': _namaController.text,
        'noHandphone': _hpController.text,
        'provinsi': _provinsiController.text,
        'kota': _kotaController.text,
        'kecamatan': _kecamatanController.text,
        'detailAlamat': _detailAlamatController.text,
      };

      if (widget.pelangganId != null) {
        // Update data
        await FirebaseFirestore.instance
            .collection('Pelanggan')
            .doc(widget.pelangganId)
            .update(pelangganData);
      } else {
        // Add new data
        await FirebaseFirestore.instance
            .collection('Pelanggan')
            .add(pelangganData);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data berhasil disimpan!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tambah Pelanggan',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(labelText: 'Nama Pelanggan'),
                validator: (value) => value!.isEmpty ? 'Harus diisi' : null,
              ),
              TextFormField(
                controller: _hpController,
                decoration: const InputDecoration(labelText: 'No Handphone'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Harus diisi';
                  } else if (value.length < 10 || value.length > 13) {
                    return 'Nomor telepon tidak valid';
                  } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                    return 'Hanya angka yang diperbolehkan';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _provinsiController,
                decoration: const InputDecoration(labelText: 'Provinsi'),
                validator: (value) => value!.isEmpty ? 'Harus diisi' : null,
              ),
              TextFormField(
                controller: _kotaController,
                decoration: const InputDecoration(labelText: 'Kota'),
                validator: (value) => value!.isEmpty ? 'Harus diisi' : null,
              ),
              TextFormField(
                controller: _kecamatanController,
                decoration: const InputDecoration(labelText: 'Kecamatan'),
                validator: (value) => value!.isEmpty ? 'Harus diisi' : null,
              ),
              TextFormField(
                controller: _detailAlamatController,
                decoration: const InputDecoration(
                    labelText: 'Detail Alamat (Nama Jalan, Gedung, No Rumah)'),
                maxLines: 2,
                validator: (value) => value!.isEmpty ? 'Harus diisi' : null,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _simpanData,
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50)),
                child: const Text('Simpan Data'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50)),
                child: const Text('Kembali'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}