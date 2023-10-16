class Produk {
  final String jenis;
  final int id;
  final String? gambar;

  Produk({required this.id, required this.jenis, this.gambar});

  factory Produk.fromJson(Map<String, dynamic> json) {
    return Produk(
        id: json['id'] as int,
        jenis: json['jenis'] as String,
        gambar: json['gambar']);
  }
}
