class Pembelian {
  final String id,
      tanggal,
      waktu,
      id_cabang,
      nama_cabang,
      foto,
      jumlah_barang,
      total_pembelian;
  // final int ;

  Pembelian({
    required this.id,
    required this.tanggal,
    required this.waktu,
    required this.jumlah_barang,
    required this.total_pembelian,
    required this.foto,
    required this.id_cabang,
    required this.nama_cabang,
  });

  factory Pembelian.fromJson(Map<String, dynamic> json) {
    return Pembelian(
      id: json['id'] as String,
      tanggal: json['tanggal'] as String,
      waktu: json['waktu'] as String,
      jumlah_barang: json['jumlah_barang'] as String,
      total_pembelian: json['total_pembelian'] as String,
      foto: json['foto'] as String,
      id_cabang: json['id_cabang'] as String,
      nama_cabang: json['nama_cabang'] as String,
    );
  }
}
