class Cabang {
  final String id, nama_cabang, alamat, kodePos, idkota, kota;
  int? stock;

  Cabang(
      {required this.id,
      required this.nama_cabang,
      required this.alamat,
      required this.kodePos,
      required this.idkota,
      required this.kota, this.stock});

  factory Cabang.fromJson(Map<String, dynamic> json) {
    return Cabang(
      id: json['id'] as String,
      nama_cabang: json['nama_cabang'] as String,
      alamat: json['alamat'] as String,
      kodePos: json['kodepos'] as String,
      idkota: json['id_kota'] as String,
      kota: json['kota'] as String,
      stock: json['stock'] as int
    );
  }
}
