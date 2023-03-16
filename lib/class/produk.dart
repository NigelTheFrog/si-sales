class Produk {
  final String jenis;
  final int id;

  Produk({required this.id, required this.jenis});

  factory Produk.fromJson(Map<String, dynamic> json) {
    return Produk(
      id: json['id'] as int,
      jenis: json['jenis'] as String,
    );
  }
}
