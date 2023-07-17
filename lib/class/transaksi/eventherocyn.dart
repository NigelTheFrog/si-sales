class EventHerocyn {
  final String id, nama, tanggal;
  final List? produk,
      kebutuhan,
      personil,
      lokasi,
      target,
      gimmick,
      pengguna_baru,
      pengguna_lama;
  final String? tujuan,
      latar_belakang,
      strategi,
      username,
      nama_depan,
      nama_belakang,
      alamat;
  final int? status_proposal, status_laporan;

  EventHerocyn(
      {required this.id,
      required this.tanggal,
      required this.nama,
      this.alamat,
      this.username,
      this.nama_depan,
      this.nama_belakang,
      // required this.jumlah_kebutuhan,
      // required this.total_pengeluaran,
      this.tujuan,
      this.latar_belakang,
      this.strategi,

      // this.jumlah_penjualan,
      // this.total_penjualan,
      this.status_proposal,
      this.status_laporan,
      this.kebutuhan,
      this.personil,
      this.pengguna_baru,
      this.pengguna_lama,
      this.produk,
      this.target,
      this.gimmick,
      this.lokasi});

  factory EventHerocyn.fromJson(Map<String, dynamic> json) {
    return EventHerocyn(
        id: json['id'] as String,
        tanggal: json['tanggal'] as String,
        nama: json['nama'] as String,
        alamat: json['alamat'] as String?,
        tujuan: json['tujuan'] as String?,
        latar_belakang: json['latar_belakang'] as String?,
        strategi: json['strategi'] as String?,
        username: json['username'] as String?,
        nama_depan: json['nama_depan'] as String?,
        nama_belakang: json['nama_belakang'] as String?,
        status_proposal: json['status_proposal'] as int?,
        status_laporan: json['status_laporan'] as int?,
        kebutuhan: json['kebutuhan'],
        personil: json['personil'],
        lokasi: json['lokasi'],
        target: json['target'],
        gimmick: json['gimmick'],
        pengguna_baru: json['pengguna_baru'],
        pengguna_lama: json['pengguna_lama'],
        produk: json['produk']);
  }
}
