import 'package:flutter/material.dart';
import 'dashboard.dart';
import 'pelanggan.dart';
import 'buat_order.dart';
import 'data_order.dart';
import 'home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PengaturanPage extends StatefulWidget {
  const PengaturanPage({super.key});

  @override
  _PengaturanPageState createState() => _PengaturanPageState();
}

class _PengaturanPageState extends State<PengaturanPage> {
  int _selectedIndex = 4;
  String username = '';
  String role = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          username = userDoc['username'] ?? 'User';
          role = userDoc['role'] ?? 'Unknown';
        });
      }
    }
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    Widget nextPage;
    switch (index) {
      case 0:
        nextPage = const DashboardPage();
        break;
      case 1:
        nextPage = const PelangganPage();
        break;
      case 2:
        nextPage = const BuatOrderPage();
        break;
      case 3:
        nextPage = const DataOrderPage();
        break;
      case 4:
      default:
        nextPage = const PengaturanPage();
        break;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => nextPage),
    );
  }

  void _showDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Tutup"),
            ),
          ],
        );
      },
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Konfirmasi Logout"),
          content: const Text("Apakah Anda yakin ingin logout?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                  (Route<dynamic> route) => false,
                );
              },
              child: const Text(
                "Logout",
                style: TextStyle(color: Colors.red),
              ),
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
        title: const Text("Pengaturan", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage('assets/profile.png'),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    username,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    role,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Support & About",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildCard(
              icon: Icons.flag,
              text: "Tutorial Penggunaan Aplikasi",
              onTap: () {
                _showDialog(context, "Tutorial Penggunaan",
                    "1. Tambahkan layanan.\n2. Tambahkan pelanggan.\n3. Buat pesanan.\n4. Lihat daftar pesanan.");
              },
            ),
            _buildCard(
              icon: Icons.info,
              text: "Tentang Aplikasi",
              onTap: () {
                _showDialog(context, "Tentang Aplikasi",
                    "Avachive adalah aplikasi manajemen laundry.");
              },
            ),
            const SizedBox(height: 20),
            const Text(
              "Action",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildCard(
              icon: Icons.logout,
              text: "Log Out",
              textColor: Colors.red,
              onTap: () {
                _confirmLogout(context);
              },
            ),
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
        iconSize: 20, // Ukuran ikon yang lebih kecil
        selectedLabelStyle:
            TextStyle(fontSize: 12), // Ukuran label yang lebih kecil
        unselectedLabelStyle:
            TextStyle(fontSize: 12), // Ukuran label yang lebih kecil
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildCard(
      {required IconData icon,
      required String text,
      required VoidCallback onTap,
      Color textColor = Colors.black}) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(
          text,
          style: TextStyle(color: textColor),
        ),
        onTap: onTap,
      ),
    );
  }
}
