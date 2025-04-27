import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditLayananPage extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> currentData;

  const EditLayananPage({
    super.key,
    required this.docId,
    required this.currentData,
  });

  @override
  State<EditLayananPage> createState() => _EditLayananPageState();
}

class _EditLayananPageState extends State<EditLayananPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late TextEditingController _hargaController;
  String? _selectedCategory;
  String? _selectedPackage;
  List<String> _categories = [];
  List<String> _packages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.currentData['namaLayanan']);
    _hargaController = TextEditingController(text: widget.currentData['Harga'].toString());
    _selectedCategory = widget.currentData['Kategori'];
    _selectedPackage = widget.currentData['Paket'];
    _fetchCategories();
    _fetchPackages();
  }

  // Mengambil daftar kategori dari Firestore
  void _fetchCategories() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('Paket')
          .doc('Kategori')
          .get();

      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        setState(() {
          _categories = data.values.map((e) => e.toString()).toList();
        });
      }
    } catch (e) {
      _showErrorSnackBar(e.toString());
    }
  }

  // Mengambil daftar paket dari Firestore
  void _fetchPackages() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('Paket')
          .doc('paketLayanan')
          .get();

      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        setState(() {
          _packages = data.values.map((e) => e.toString()).toList();
        });
      }
    } catch (e) {
      _showErrorSnackBar(e.toString());
    }
  }

  Future<void> _updateLayanan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('Layanan').doc(widget.docId).update({
        'namaLayanan': _namaController.text.trim(),
        'Kategori': _selectedCategory,
        'Harga': int.parse(_hargaController.text.trim()),
        'Paket': _selectedPackage,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Layanan berhasil diperbarui!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $message')),
    );
  }

void _showConfirmationDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Apakah kamu yakin ingin menyimpan perubahan layanan ini?'),
        actions: [
          TextButton(
            child: const Text('Batal'),
            onPressed: () {
              Navigator.of(context).pop(); // Tutup dialog
            },
          ),
          TextButton(
            child: const Text('Ya'),
            onPressed: () {
              Navigator.of(context).pop(); // Tutup dialog dulu
              _updateLayanan(); // Jalankan fungsi update
            },
          ),
        ],
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Layanan'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _namaController,
                decoration: InputDecoration(
                  labelText: 'Nama Layanan',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Harap isi nama layanan';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Pilih Kategori',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                },
                validator: (value) =>
                    value == null ? 'Harap pilih kategori' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _hargaController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Harga',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Harap isi harga';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Harap masukkan angka yang valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: _selectedPackage,
                decoration: InputDecoration(
                  labelText: 'Pilih Paket',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                items: _packages.map((String package) {
                  return DropdownMenuItem<String>(
                    value: package,
                    child: Text(package),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedPackage = newValue;
                  });
                },
                validator: (value) =>
                    value == null ? 'Harap pilih paket' : null,
              ),
              const SizedBox(height: 25),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _showConfirmationDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text(
                        'Simpan Perubahan',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}