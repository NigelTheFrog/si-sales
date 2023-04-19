class Kelurahan {
  final String id, kelurahan;
  final List? outlet;

  Kelurahan({required this.id, required this.kelurahan, this.outlet});

  factory Kelurahan.fromJson(Map<String, dynamic> json) {
    return Kelurahan(
      id: json['id'] as String,
      kelurahan: json['kelurahan'] as String,
      outlet: json['outlet'],
    );
  }
}
