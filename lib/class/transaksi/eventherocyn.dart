class EventHerocyn {
  final String id, nama, pengajuan, tanggal;
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
      // username,
      penanggung_jawab,
      // nama_belakang,
      alamat;
  final int? status;
  final List? persetujuan;

  EventHerocyn(
      {required this.id,
      required this.tanggal,
      required this.nama,
      required this.pengajuan,
      this.alamat,
      // this.username,
      this.penanggung_jawab,
      // this.nama_belakang,
      // required this.jumlah_kebutuhan,
      // required this.total_pengeluaran,
      this.tujuan,
      this.latar_belakang,
      this.strategi,
      this.status,
      // this.jumlah_penjualan,
      // this.total_penjualan,
      this.persetujuan,
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
        pengajuan: json['tanggal_pengajuan'] as String,
        nama: json['nama'] as String,
        alamat: json['alamat'] as String?,
        tujuan: json['tujuan'] as String?,
        latar_belakang: json['latar_belakang'] as String?,
        strategi: json['strategi'] as String?,
        // username: json['username'] as String?,
        penanggung_jawab: json['penanggung_jawab'] as String?,
        status: json['status'] as int?,
        //nama_belakang: json['nama_belakang'] as String?,
        persetujuan: json['persetujuan'],
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
