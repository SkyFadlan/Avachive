import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dashboard.dart';
import 'pelanggan.dart';
import 'data_order.dart';
import 'pengaturan.dart';
import 'package:intl/intl.dart';

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
  String? selectedCustomerKodePos;
  String? selectedCustomerNoRumah;
  String? selectedCustomerRtRw;
  String? selectedCustomerDetailAlamat; // Menyimpan detail alamat pelanggan
  String? selectedCustomerAlamatLengkap;
  String? selectedWaktuPembayaran;
  List<String> waktuPembayaranOptions = [
    "Bayar Sekarang",
    "Bayar Nanti",
  ];
  List<Map<String, dynamic>> selectedItems = [];
  int totalHarga = 0;

  // Variabel untuk pencarian
  String searchQuery = '';

  int? uangDiberikan; // Menyimpan nominal uang yang diberikan oleh pelanggan
  int kembalian = 0; // Menyimpan nilai kembalian
  int? dp; // Menyimpan nominal DP yang diberikan
  int sisaPembayaran = 0; // Menyimpan sisa pembayaran

  // Variabel untuk metode pembayaran
  String? selectedPaymentMethod; // Menyimpan metode pembayaran yang dipilih
  List<String> paymentMethods = []; // Menyimpan daftar metode pembayaran

  // Variabel untuk metode pengambilan
  String? selectedPickupMethod; // Menyimpan metode pengambilan yang dipilih
  List<String> pickupMethods = [
    "Diantar ke Alamat",
    "Diambil Sendiri"
  ]; // Daftar metode pengambilan

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
    _fetchPaymentMethods(); // Mengambil metode pembayaran saat halaman diinisialisasi
  }

  String formatCurrency(int amount) {
    final formatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
    return formatter.format(amount);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Mengambil metode pembayaran dari Firestore
  void _fetchPaymentMethods() async {
    try {
      var snapshot =
          await FirebaseFirestore.instance.collection('Pembayaran').get();
      setState(() {
        paymentMethods = snapshot.docs
            .map((doc) => doc['metodePembayaran'] as String)
            .toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text("Terjadi kesalahan saat mengambil metode pembayaran: $e")),
      );
    }
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
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const PengaturanPage()));
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
          return data["namaLayanan"]
              .toString()
              .toLowerCase()
              .contains(searchQuery.toLowerCase());
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
                  Text(formatCurrency((data["Harga"] as num?)?.toInt() ?? 0)),
                ],
              ),
              trailing: ElevatedButton(
                onPressed: () {
                  _tambahItem({
                    "name": data["namaLayanan"] ?? "",
                    "price": (data["Harga"] as num?)?.toInt() ??
                        0, // Pastikan ini adalah number
                    "quantity": 1,
                    "kategori":
                        data["Kategori"] ?? "", // Menyimpan kategori layanan
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
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Kategori: ${item["kategori"]}"),
                      Text(
                          "${formatCurrency(item["price"])} x ${item["quantity"]}"),
                    ],
                  ),
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
            "Total Harga: ${formatCurrency(totalHarga)}",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        // Dropdown untuk memilih waktu pembayaran
        if (selectedItems.isNotEmpty) _buildWaktuPembayaranDropdown(),
        // Dropdown untuk memilih metode pengambilan
        if (selectedItems.isNotEmpty) _buildPickupMethodDropdown(),
        ElevatedButton(
          onPressed: _simpanOrder,
          child: const Text("Simpan Order"),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodDropdown() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
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
            // Reset uangDiberikan saat metode pembayaran berubah
            uangDiberikan = null;
            kembalian = 0; // Reset kembalian
          });
        },
        hint: const Text("Pilih Metode Pembayaran"),
      ),
    );
  }

  Widget _buildWaktuPembayaranDropdown() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Waktu Pembayaran',
              border: OutlineInputBorder(),
            ),
            value: selectedWaktuPembayaran,
            items: waktuPembayaranOptions.map((option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Text(option),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedWaktuPembayaran = value;
                // Reset uangDiberikan dan kembalian saat waktu pembayaran berubah
                uangDiberikan = null;
                kembalian = 0;
                selectedPaymentMethod = null; // Reset metode pembayaran
              });
            },
            hint: const Text("Pilih Waktu Pembayaran"),
          ),
          if (selectedWaktuPembayaran == "Bayar Sekarang") ...[
            // Tampilkan dropdown metode pembayaran jika waktu pembayaran adalah "Bayar Sekarang"
            _buildPaymentMethodDropdown(),
            if (selectedPaymentMethod == "Tunai") ...[
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Nominal Uang Diberikan',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      uangDiberikan = int.tryParse(value) ?? 0;
                      kembalian = (uangDiberikan! - totalHarga)
                          .clamp(0, double.infinity)
                          .toInt();
                    });
                  },
                ),
              ),
              if (uangDiberikan != null) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    "Kembalian: ${formatCurrency(kembalian)}",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ],
          ],
          if (selectedWaktuPembayaran == "Bayar Nanti") ...[
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Nominal DP',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    dp = int.tryParse(value) ?? 0;
                    sisaPembayaran = (totalHarga - (dp ?? 0))
                        .clamp(0, double.infinity)
                        .toInt();
                  });
                },
              ),
            ),
            if (dp != null) ...[
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  "Sisa Pembayaran: ${formatCurrency(sisaPembayaran)}",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildPickupMethodDropdown() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'Pilih Metode Pengambilan',
          border: OutlineInputBorder(),
        ),
        value: selectedPickupMethod,
        items: pickupMethods.map((method) {
          return DropdownMenuItem<String>(
            value: method,
            child: Text(method),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            selectedPickupMethod = value;
          });
        },
        hint: const Text("Pilih Metode Pengambilan"),
      ),
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
          "price": item["price"], // Pastikan ini adalah number
          "quantity": 1,
          "kategori": item["kategori"], // Menyimpan kategori layanan
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
    if (selectedCustomer == null ||
        selectedItems.isEmpty ||
        selectedPickupMethod == null ||
        selectedWaktuPembayaran == null ||
        (selectedWaktuPembayaran == "Bayar Sekarang" &&
            selectedPaymentMethod == "Tunai" &&
            (uangDiberikan == null || uangDiberikan! < totalHarga))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                "Harap pilih pelanggan, layanan, metode pembayaran, waktu pembayaran, dan metode pengambilan, serta pastikan uang yang diberikan cukup")),
      );
      return;
    }

    FirebaseFirestore.instance.collection('orderan').add({
      "customer": {
        "name": selectedCustomer,
        "noHandphone": selectedCustomerPhone,
        "provinsi": selectedCustomerProvinsi,
        "kota": selectedCustomerKota,
        "kecamatan": selectedCustomerKecamatan,
        "kodePos": selectedCustomerKodePos,
        "rtRw": selectedCustomerRtRw,
        "noRumah": selectedCustomerNoRumah,
        "detailAlamat": selectedCustomerDetailAlamat,
        "alamatLengkap": selectedCustomerAlamatLengkap,
      },
      "items": selectedItems.map((item) {
        return {
          "name": item["name"],
          "price": item["price"],
          "quantity": item["quantity"],
          "kategori": item["kategori"],
        };
      }).toList(),
      "total_price": totalHarga,
      "metodePembayaran": selectedPaymentMethod,
      "waktuPembayaran": selectedWaktuPembayaran, // Store payment time
      "metodePengambilan": selectedPickupMethod,
      "uangDiberikan": selectedPaymentMethod == "Tunai" ? uangDiberikan : null,
      "kembalian": selectedPaymentMethod == "Tunai" ? kembalian : null,
      "dp": selectedWaktuPembayaran == "Bayar Nanti"
          ? dp
          : null, // Simpan DP jika bayar nanti
      "sisaPembayaran": selectedWaktuPembayaran == "Bayar Nanti"
          ? sisaPembayaran
          : null, // Simpan sisa pembayaran
      "timestamp": Timestamp.now(),
      "status": "Diproses",
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
      ScaffoldMessenger.of(context).showSnackBar(
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
                "kodePos": doc.data()["kodePos"] ?? "",
                "rtRw": doc.data()["rtRw"] ?? "",
                "noRumah": doc.data()["noRumah"] ?? "",
                "detailAlamat": doc.data()["detailAlamat"] ?? "",
                "alamatLengkap": doc.data()["alamatLengkap"] ?? "",
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
                          selectedCustomerPhone =
                              pelangganList[index]["noHandphone"];
                          selectedCustomerProvinsi =
                              pelangganList[index]["provinsi"];
                          selectedCustomerKota = pelangganList[index]["kota"];
                          selectedCustomerKecamatan =
                              pelangganList[index]["kecamatan"];
                          selectedCustomerKodePos =
                              pelangganList[index]["kodePos"];
                          selectedCustomerRtRw = pelangganList[index]["rtRw"];
                          selectedCustomerNoRumah =
                              pelangganList[index]["noRumah"];
                          selectedCustomerDetailAlamat =
                              pelangganList[index]["detailAlamat"];
                          selectedCustomerAlamatLengkap =
                              pelangganList[index]["alamatLengkap"];
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchField(),
            SizedBox(
              height: 300, // Beri tinggi tetap agar tidak bentrok dengan scroll
              child: _buildItemList('Layanan'),
            ),
            if (selectedCustomer == null && selectedItems.isNotEmpty)
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Pelanggan: $selectedCustomer",
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: _pilihPelanggan,
                    ),
                  ],
                ),
              ),
            if (selectedItems.isNotEmpty) _buildSelectedItems(),
          ],
        ),
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
        selectedLabelStyle: const TextStyle(fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        onTap: _onItemTapped,
      ),
    );
  }
}
