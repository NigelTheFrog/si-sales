class Kota {
  final String id, kota;
  final List? kecamatan;

  Kota({required this.id, required this.kota, this.kecamatan});

  factory Kota.fromJson(Map<String, dynamic> json) {
    return Kota(
      id: json['id'] as String,
      kota: json['kota'] as String,
      kecamatan: json['kecamatan'],
    );
  }
}
