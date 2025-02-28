import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dashboard.dart';
import 'pelanggan.dart';
import 'data_order.dart';
import 'pengaturan.dart';

class BuatOrderPage extends StatefulWidget {
  const BuatOrderPage({super.key});

  @override
  _BuatOrderPageState createState() => _BuatOrderPageState();
}

class _BuatOrderPageState extends State<BuatOrderPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 2;
  String? selectedCustomer;
  String? selectedCustomerPhone; // Menyimpan nomor handphone pelanggan
  String? selectedCustomerAddress; // Menyimpan alamat pelanggan
  String? selectedCustomerProvinsi; // Menyimpan provinsi pelanggan
  String? selectedCustomerKota; // Menyimpan kota pelanggan
  String? selectedCustomerKecamatan; // Menyimpan kecamatan pelanggan
  List<Map<String, dynamic>> selectedItems = [];
  int totalHarga = 0;

  // Variabel untuk pencarian
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const DashboardPage()));
        break;
      case 1:
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const PelangganPage()));
        break;
      case 2:
        // Halaman Buat Order, tidak perlu navigasi
        break;
      case 3:
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const DataOrderPage()));
        break;
      case 4:
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const PengaturanPage()));
        break;
    }
  }

  Widget _buildItemList(String collectionName) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection(collectionName).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var items = snapshot.data!.docs.where((doc) {
          var data = doc.data() as Map<String, dynamic>;
          // Filter berdasarkan pencarian
          return data["namaLayanan"].toString().toLowerCase().contains(searchQuery.toLowerCase());
        }).toList();

        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            var data = items[index].data() as Map<String, dynamic>;
            return ListTile(
              title: Text(data["namaLayanan"] ?? ""),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Kategori: ${data["Kategori"] ?? ""}"),
                  Text("Paket: ${data["Paket"] ?? ""}"),
                  Text("Rp ${data["Harga"] ?? "0"}"),
                ],
              ),
              trailing: ElevatedButton(
                onPressed: () {
                  _tambahItem({
                    "name": data["namaLayanan"] ?? "",
                    "price": int.tryParse(data["Harga"] ?? "0") ?? 0,
                    "quantity": 1,
                  });
                },
                child: const Text("Tambah"),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: InputDecoration(
          labelText: 'Cari Layanan',
          border: OutlineInputBorder(),
        ),
        onChanged: (value) {
          setState(() {
            searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildSelectedItems() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (selectedCustomer != null) ...[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Pelanggan: $selectedCustomer",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "No Handphone: $selectedCustomerPhone",
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const Divider(),
        ] else
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                _pilihPelanggan();
              },
              child: const Text("Pilih Pelanggan"),
            ),
          ),
        if (selectedItems.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: const Text(
              "Layanan yang Dipilih:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          ...selectedItems.map((item) => Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  title: Text(item["name"]),
                  subtitle: Text("Rp ${item["price"]} x ${item["quantity"]}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          _ubahQuantity(item, -1);
                        },
                      ),
                      Text('${item["quantity"]}'),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          _ubahQuantity(item, 1);
                        },
                      ),
                    ],
                  ),
                ),
              )),
          const Divider(),
        ],
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "Total Harga: Rp $totalHarga",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        ElevatedButton(
          onPressed: _simpanOrder,
          child: const Text("Simpan Order"),
        ),
      ],
    );
  }

  void _ubahQuantity(Map<String, dynamic> item, int change) {
    setState(() {
      item["quantity"] += change;
      if (item["quantity"] <= 0) {
        selectedItems.remove(item);
      }
      _hitungTotal();
    });
  }

  void _tambahItem(Map<String, dynamic> item) {
    setState(() {
      var existingItem = selectedItems.firstWhere(
        (element) => element["name"] == item["name"],
        orElse: () => {},
      );

      if (existingItem.isNotEmpty) {
        existingItem["quantity"] += 1;
      } else {
        selectedItems.add({
          "name": item["name"],
          "price": item["price"],
          "quantity": 1,
        });
      }
      _hitungTotal();
    });
  }

  void _hitungTotal() {
    setState(() {
      totalHarga = selectedItems.fold(
          0,
          (sum, item) =>
              sum +
              ((item["price"] as num?)?.toInt() ?? 0) *
                  ((item["quantity"] as num?)?.toInt() ?? 1));
    });
  }

  void _simpanOrder() {
    if (selectedCustomer == null || selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Harap pilih pelanggan dan layanan")),
      );
      return;
    }

    FirebaseFirestore.instance.collection('orderan').add({
      "customer": selectedCustomer,
      "items": selectedItems,
      "total_price": totalHarga,
      "timestamp": Timestamp.now(),
      "status": "Diproses", // Pastikan status disimpan sebagai "Diproses"
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Order berhasil disimpan!")),
      );

      Future.delayed(const Duration(milliseconds: 500), () {
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DataOrderPage()),
          );
        }
      });
    }).catchError((error) {
      ScaffoldMessenger.of(context ).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan: $error")),
      );
    });
  }

  void _pilihPelanggan() async {
    try {
      var pelangganSnapshot =
          await FirebaseFirestore.instance.collection('Pelanggan').get();

      if (pelangganSnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Tidak ada pelanggan tersedia.")),
        );
        return;
      }

      List<Map<String, dynamic>> pelangganList = pelangganSnapshot.docs
          .map((doc) => {
                "nama": doc.data()["namaPelanggan"] ?? "Tanpa Nama",
                "noHandphone": doc.data()["noHandphone"] ?? "",
                "provinsi": doc.data()["provinsi"] ?? "",
                "kota": doc.data()["kota"] ?? "",
                "kecamatan": doc.data()["kecamatan"] ?? "",
              })
          .toList();

      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Pilih Pelanggan"),
              content: SizedBox(
                height: 300,
                child: ListView.builder(
                  itemCount: pelangganList.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(pelangganList[index]["nama"]),
                      onTap: () {
                        setState(() {
                          selectedCustomer = pelangganList[index]["nama"];
                          selectedCustomerPhone = pelangganList[index]["noHandphone"];
                          selectedCustomerProvinsi = pelangganList[index]["provinsi"];
                          selectedCustomerKota = pelangganList[index]["kota"];
                          selectedCustomerKecamatan = pelangganList[index]["kecamatan"];
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            );
          },
        );
      }
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
        title: const Text(
          'Buat Order',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          _buildSearchField(),
          Expanded(
            child: _buildItemList('Layanan'),
          ),
          if (selectedItems.isNotEmpty && selectedCustomer == null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: _pilihPelanggan,
                child: const Text("Pilih Pelanggan"),
              ),
            ),
          if (selectedCustomer != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Pelanggan: $selectedCustomer",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          if (selectedItems.isNotEmpty) _buildSelectedItems(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home,
                color: _selectedIndex == 0 ? Colors.blue : Colors.grey),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person,
                color: _selectedIndex == 1 ? Colors.blue : Colors.grey),
            label: 'Pelanggan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart,
                color: _selectedIndex == 2 ? Colors.blue : Colors.grey),
            label: 'Buat Order',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.checklist,
                color: _selectedIndex == 3 ? Colors.blue : Colors.grey),
            label: 'Data Order',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings,
                color: _selectedIndex == 4 ? Colors.blue : Colors.grey),
            label: 'Pengaturan',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        iconSize: 20,
        selectedLabelStyle:
            const TextStyle(fontSize: 12),
        unselectedLabelStyle:
            const TextStyle(fontSize: 12),
        onTap: _onItemTapped,
      ),
    );
  }
}