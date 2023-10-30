class Person {
  final String username,
      nama_depan,
      nama_belakang,
      email,
      avatar,
      no_telp,
      tanggal_gabung,
      jabatan,
      id_grup,
      nama_grup,
      id_cabang,
      nama_cabang;
  int id_jabatan, gender;

  Person({
    required this.username,
    required this.nama_depan,
    required this.nama_belakang,
    required this.email,
    required this.avatar,
    required this.gender,
    required this.no_telp,
    required this.tanggal_gabung,
    required this.id_jabatan,
    required this.jabatan,
    required this.id_grup,
    required this.nama_grup,
    required this.id_cabang,
    required this.nama_cabang,
  });

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      username: json['username'] as String,
      nama_depan: json['nama_depan'] as String,
      nama_belakang: json['nama_belakang'] as String,
      email: json['email'] as String,
      avatar: json['avatar'] as String,
      gender: json['gender'] as int,
      no_telp: json['no_telp'] as String,
      tanggal_gabung: json['tanggal_gabung'] as String,
      id_jabatan: json['id_jabatan'] as int,
      jabatan: json['jabatan'] as String,
      id_grup: json['id_grup'] as String,
      nama_grup: json['nama_grup'] as String,
      id_cabang: json['id_cabang'] as String,
      nama_cabang: json['nama_cabang'] as String,
    );
  }
}
