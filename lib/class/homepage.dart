class HomePage {
  final int? jumlahKehadiran, jumlahKunjungan;
  final String? tanggalKehadiran, tanggalKunjungan;
  // final List? kehadiran, transaksi, event, kunjungan, product;

  HomePage(
      {this.jumlahKehadiran,
      this.tanggalKehadiran,
      this.jumlahKunjungan,
      this.tanggalKunjungan});

  factory HomePage.fromJson(Map<String, dynamic> json) {
    return HomePage(
      jumlahKehadiran: json['jumlah_kehadiran'],
      tanggalKehadiran: json['tanggal_kehadiran'],
      jumlahKunjungan: json['jumlah'],
      tanggalKunjungan: json['tanggal'],
    );
  }
}
