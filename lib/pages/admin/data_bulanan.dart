import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'detail_admin_order.dart'; // Impor halaman DetailAdminOrderPage

class DataBulanPage extends StatelessWidget {
  final int bulan;
  final int tahun;

  const DataBulanPage({super.key, required this.bulan, required this.tahun});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Orderan Bulan $bulan-$tahun'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('orderan').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;

          final filtered = docs.where((doc) {
            final ts = doc['timestamp'] as Timestamp?;
            if (ts == null) return false;
            final date = ts.toDate();
            return date.month == bulan && date.year == tahun;
          }).toList();

          // Hitung total omzet
          final totalOmzet = filtered.fold<int>(0, (sum, doc) {
            final items = List.from(doc['items']);
            final hargaOrder = items.fold<int>(
              0,
              (sumItems, item) => sumItems + ((item['price'] as num).toInt() * (item['quantity'] as num).toInt()),
            );
            return sum + hargaOrder;
          });

          // Group orderan berdasarkan tanggal (yyyy-MM-dd)
          final Map<String, List<Map<String, dynamic>>> grouped = {};

          for (var doc in filtered) {
            final date = (doc['timestamp'] as Timestamp).toDate();
            final dateKey = DateFormat('yyyy-MM-dd').format(date);
            final customerName = doc['customer']['name'] ?? 'Tidak Diketahui';
            final items = List.from(doc['items']);
            final totalPrice = items.fold<int>(
              0,
              (sum, item) => sum + ((item['price'] as num).toInt() * (item['quantity'] as num).toInt()),
            );

            grouped.putIfAbsent(dateKey, () => []);
            grouped[dateKey]!.add({
              'id': doc.id, // Simpan ID order untuk navigasi
              'nama': customerName,
              'tanggal': DateFormat('dd-MM-yyyy').format(date),
              'harga': totalPrice,
              'status': doc['status'] ?? 'Selesai',
            });
          }

          // Generate semua tanggal dalam bulan itu
          final daysInMonth = DateUtils.getDaysInMonth(tahun, bulan);
          final List<DateTime> semuaTanggal = List.generate(daysInMonth, (index) {
            return DateTime(tahun, bulan, index + 1);
          });

          return ListView(
            padding: EdgeInsets.all(16),
            children: [
              // Header Bulan
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('MMMM', 'id_ID').format(DateTime(tahun, bulan)),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Jumlah Order: ${filtered.length}",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Total Omzet: Rp ${NumberFormat('#,###', 'id_ID').format(totalOmzet)}",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Tanggal 1 - 31
              ...semuaTanggal.map((tanggal) {
                final dateKey = DateFormat('yyyy-MM-dd').format (tanggal);
                final orders = grouped[dateKey] ?? [];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(tanggal),
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    if (orders.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, bottom: 16),
                        child: Text("Tidak ada orderan", style: TextStyle(color: Colors.grey)),
                      )
                    else
                      ...orders.asMap().entries.map((entry) {
                        final i = entry.key;
                        final order = entry.value;
                        return GestureDetector(
                          onTap: () {
                            // Navigasi ke halaman DetailAdminOrderPage
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailAdminOrderPage(orderId: order['id']),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("${i + 1}. "),
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 3,
                                          offset: Offset(0, 2),
                                        )
                                      ],
                                    ),
                                    padding: EdgeInsets.all(12),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 20,
                                          backgroundColor: Colors.grey.shade300,
                                          child: Icon(Icons.person),
                                        ),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(order["nama"], style: TextStyle(fontWeight: FontWeight.bold)),
                                              SizedBox(height: 4),
                                              Text(order["tanggal"]),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              "Rp ${NumberFormat('#,###', 'id_ID').format(order["harga"])}",
                                              style: TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              order["status"],
                                              style: TextStyle(color: Colors.green),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      }),
                    SizedBox(height: 16),
                  ],
                );
              }),
            ],
          );
        },
      ),
    );
  }
}