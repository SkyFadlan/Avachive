import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailAdminPelangganPage extends StatelessWidget {
  final String namaPelanggan;
  final String noHandphone;
  final String provinsi;
  final String kota;
  final String kecamatan;
  final String kodePos;
  final String noRumah;
  final String rtRw;
  final String detailAlamat;

  Future<void> _bukaGoogleMaps(BuildContext context) async {
    final alamatLengkap = '$detailAlamat, $kecamatan, $kota, $provinsi';

    try {
      List<Location> locations = await locationFromAddress(alamatLengkap);

      if (locations.isNotEmpty) {
        final location = locations.first;
        final googleMapsUrl =
            'https://www.google.com/maps/search/?api=1&query=${location.latitude},${location.longitude}';

        if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
          await launchUrl(Uri.parse(googleMapsUrl),
              mode: LaunchMode.externalApplication);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tidak dapat membuka Google Maps.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lokasi tidak ditemukan.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  const DetailAdminPelangganPage({
    Key? key,
    required this.namaPelanggan,
    required this.noHandphone,
    required this.provinsi,
    required this.kota,
    required this.kecamatan,
    required this.noRumah,
    required this.rtRw,
    required this.kodePos,
    required this.detailAlamat,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pelanggan'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Nama Pelanggan', namaPelanggan),
                _buildInfoRow('No Handphone', noHandphone),
                _buildInfoRow('Provinsi', provinsi),
                _buildInfoRow('Kota', kota),
                _buildInfoRow('Kecamatan', kecamatan),
                _buildInfoRow('Kode Pos', kodePos),
                _buildInfoRow('Detail Alamat', detailAlamat),
                _buildInfoRow('Alamat Lengkap',
                    '$detailAlamat, $kecamatan, $kota, $provinsi, $kodePos'),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () => _bukaGoogleMaps(context),
                    icon: const Icon(Icons.map),
                    label: const Text('Lihat di Google Maps'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start, // Supaya teks bisa turun ke bawah
        children: [
          SizedBox(
            width: 130, // Lebar tetap agar kolom kiri rata dan rapi
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}
