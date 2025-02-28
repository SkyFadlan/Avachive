import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'pages/login.dart'; // Pastikan import ini ada
import 'pages/dashboard.dart'; // Halaman Dashboard untuk Kasir
import 'pages/admin/dashboard.dart'; // Halaman Dashboard untuk Admin
import 'pages/home.dart';

void main() async {
  // Pastikan widget binding sudah diinisialisasi
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inisialisasi Firebase
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Avacive Laundry',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: AuthChecker(), // Arahkan ke halaman AuthChecker
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthChecker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator()); // Loading
        }

        if (snapshot.hasData) {
          // Jika sudah login, periksa peran pengguna
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('Users').doc(snapshot.data!.uid).get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator()); // Loading
              }

              if (userSnapshot.hasData && userSnapshot.data!.exists) {
                String role = userSnapshot.data!['role'];
                if (role == 'admin') {
                  return const AdminDashboardPage(); // Halaman Dashboard Admin
                } else if (role == 'kasir') {
                  return const DashboardPage(); // Halaman Dashboard Kasir
                }
              }

              return const HomePage(); // Jika peran tidak dikenali, kembali ke halaman login
            },
          );
        }

        return const HomePage(); // Jika belum login, ke halaman login
      },
    );
  }
}