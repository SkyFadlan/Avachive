import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Pages
import 'dashboard.dart';
import 'karyawan.dart';
import 'layanan.dart';
import 'pelanggan.dart';
import 'edit_admin.dart';
import '../home.dart';
import 'edit_profile_admin.dart';
import 'laporan_bulanan.dart';

class PengaturanAdminPage extends StatefulWidget {
  const PengaturanAdminPage({super.key});

  @override
  State<PengaturanAdminPage> createState() => _PengaturanAdminPageState();
}

class _PengaturanAdminPageState extends State<PengaturanAdminPage> {
  int _selectedIndex = 5;
  String username = '';
  String role = '';

  @override
  void initState() {
    super.initState();
    _loadAdminData();
  }

  Future<void> _loadAdminData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('role', isEqualTo: 'admin')
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final adminDoc = querySnapshot.docs.first;
        if (mounted) {
          setState(() {
            username = adminDoc.data()['username'] ?? 'Admin';
            role = adminDoc.data()['role'] ?? 'Admin';
          });
        }
      }
    }
  }

  void _onItemTapped(int index) {
  if (index == _selectedIndex) return;

  setState(() {
    _selectedIndex = index; // Update the selected index
  });

  final pages = [
    const AdminDashboardPage(),
    const KasirPage(),
    const LayananPage(),
    const AdminPelangganPage(),
    const LaporanBulananPage(), // This should be the Data page
    const PengaturanAdminPage(),
  ];

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => pages[index]),
  );
}

  void _showDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Tutup"),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Konfirmasi Logout"),
        content: const Text("Apakah Anda yakin ingin logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const HomePage()),
                (route) => false,
              );
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pengaturan", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Profil',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfilAdminPage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage('assets/profile.png'),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    username,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(role, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text("Support & About",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildCard(
              icon: Icons.flag,
              text: "Tutorial Penggunaan Aplikasi",
              onTap: () => _showDialog(context, "Tutorial Penggunaan", """
1. Tambahkan layanan.
2. Tambahkan pelanggan.
3. Buat pesanan.
4. Lihat daftar pesanan.
"""),
            ),
            _buildCard(
              icon: Icons.info,
              text: "Tentang Aplikasi",
              onTap: () => _showDialog(
                context,
                "Tentang Aplikasi",
                "Avachive adalah aplikasi manajemen laundry.",
              ),
            ),
            const SizedBox(height: 20),
            const Text("Action", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildCard(
              icon: Icons.edit,
              text: "Ubah Password",
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GantiPasswordAdminPage(),
                    ));
              },
            ),
            _buildCard(
              icon: Icons.logout,
              text: "Log Out",
              textColor: Colors.red,
              onTap: () => _confirmLogout(context),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        iconSize: 20,
        selectedLabelStyle: const TextStyle(fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Karyawan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_laundry_service),
            label: 'Layanan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Pelanggan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Data',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Pengaturan',
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    Color textColor = Colors.black,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(text, style: TextStyle(color: textColor)),
        onTap: onTap,
      ),
    );
  }
}
