class Pembelian {
  final String id,
      tanggal,
      waktu,
      id_cabang,
      nama_cabang,
      foto,
      jumlah_barang,
      
      username,
      nama_depan,
      nama_belakang;
  final int total_pembelian;

  Pembelian({
    required this.id,
    required this.tanggal,
    required this.waktu,
    required this.jumlah_barang,
    required this.total_pembelian,
    required this.foto,
    required this.id_cabang,
    required this.nama_cabang,
    required this.username,
    required this.nama_depan,
    required this.nama_belakang,
  });

  factory Pembelian.fromJson(Map<String, dynamic> json) {
    return Pembelian(
      id: json['id'] as String,
      tanggal: json['tanggal'] as String,
      waktu: json['waktu'] as String,
      jumlah_barang: json['jumlah_barang'] as String,
      total_pembelian: int.parse(json['total_pembelian']),
      foto: json['foto'] as String,
      id_cabang: json['id_cabang'] as String,
      nama_cabang: json['nama_cabang'] as String,
      username: json['username'] as String,
      nama_depan: json['nama_depan'] as String,
      nama_belakang: json['nama_belakang'] as String,
    );
  }
}
