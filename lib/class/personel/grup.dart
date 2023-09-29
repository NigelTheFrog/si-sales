class Grup {
  final String id, nama_grup, id_cabang, nama_cabang, kota, provinsi, area;
  final int jumlah_pegawai;
  final String? tl, spv, am;

  Grup(
      {required this.id,
      required this.nama_grup,
      required this.jumlah_pegawai,
      required this.id_cabang,
      required this.nama_cabang,
      required this.kota,
      required this.provinsi,
      required this.area,
      this.tl,
      this.am,
      this.spv});

  factory Grup.fromJson(Map<String, dynamic> json) {
    return Grup(
      id: json['id'] as String,
      nama_grup: json['nama_grup'] as String,
      jumlah_pegawai: json['jumlah_pegawai'] as int,
      id_cabang: json['id_cabang'] as String,
      nama_cabang: json['nama_cabang'] as String,
      kota: json['kota'] as String,
      provinsi: json['provinsi'] as String,
      area: json['area'] as String,
      tl: json['TL'] as String?,
      spv: json['SPV'] as String?,
      am: json['AM'] as String?,
    );
  }
}
