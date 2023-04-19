class Jabatan {
  final String jabatan, keterangan;
  final int id;

  Jabatan({required this.id, required this.jabatan, required this.keterangan});

  factory Jabatan.fromJson(Map<String, dynamic> json) {
    return Jabatan(
      id: json['id'] as int,
      jabatan: json['jabatan'] as String,
      keterangan: json['keterangan'] as String,
    );
  }
}
