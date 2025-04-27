import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TambahLayananPage extends StatefulWidget {
  const TambahLayananPage({super.key});

  @override
  State<TambahLayananPage> createState() => _TambahLayananPageState();
}

class _TambahLayananPageState extends State<TambahLayananPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();
  String? _selectedPackage;
  String? _selectedCategory;
  List<String> _packages = [];
  List<String> _categories = [];
  bool _isLoading = false;
  FocusNode _categoryFocusNode = FocusNode(); // FocusNode untuk kategori
  FocusNode _packageFocusNode = FocusNode(); // FocusNode untuk paket

  @override
  void initState() {
    super.initState();
    _fetchPackages();
    _fetchCategories();

    // Tambahkan listener untuk FocusNode
    _categoryFocusNode.addListener(() {
      setState(() {}); // Memperbarui tampilan saat fokus kategori berubah
    });

    _packageFocusNode.addListener(() {
      setState(() {}); // Memperbarui tampilan saat fokus paket berubah
    });
  }

  @override
  void dispose() {
    _categoryFocusNode.dispose(); // Pastikan untuk membuang FocusNode kategori
    _packageFocusNode.dispose(); // Pastikan untuk membuang FocusNode paket
    super.dispose();
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _tambahLayanan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('Layanan').add({
        'namaLayanan': _namaController.text.trim(),
        'Kategori': _selectedCategory,
        'Harga': int.parse(_hargaController.text.trim()),
        'Paket': _selectedPackage,
        'createdAt': FieldValue.serverTimestamp(),
      });

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Layanan berhasil ditambahkan!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Menampilkan dialog untuk menambahkan paket baru
  void _showAddPackageDialog() {
    TextEditingController _packageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Tambah Paket Baru"),
          content: TextField(
            controller: _packageController,
            decoration: const InputDecoration(
              labelText: "Nama Paket",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () async {
                String newPackage = _packageController.text.trim();
                if (newPackage.isNotEmpty) {
                  await _addNewPackage(newPackage);
                  Navigator.pop(context);
                }
              },
              child: const Text("Tambah"),
            ),
          ],
        );
      },
    );
  }

  // Menambahkan paket baru ke Firestore
  Future<void> _addNewPackage(String packageName) async {
    try {
      DocumentReference docRef =
          FirebaseFirestore.instance.collection('Paket').doc('paketLayanan');

      DocumentSnapshot snapshot = await docRef.get();

      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

        // Mencari key yang kosong
        int newKey = 1;
        while (data.containsKey(newKey.toString())) {
          newKey++;
        }

        await docRef.update({
          newKey.toString(): packageName,
        });
      } else {
        // Jika belum ada, buat baru
        await docRef.set({
          "1": packageName,
        });
      }

      _fetchPackages();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Paket '$packageName' berhasil ditambahkan!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  // Menampilkan dialog untuk menambahkan kategori baru
  void _showAddCategoryDialog() {
    TextEditingController _categoryController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Tambah Kategori Baru"),
          content: TextField(
            controller: _categoryController,
            decoration: const InputDecoration(
              labelText: "Nama Kategori",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () async {
                String newCategory = _categoryController.text.trim();
                if (newCategory.isNotEmpty) {
                  await _addNewCategory(newCategory);
                  Navigator.pop(context);
                }
              },
              child: const Text("Tambah"),
            ),
          ],
        );
      },
    );
  }

  // Menambahkan kategori baru ke Firestore
  Future<void> _addNewCategory(String categoryName) async {
    try {
      DocumentReference docRef =
          FirebaseFirestore.instance.collection('Paket').doc('Kategori');

      DocumentSnapshot snapshot = await docRef.get();

      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

        // Mencari key yang kosong
        int newKey = 1;
        while (data.containsKey(newKey.toString())) {
          newKey++;
        }

        await docRef.update({
          newKey.toString(): categoryName,
        });
      } else {
        // Jika belum ada, buat baru
        await docRef.set({
          "1": categoryName,
        });
      }

      _fetchCategories();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Kategori '$categoryName' berhasil ditambahkan!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  // Menampilkan dialog konfirmasi untuk menghapus kategori
  void _showDeleteCategoryDialog(String category) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Hapus Kategori"),
          content:
              Text("Apakah Anda yakin ingin menghapus kategori '$category'?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () async {
                await _deleteCategory(category);
                Navigator.pop(context);
              },
              child: const Text("Hapus"),
            ),
          ],
        );
      },
    );
  }

  // Menghapus kategori dari Firestore
  Future<void> _deleteCategory(String category) async {
    try {
      DocumentReference docRef =
          FirebaseFirestore.instance.collection('Paket').doc('Kategori');

      DocumentSnapshot snapshot = await docRef.get();

      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

        // Mencari key yang sesuai dengan kategori yang ingin dihapus
        String keyToDelete = data.keys
            .firstWhere((key) => data[key] == category, orElse: () => '');

        if (keyToDelete.isNotEmpty) {
          await docRef.update({
            keyToDelete: FieldValue.delete(),
          });
          _fetchCategories(); // Memperbarui daftar kategori
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Kategori '$category' berhasil dihapus!")),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  // Menampilkan dialog konfirmasi untuk menghapus paket
  void _showDeletePackageDialog(String package) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Hapus Paket"),
          content: Text("Apakah Anda yakin ingin menghapus paket '$package'?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () async {
                await _deletePackage(package);
                Navigator.pop(context);
              },
              child: const Text("Hapus"),
            ),
          ],
        );
      },
    );
  }

  // Menghapus paket dari Firestore
  Future<void> _deletePackage(String package) async {
    try {
      DocumentReference docRef =
          FirebaseFirestore.instance.collection('Paket').doc('paketLayanan');

      DocumentSnapshot snapshot = await docRef.get();

      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

        // Mencari key yang sesuai dengan paket yang ingin dihapus
        String keyToDelete = data.keys
            .firstWhere((key) => data[key] == package, orElse: () => '');

        if (keyToDelete.isNotEmpty) {
          await docRef.update({
            keyToDelete: FieldValue.delete(),
          });
          _fetchPackages(); // Memperbarui daftar paket
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Paket '$package' berhasil dihapus!")),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Layanan Baru'),
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
                validator: (value) => value == null || value.isEmpty
                    ? 'Harap isi nama layanan'
                    : null,
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      focusNode: _categoryFocusNode, // FocusNode untuk kategori
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(category),
                              // Tampilkan ikon hapus hanya saat dropdown dibuka
                              if (_categoryFocusNode.hasFocus)
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () {
                                    _showDeleteCategoryDialog(category);
                                  },
                                ),
                            ],
                          ),
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
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.add_circle,
                        color: Colors.blue, size: 30),
                    onPressed: _showAddCategoryDialog,
                  ),
                ],
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
                  if (value == null || value.isEmpty) return 'Harap isi harga';
                  if (int.tryParse(value) == null)
                    return 'Harap masukkan angka yang valid';
                  return null;
                },
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      focusNode: _packageFocusNode, // FocusNode untuk paket
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(package),
                              // Tampilkan ikon hapus hanya saat dropdown dibuka
                              if (_packageFocusNode.hasFocus)
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () {
                                    _showDeletePackageDialog(package);
                                  },
                                ),
                            ],
                          ),
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
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.add_circle,
                        color: Colors.blue, size: 30),
                    onPressed: _showAddPackageDialog,
                  ),
                ],
              ),
              const SizedBox(height: 25),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _tambahLayanan,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text(
                        'Simpan Layanan',
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
