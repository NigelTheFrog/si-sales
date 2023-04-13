// class Event {
//   final String id,
//       nama,
//       lokasi,
//       tanggal,
//       tujuan,
//       username,
//       nama_depan,
//       nama_belakang;
//   final int jumlah_kebutuhan, total_pengeluaran;
//   final String? proposal, laporan;
//   final int? jumlah_penjualan, total_penjualan, status_proposal;
//   final List? produk;
//   final List? kebutuhan;
class EventHerocyn {
  final String id, nama, lokasi, tanggal, username, nama_depan, nama_belakang;
  final List? produk;
  final String? tujuan, laporan, proposal;
  final int? status_proposal, status_laporan;
  final List? kebutuhan;

  EventHerocyn({
    required this.id,
    required this.tanggal,
    required this.nama,
    required this.lokasi,
    required this.username,
    required this.nama_depan,
    required this.nama_belakang,
    // required this.jumlah_kebutuhan,
    // required this.total_pengeluaran,
    this.tujuan,
    this.proposal,
    this.laporan,
    // this.jumlah_penjualan,
    // this.total_penjualan,
    this.status_proposal,
    this.status_laporan,
    this.kebutuhan,
    this.produk,
  });

  factory EventHerocyn.fromJson(Map<String, dynamic> json) {
    return EventHerocyn(
        id: json['id'] as String,
        tanggal: json['tanggal'] as String,
        nama: json['nama'] as String,
        lokasi: json['lokasi'] as String,
        tujuan: json['tujuan'] as String?,
        username: json['username'] as String,
        nama_depan: json['nama_depan'] as String,
        nama_belakang: json['nama_belakang'] as String,
        // jumlah_kebutuhan: int.parse(json['jumlah_kebutuhan']),
        // total_pengeluaran: int.parse(json['total_pengeluaran']),
        proposal: json['proposal'] as String?,
        laporan: json['laporan'] as String?,
        // jumlah_penjualan: int.parse( json['jumlah_penjualan']),
        // total_penjualan: int.parse(json['total_penjualan']),
        status_proposal: json['status_proposal'] as int?,
        status_laporan: json['status_laporan'] as int?,
        kebutuhan: json['kebutuhan'],
        produk: json['produk']);
  }
}
