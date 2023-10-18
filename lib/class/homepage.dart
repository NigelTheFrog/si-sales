class HomePage {
  final int? jumlahKehadiran, jumlahKunjungan;
  String? tanggalKehadiran, tanggalKunjungan;
  // final List? kehadiran, transaksi, event, kunjungan, product;

  HomePage(
      {this.jumlahKehadiran,
      this.tanggalKehadiran,
      this.jumlahKunjungan,
      this.tanggalKunjungan});

  factory HomePage.fromJson(Map<String, dynamic> json) {
    return HomePage(
      jumlahKehadiran: json['jumlah_kehadiran'],
      tanggalKehadiran: json['tanggalKehadiran'],
      jumlahKunjungan: json['jumlahKunjungan'],
      tanggalKunjungan: json['tanggalKunjungan'],
    );
  }
}
