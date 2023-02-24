class Grup {
  final String id, nama_depan, nama_belakang, nama_grup, id_cabang, nama_cabang;
  final int jumlah_pegawai;

  Grup({
    required this.id,
    required this.nama_grup,
    required this.nama_depan,
    required this.nama_belakang,
    required this.jumlah_pegawai,
    required this.id_cabang,
    required this.nama_cabang,
  });

  factory Grup.fromJson(Map<String, dynamic> json) {
    return Grup(
      id: json['id_grup'] as String,
      nama_grup: json['nama_grup'] as String,
      nama_depan: json['nama_depan'] as String,
      nama_belakang: json['nama_belakang'] as String,
      jumlah_pegawai: json['jumlah_pegawai'] as int,
      id_cabang: json['id_cabang'] as String,
      nama_cabang: json['nama_cabang'] as String,
    );
  }
}
