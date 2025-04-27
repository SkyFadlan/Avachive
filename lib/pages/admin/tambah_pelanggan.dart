import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code_picker/country_code_picker.dart';

class TambahAdminPelangganPage extends StatefulWidget {
  final String? pelangganId;
  final Map<String, dynamic>? initialData;

  const TambahAdminPelangganPage({Key? key, this.pelangganId, this.initialData})
      : super(key: key);

  @override
  _TambahAdminPelangganPageState createState() =>
      _TambahAdminPelangganPageState();
}

class _TambahAdminPelangganPageState extends State<TambahAdminPelangganPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _hpController = TextEditingController();
  final TextEditingController _provinsiController = TextEditingController();
  final TextEditingController _kotaController = TextEditingController();
  final TextEditingController _kecamatanController = TextEditingController();
  final TextEditingController _detailAlamatController = TextEditingController();
  final TextEditingController _kodePosController =
      TextEditingController(); // Kode pos
  final TextEditingController _rtRwController = TextEditingController();

  String _selectedCountryCode = '+62'; // Default ke Indonesia

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _namaController.text = widget.initialData!['namaPelanggan'] ?? '';
      _hpController.text = widget.initialData!['noHandphone']
              ?.replaceFirst(_selectedCountryCode, '') ??
          '';
      _provinsiController.text = widget.initialData!['provinsi'] ?? '';
      _kotaController.text = widget.initialData!['kota'] ?? '';
      _kecamatanController.text = widget.initialData!['kecamatan'] ?? '';
      _detailAlamatController.text = widget.initialData!['detailAlamat'] ?? '';
      _kodePosController.text =
      widget.initialData!['kodePos'] ?? ''; // Mengisi kode pos
    }
  }

  void _simpanData() async {
    if (_formKey.currentState!.validate()) {
      final pelangganData = {
        'namaPelanggan': _namaController.text,
        'noHandphone': '$_selectedCountryCode${_hpController.text}',
        'provinsi': _provinsiController.text,
        'kota': _kotaController.text,
        'kecamatan': _kecamatanController.text,
        'detailAlamat': _detailAlamatController.text,
        'kodePos': _kodePosController.text,
        'rtRw': _rtRwController.text,
        'alamatLengkap':
            '${_detailAlamatController.text}, RT/RW ${_rtRwController.text}, ${_kecamatanController.text}, ${_kotaController.text}, ${_provinsiController.text}, ${_kodePosController.text}',
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
                validator: (value) => value!.isEmpty ? 'Har us diisi' : null,
              ),
              Row(
                children: [
                  CountryCodePicker(
                    onChanged: (code) {
                      setState(() {
                        _selectedCountryCode = code.dialCode!;
                      });
                    },
                    initialSelection: 'ID', // Kode negara Indonesia
                    showCountryOnly: false, // Menampilkan kode negara dan nama
                    showOnlyCountryWhenClosed: false,
                    favorite: const [
                      '+62',
                      'ID'
                    ], // Menyukai kode negara Indonesia
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: _hpController,
                      decoration:
                          const InputDecoration(labelText: 'No Handphone'),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Harus diisi';
                        } else if (value.length < 9 || value.length > 12) {
                          return 'Nomor telepon tidak valid';
                        } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                          return 'Hanya angka yang diperbolehkan';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
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
                    labelText: 'Detail Alamat (Nama Jalan,Blok/Gg No Rumah.)'),
                maxLines: 2,
                validator: (value) => value!.isEmpty ? 'Harus diisi' : null,
              ),
              TextFormField(
                controller: _rtRwController,
                decoration:
                    const InputDecoration(labelText: 'RT/RW (contoh: 01/04)'),
                validator: (value) => value!.isEmpty ? 'Harus diisi' : null,
              ),
              TextFormField(
                controller: _kodePosController,
                decoration: const InputDecoration(labelText: 'Kode Pos'),
                keyboardType: TextInputType.number,
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
