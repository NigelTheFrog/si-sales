class Kunjungan {
  final String id, tanggal, waktu_in, id_outlet, nama_toko, deskripsi;
  final String? foto, waktu_out, id_nota, nama_depan, nama_belakang, username;
  final int status;

  Kunjungan(
      {required this.id,
      required this.tanggal,
      required this.waktu_in,
      required this.id_outlet,
      required this.nama_toko,
      required this.deskripsi,
      this.waktu_out,
      this.username,
      this.nama_depan,
      this.nama_belakang,
      this.id_nota,
      this.foto,
      required this.status});

  factory Kunjungan.fromJson(Map<String, dynamic> json) {
    return Kunjungan(
      id: json['id'] as String,
      tanggal: json['tanggal'] as String,
      waktu_in: json['waktu_in'] as String,
      deskripsi: json['deskripsi'] as String,
      waktu_out: json['waktu_out'] as String?,
      foto: json['bukti'] as String?,
      id_outlet: json['id_outlet'] as String,
      nama_toko: json['nama_toko'] as String,
      username: json['username'] as String?,
      nama_depan: json['nama_depan'] as String?,
      nama_belakang: json['nama_belakang'] as String?,
      id_nota: json['id_nota'] as String?,
      status: json['status'] as int,
    );
  }
}
