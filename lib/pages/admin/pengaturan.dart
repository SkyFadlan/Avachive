import 'package:flutter/material.dart';
import 'dashboard.dart'; // Ganti dengan import halaman Dashboard Admin yang sesuai
import 'kasir.dart'; // Ganti dengan import halaman Kasir yang sesuai
import 'layanan.dart'; // Ganti dengan import halaman Layanan yang sesuai
import 'laporan_bulanan.dart'; // Ganti dengan import halaman Laporan Bulanan yang sesuai
import '../home.dart'; // Ganti dengan import halaman Home yang sesuai
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PengaturanAdminPage extends StatefulWidget {
  const PengaturanAdminPage({super.key});

  @override
  _PengaturanAdminPageState createState() => _PengaturanAdminPageState();
}

class _PengaturanAdminPageState extends State<PengaturanAdminPage> {
  int _selectedIndex = 4; // Indeks untuk Pengaturan
  String username = '';
  String role = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser ;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          username = userDoc['username'] ?? 'User ';
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
        nextPage = const AdminDashboardPage();
        break;
      case 1:
        nextPage = const KasirPage();
        break;
      case 2:
        nextPage = const LayananPage();
        break;
      case 3:
        nextPage = const LaporanBulananPage();
        break;
      case 4:
      default:
        nextPage = const PengaturanAdminPage();
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
            icon: Icon(Icons.people,
                color: _selectedIndex == 1 ? Colors.blue : Colors.grey),
            label: 'Kasir',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_laundry_service,
                color: _selectedIndex == 2 ? Colors.blue : Colors.grey),
            label: 'Layanan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart,
                color: _selectedIndex == 3 ? Colors.blue : Colors.grey),
            label: 'Laporan Bulanan',
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