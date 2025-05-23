import 'package:flutter/material.dart';
import 'login_kasir.dart'; // Import halaman login kasir
import 'login_admin.dart'; // Import halaman login admin
import 'login_driver.dart'; // Import halaman login driver

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60), // Tinggi AppBar
        child: AppBar(
          backgroundColor: Colors.lightBlue,
          automaticallyImplyLeading: false, // Warna biru sesuai gambar
          elevation: 0,
          title: Row(
            children: [
              Image.asset(
                'assets/logo.png', // Ganti dengan logo yang sesuai
                height: 30,
              ),
              const SizedBox(width: 8),
              const Text(
                'Avachive',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Selamat Datang Di Avachive\nSiap Kelola Bisnis Laundry Anda',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginKasirPage(), // Navigasi ke halaman login kasir
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    minimumSize: const Size(double.infinity, 45),
                  ),
                  child: const Text('Login sebagai Kasir', style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginAdminPage(), // Navigasi ke halaman login admin
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    minimumSize: const Size(double.infinity, 45),
                  ),
                  child: const Text('Login sebagai Admin', style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginDriverPage(), // Navigasi ke halaman login driver
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    minimumSize: const Size(double.infinity, 45),
                  ),
                  child: const Text('Login sebagai Driver', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}