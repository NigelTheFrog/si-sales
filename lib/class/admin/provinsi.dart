class Provinsi {
  final String id, provinsi;
  final List? kota;

  Provinsi({required this.id, required this.provinsi, this.kota});

  factory Provinsi.fromJson(Map<String, dynamic> json) {
    return Provinsi(
        id: json['id'] as String,
        provinsi: json['provinsi'] as String,
        kota: json['kota']);
  }
}
