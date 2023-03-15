class Penjualan {
  final String id,
      tanggal,
      waktu,
      id_outlet,
      nama_toko,
      jumlah_barang,
      username,
      nama_depan,
      nama_belakang;
  final String? foto;
  final int total_penjualan, diskon, ppn;
  final List? produk;

  Penjualan(
      {required this.id,
      required this.tanggal,
      required this.waktu,
      required this.jumlah_barang,
      required this.total_penjualan,
      required this.id_outlet,
      required this.nama_toko,
      required this.username,
      required this.nama_depan,
      required this.nama_belakang,
      this.foto,
      this.produk,
      required this.ppn,
      required this.diskon});

  factory Penjualan.fromJson(Map<String, dynamic> json) {
    return Penjualan(
        id: json['id'] as String,
        tanggal: json['tanggal'] as String,
        waktu: json['waktu'] as String,
        jumlah_barang: json['jumlah_barang'] as String,
        total_penjualan: int.parse(json['total_penjualan']),
        foto: json['foto'] as String?,
        id_outlet: json['id_outlet'] as String,
        nama_toko: json['nama_toko'] as String,
        username: json['username'] as String,
        nama_depan: json['nama_depan'] as String,
        nama_belakang: json['nama_belakang'] as String,
        ppn: json['ppn'] as int,
        diskon: json['diskon'] as int,
        produk: json['produk']);
  }
}
