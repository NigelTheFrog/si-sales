class Penjualan {
  final String id,
      tanggal,
      waktu,
      id_cabang,
      nama_cabang,
      nama_depan,
      nama_belakang;
  final int jumlah_barang, total_penjualan, laba;

  Penjualan({
    required this.id,
    required this.tanggal,
    required this.waktu,
    required this.jumlah_barang,
    required this.total_penjualan,
    required this.laba,
    required this.id_cabang,
    required this.nama_cabang,
    required this.nama_depan,
    required this.nama_belakang,
  });

  factory Penjualan.fromJson(Map<String, dynamic> json) {
    return Penjualan(
      id: json['id'] as String,
      tanggal: json['tanggal'] as String,
      waktu: json['waktu'] as String,
      jumlah_barang: json['jumlah_barang'] as int,
      total_penjualan: json['total_penjualan'] as int,
      laba: json['laba'] as int,
      id_cabang: json['id_cabang'] as String,
      nama_cabang: json['nama_cabang'] as String,
      nama_depan: json['nama_depan'] as String,
      nama_belakang: json['nama_belakang'] as String,
    );
  }
}
