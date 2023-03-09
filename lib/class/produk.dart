class Produk {
  final String jenis;
  final int id, harga;

  Produk({required this.id, required this.harga, required this.jenis});

  factory Produk.fromJson(Map<String, dynamic> json) {
    return Produk(
      id: json['id'] as int,
      harga: json['harga'] as int,
      jenis: json['jenis'] as String,
    );
  }
}
