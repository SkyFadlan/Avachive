import 'package:flutter/material.dart';

class DetailPelangganPage extends StatelessWidget {
  final String namaPelanggan;
  final String noHandphone;
  final String provinsi;
  final String kota;
  final String kecamatan;
  final String detailAlamat;

  const DetailPelangganPage({
    Key? key,
    required this.namaPelanggan,
    required this.noHandphone,
    required this.provinsi,
    required this.kota,
    required this.kecamatan,
    required this.detailAlamat,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pelanggan'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nama Pelanggan: $namaPelanggan', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('No Handphone: $noHandphone', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Provinsi: $provinsi', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Kota: $kota', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Kecamatan: $kecamatan', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Detail Alamat: $detailAlamat', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}