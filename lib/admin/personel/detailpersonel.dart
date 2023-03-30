import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:pt_coronet_crown/admin/personel/personeldata.dart';
import 'package:pt_coronet_crown/class/cabang.dart';
import 'package:pt_coronet_crown/class/jabatan.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:pt_coronet_crown/drawer.dart';

class DetailPersonel extends StatefulWidget {
  String username,
      avatar,
      namaDepan,
      namaBelakang,
      email,
      nomorTelepon,
      namaCabang,
      namaJabatan;
  DetailPersonel({
    super.key,
    required this.username,
    required this.avatar,
    required this.namaDepan,
    required this.namaBelakang,
    required this.email,
    required this.nomorTelepon,
    required this.namaCabang,
    required this.namaJabatan,
  });
  @override
  _DetailPersonelState createState() {
    return _DetailPersonelState();
  }
}

const List<String> genderList = <String>['Pria', 'Wanita'];

class _DetailPersonelState extends State<DetailPersonel> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController namaDepanController = TextEditingController();
  TextEditingController namaBelakangController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController nomorTeleponController = TextEditingController();
  TextEditingController namaCabangController = TextEditingController();
  TextEditingController namaJabatanController = TextEditingController();

  late Timer timer;
  String cabang = "",
      gender = genderList.first.toString(),
      controllerCabang = "",
      controllerJabatan = "",
      _jabatan = "";
  var _avatar = null;
  var _avatar_proses = null;

  final picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

  Future<List> daftarCabang() async {
    Map json;
    final response = await http.post(
      Uri.parse("http://localhost/magang/admin/cabang/daftarcabang.php"),
    );

    if (response.statusCode == 200) {
      json = jsonDecode(response.body);
      return json['data'];
    } else {
      throw Exception('Failed to read API');
    }
  }

  Future<List> daftarJabatan() async {
    Map json;
    final response = await http.post(
      Uri.parse("http://localhost/magang/admin/jabatan/daftarjabatan.php"),
    );

    if (response.statusCode == 200) {
      json = jsonDecode(response.body);
      return json['data'];
    } else {
      throw Exception('Failed to read API');
    }
  }

  void warningDialog(context, warning_message) {
    showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Text('Peringatan'),
              content: Text(warning_message),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context, 'OK'),
                  child: const Text('OK'),
                ),
              ],
            ));
  }

  void submit(BuildContext context) async {
    if (_avatar_proses == null) return;
    String base64Image = base64Encode(_avatar_proses);
    final response = await http.post(
        Uri.parse("http://localhost/magang/account/createaccount.php"),
        body: {
          'username': widget.username,
          'namaDepan': namaDepanController.text,
          'namaBelakang': namaBelakangController.text,
          'email': emailController.text,
          'avatar': base64Image,
          'gender': gender,
          'no_telp': nomorTeleponController.text,
          'jabatan': _jabatan,
          'cabang': cabang,
          'grup': '-'
        });
    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      if (json['result'] == 'success') {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Sukses Menambah Data')));
        dispose();
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => PersonelData()));
      } else if (json['Error'] ==
          "Got a packet bigger than 'max_allowed_packet' bytes") {
        setState(() {
          warningDialog(context, "Ukuran gambar terlalu besar");
        });
      }
    } else {
      throw Exception('Failed to read API');
    }
  }

  Widget comboCabang = Text("");
  Widget comboJabatan = Text("");

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    usernameController.text = widget.username;
    namaDepanController.text = widget.namaDepan;
    namaBelakangController.text = widget.namaBelakang;
    emailController.text = widget.email;
    nomorTeleponController.text = widget.nomorTelepon;
    namaCabangController.text = widget.namaCabang;
    namaJabatanController.text = widget.namaJabatan;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    timer.cancel();
    super.dispose();
  }

  void generatDaftarCabang() {
    List<Cabang> cabangs;
    var data = daftarCabang();
    data.then((value) {
      cabangs = List<Cabang>.from(value.map((i) {
        return Cabang.fromJson(i);
      }));
      setState(() {
        comboCabang = DropdownButtonHideUnderline(
            child: DropdownButton(
                hint: controllerCabang == ""
                    ? Text("Daftar Cabang")
                    : Text(
                        controllerCabang,
                        style: TextStyle(color: Colors.black),
                      ),
                isDense: false,
                items: cabangs.map((cabang) {
                  return DropdownMenuItem(
                    child: Text(cabang.nama_cabang),
                    value: [cabang.id, cabang.nama_cabang],
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    cabang = value![0];
                    controllerCabang = value[1].toString();
                  });
                }));
      });
    });
  }

  void generatDaftarJabatan() {
    List<Jabatan> jabatans;
    var data = daftarJabatan();
    data.then((value) {
      jabatans = List<Jabatan>.from(value.map((i) {
        return Jabatan.fromJson(i);
      }));
      setState(() {
        comboJabatan = DropdownButtonHideUnderline(
            child: DropdownButton(
                hint: controllerJabatan == ""
                    ? Text("Daftar Jabatan")
                    : Text(
                        controllerJabatan,
                        style: TextStyle(color: Colors.black),
                      ),
                isDense: false,
                items: jabatans.map((jabatan) {
                  return DropdownMenuItem(
                    child: Text(jabatan.jabatan),
                    value: [jabatan.id, jabatan.jabatan],
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _jabatan = value![0].toString();
                    controllerJabatan = value[1].toString();
                  });
                }));
      });
    });
  }

  void prosesFoto() {
    Future<Directory?> extDir = getTemporaryDirectory();
    extDir.then((value) {
      String _timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String filePath = '${value?.path}/$_timestamp.jpg';
      _avatar_proses = File(filePath);
      img.Image? temp = img.readJpg(_avatar!.readAsBytesSync());
      img.Image temp2 = img.copyResize(temp!, width: 480, height: 640);
      setState(() {
        _avatar_proses = Uint8List.fromList(img.encodeJpg(temp2));
      });
    });
  }

  Future chooseImg() async {
    FilePickerResult fileResult =
        await FilePicker.platform.pickFiles() as FilePickerResult;
    if (fileResult != null) {
      setState(() {
        _avatar = fileResult.files.first.bytes;
        img.Image? temp = img.decodeImage(_avatar!);
        img.Image temp2 = img.copyResize(temp!, width: 480, height: 640);
        _avatar_proses = Uint8List.fromList(img.encodeJpg(temp2));
      });
    }
  }

  Future captureImg() async {
    var picked_img =
        await picker.pickImage(source: ImageSource.camera, imageQuality: 20);
    // setState(() {
    _avatar = File(picked_img!.path);
    prosesFoto();

    //});
  }

  // void editDialog(BuildContext context, int change) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       if (change == 1) {
  //         return AlertDialog(
  //           title: Text("Edit Nama Depan"),
  //           content: TextFormField(
  //               "Edit Nama Dep"),
  //           actions: [
  //             TextButton(
  //               child: Text("Cancel"),
  //               onPressed: () {},
  //             ),
  //             TextButton(
  //               child: Text("Iya"),
  //               onPressed: () {
  //                 //deletePersonel(person2[i].username);
  //               },
  //             )
  //           ],
  //         );
  //       }
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Daftarkan Pegawai Baru"),
        ),
        body: SingleChildScrollView(
            child: Container(
          alignment: Alignment.center,
          child: Form(
            key: _formKey,
            child: Container(
                width: 500,
                child: Column(children: <Widget>[
                  Padding(
                      padding: EdgeInsets.all(10),
                      child: GestureDetector(
                          onTap: () {
                            if (kIsWeb) {
                              chooseImg();
                            } else {
                              captureImg();
                            }
                          }, // Image tapped
                          child: Container(
                            height: 200,
                            width: 150,
                            color: Colors.blue,
                            child: Image.memory(base64Decode(widget.avatar)),
                            // : Image.file(_avatar_proses!),
                          ))),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Username',
                      ),
                      controller: usernameController,
                      enabled: false,
                    ),
                  ),
                  Padding(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        children: [
                          SizedBox(
                              width: 440,
                              child: TextField(
                                controller: emailController,
                                decoration: const InputDecoration(
                                  labelText: 'E-mail',
                                ),
                                enabled: false,
                              )),
                          IconButton(onPressed: () {}, icon: Icon(Icons.edit))
                        ],
                      )),
                  Padding(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        children: [
                          SizedBox(
                              width: 440,
                              child: TextField(
                                controller: nomorTeleponController,
                                decoration: const InputDecoration(
                                  labelText: 'Nomor Telepon',
                                ),
                                enabled: false,
                              )),
                          IconButton(onPressed: () {}, icon: Icon(Icons.edit))
                        ],
                      )),
                  Padding(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        children: [
                          SizedBox(
                              width: 440,
                              child: TextField(
                                controller: namaDepanController,
                                decoration: const InputDecoration(
                                  labelText: 'Nama Depan',
                                ),
                                enabled: false,
                              )),
                          IconButton(onPressed: () {}, icon: Icon(Icons.edit))
                        ],
                      )),
                  Padding(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        children: [
                          SizedBox(
                              width: 440,
                              child: TextField(
                                controller: namaBelakangController,
                                decoration: const InputDecoration(
                                  labelText: 'Nama Belakang',
                                ),
                                onChanged: (value) {
                                  nama_belakang = value;
                                },
                                enabled: false,
                              )),
                          IconButton(onPressed: () {}, icon: Icon(Icons.edit))
                        ],
                      )),
                  Padding(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        children: [
                          SizedBox(
                              width: 440,
                              child: TextField(
                                controller: namaCabangController,
                                decoration: const InputDecoration(
                                  labelText: 'Cabang',
                                ),
                                onChanged: (value) {
                                  nama_belakang = value;
                                },
                                enabled: false,
                              )),
                          IconButton(onPressed: () {}, icon: Icon(Icons.edit))
                        ],
                      )),
                  Padding(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        children: [
                          SizedBox(
                              width: 440,
                              child: TextField(
                                controller: namaJabatanController,
                                decoration: const InputDecoration(
                                  labelText: 'Jabatan',
                                ),
                                onChanged: (value) {
                                  nama_belakang = value;
                                },
                                enabled: false,
                              )),
                          IconButton(onPressed: () {}, icon: Icon(Icons.edit))
                        ],
                      )),

                  // Padding(
                  //     padding: EdgeInsets.all(10),
                  //     child: Container(
                  //         height: 50,
                  //         width: 500,
                  //         child: DropdownButtonHideUnderline(
                  //             child: DropdownButton<String>(
                  //           hint: Text("Gender"),
                  //           value: gender,
                  //           items: genderList
                  //               .map<DropdownMenuItem<String>>((String value) {
                  //             return DropdownMenuItem<String>(
                  //               value: value,
                  //               child: Text(value),
                  //             );
                  //           }).toList(),
                  //           onChanged: (String? value) {
                  //             setState(() {
                  //               gender = value!;
                  //             });
                  //           },
                  //         )))),
                ])),
          ),
        )));
  }
}
