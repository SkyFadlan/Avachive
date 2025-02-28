class Order {
  final String id;
  final DateTime date; // Tanggal order selesai
  final double totalPrice; // Harga total order
  final bool isCompleted; // Status order, apakah sudah diambil

  Order({
    required this.id,
    required this.date,
    required this.totalPrice,
    required this.isCompleted,
  });

  // Contoh data untuk simulasi
  static List<Order> getOrders() {
    return [
      Order(id: '1', date: DateTime.now(), totalPrice: 20000, isCompleted: true),
      Order(id: '2', date: DateTime.now(), totalPrice: 25000, isCompleted: true),
      Order(id: '3', date: DateTime.now().subtract(const Duration(days: 1)), totalPrice: 30000, isCompleted: true),
      Order(id: '4', date: DateTime.now(), totalPrice: 15000, isCompleted: false), // Masih dalam proses
    ];
  }
}
