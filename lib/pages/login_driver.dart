import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';
import 'driver/dashboard.dart';

class LoginDriverPage extends StatefulWidget {
  const LoginDriverPage({super.key});

  @override
  State<LoginDriverPage> createState() => _LoginDriverPageState();
}

class _LoginDriverPageState extends State<LoginDriverPage> {
  final TextEditingController _idController = TextEditingController();
  bool _isLoading = false;

  // Generate email dari ID (contoh: 001@avachive.id)
  String _generateEmail(String id) => '$id@avachive.id';

  // Password default
  final String _defaultPassword = '123456';

  Future<void> _login() async {
    setState(() => _isLoading = true);

    try {
      // 1. Cek apakah ID ada di Firestore
      final QuerySnapshot userQuery = await FirebaseFirestore.instance
          .collection('Users')
          .where('id_karyawan', isEqualTo: _idController.text.trim())
          .get();

      if (userQuery.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ID Driver tidak ditemukan!')),
        );
        setState(() => _isLoading = false);
        return;
      }

      // 2. Cek role dari dokumen user
      final userData = userQuery.docs.first.data() as Map<String, dynamic>;
      if (userData['role'] != 'driver') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Akses hanya untuk driver.')),
        );
        setState(() => _isLoading = false);
        return;
      }

      // 3. Login dengan email generated + password default
      final String email = _generateEmail(_idController.text.trim());

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: _defaultPassword,
      );

      // 4. Simpan session dan navigasi ke dashboard
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', userCredential.user!.uid);
      await prefs.setString('user_role', 'driver');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardDriverPage()),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login gagal: ${e.message}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Login'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Center(
                  child: const Text(
                    'Login sebagai Driver',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _idController,
                  decoration: InputDecoration(
                    labelText: 'ID Driver',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          minimumSize: const Size(double.infinity, 45),
                        ),
                        child: const Text('Masuk',
                            style: TextStyle(color: Colors.white)),
                      ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.blue),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text(
                    'Kembali',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}