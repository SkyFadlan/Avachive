import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PilihPelangganPage extends StatelessWidget {
  const PilihPelangganPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pilih Pelanggan")),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection('Pelanggan').get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var pelangganList = snapshot.data!.docs;

          return ListView.builder(
            itemCount: pelangganList.length,
            itemBuilder: (context, index) {
              var data = pelangganList[index].data() as Map<String, dynamic>;

              // Ambil nama pelanggan dari field "namaPelanggan"
              String namaPelanggan = data["namaPelanggan"] ?? "Tanpa Nama";

              return ListTile(
                title: Text(namaPelanggan),
                subtitle: Text(data["noHandphone"] ?? "No HP Tidak Ada"),
                onTap: () {
                  Navigator.pop(context, namaPelanggan);
                },
              );
            },
          );
        },
      ),
    );
  }
}
