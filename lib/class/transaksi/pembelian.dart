class Pembelian {
  final String id,
      tanggal,
      waktu,
      id_cabang,
      nama_cabang,
      foto,
      jumlah_barang,
      username,
      nama_depan,
      nama_belakang,
      id_supplier,
      nama_supplier;
  final int total_pembelian, diskon, ppn;
  final List? produk;

  Pembelian(
      {required this.id,
      required this.tanggal,
      required this.waktu,
      required this.id_cabang,
      required this.nama_cabang,
      required this.foto,
      required this.jumlah_barang,
      required this.username,
      required this.nama_depan,
      required this.nama_belakang,
      required this.id_supplier,
      required this.nama_supplier,
      required this.total_pembelian,
      required this.diskon,
      required this.ppn,
      this.produk});

  factory Pembelian.fromJson(Map<String, dynamic> json) {
    return Pembelian(
        id: json['id'] as String,
        tanggal: json['tanggal'] as String,
        waktu: json['waktu'] as String,
        id_cabang: json['id_cabang'] as String,
        nama_cabang: json['nama_cabang'] as String,
        foto: json['foto'] as String,
        jumlah_barang: json['jumlah_barang'] as String,
        username: json['username'] as String,
        nama_depan: json['nama_depan'] as String,
        nama_belakang: json['nama_belakang'] as String,
        id_supplier: json['id_supplier'] as String,
        nama_supplier: json['nama_supplier'] as String,
        total_pembelian: int.parse(json['total_pembelian']),
        ppn: json['ppn'] as int,
        diskon: json['diskon'] as int,
        produk: json['produk']);
  }
}
