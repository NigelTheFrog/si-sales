class Absen {
  final String id, tanggal, waktu, keterangan;
  final String? nama_depan, nama_belakang, username, id_lokasi, checkout;
  final int status;

  Absen({
    required this.id,
    required this.keterangan,
    required this.tanggal,
    required this.waktu,
    required this.status,
    this.id_lokasi,
    this.username,
    this.nama_depan,
    this.nama_belakang,
    this.checkout,
  });

  factory Absen.fromJson(Map<String, dynamic> json) {
    return Absen(
        id: json['id'] as String,
        tanggal: json['tanggal'] as String,
        keterangan: json['keterangan'] as String,
        waktu: json['waktu'] as String,
        id_lokasi: json['id_lokasi'] as String?,
        username: json['username'] as String?,
        nama_depan: json['nama_depan'] as String?,
        nama_belakang: json['nama_belakang'] as String?,
        status: json['status'] as int,
        checkout: json['checkout'] as String?);
  }
}
