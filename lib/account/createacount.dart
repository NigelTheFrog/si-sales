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
import '../main.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;

class CreateAccount extends StatefulWidget {
  CreateAccount({Key? key}) : super(key: key);
  @override
  _CreateAccountState createState() {
    return _CreateAccountState();
  }
}

const List<String> genderList = <String>['Pria', 'Wanita'];

class _CreateAccountState extends State<CreateAccount> {
  late Timer timer;
  String _username = "",
      _password = "",
      _passwordCheck = "",
      _namaDepan = "",
      _namaBelakang = "",
      _email = "",
      cabang = "",
      gender = genderList.first.toString(),
      nomor_telepon = "",
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
          'username': _username,
          'namaDepan': _namaDepan,
          'namaBelakang': _namaBelakang,
          'email': _email,
          'password': _password,
          'avatar': base64Image,
          'gender': gender,
          'no_telp': nomor_telepon,
          'jabatan': _jabatan,
          'cabang': cabang,
          'grup': 'JTM-SDJ-TAMAN-1'
        });
    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      if (json['result'] == 'success') {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Sukses Menambah Data')));
        Navigator.of(context).pop();
      } else if (json['Error'] ==
          "Got a packet bigger than 'max_allowed_packet' bytes") {
        setState(() {
          warningDialog(context, "Ukuran gambar terlalu besar");
        });
      } else if (json['Error'] ==
          "Duplicate entry '$_username-1' for key 'PRIMARY'") {
        setState(() {
          warningDialog(context, "Username telah dipakai");
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
    timer = Timer.periodic(const Duration(milliseconds: 250), (timer) {
      setState(() {
        generatDaftarCabang();
        generatDaftarJabatan();
      });
    });
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
                dropdownColor: Colors.grey[100],
                hint: controllerCabang == ""
                    ? Text("Daftar Cabang")
                    : Text(controllerCabang),
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
                dropdownColor: Colors.grey[100],
                hint: controllerJabatan == ""
                    ? Text("Daftar Jabatan")
                    : Text(controllerJabatan),
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
                            child: _avatar_proses == null
                                ? Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Belum ada gambar diambil',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  )
                                : Image.memory(_avatar_proses!),
                            // : Image.file(_avatar_proses!),
                          ))),
                  Padding(
                      padding: EdgeInsets.all(10),
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Username',
                        ),
                        onChanged: (value) {
                          _username = value;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Username tidak boleh kosong';
                          }
                          return null;
                        },
                      )),
                  Padding(
                      padding: EdgeInsets.all(10),
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Password',
                        ),
                        onChanged: (value) {
                          _password = value;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password tidak boleh kosong';
                          }
                          return null;
                        },
                        obscureText: true,
                      )),
                  Padding(
                      padding: EdgeInsets.all(10),
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Isi ulang password',
                        ),
                        onChanged: (value) {
                          _passwordCheck = value;
                        },
                        validator: (value) {
                          if (value != _password) {
                            return 'Password tidak sama';
                          }
                          return null;
                        },
                        obscureText: true,
                      )),
                  Padding(
                      padding: EdgeInsets.all(10),
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'E-mail',
                        ),
                        onChanged: (value) {
                          _email = value;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email tidak boleh kosong';
                          }
                          return null;
                        },
                      )),
                  Padding(
                      padding: EdgeInsets.all(10),
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Nomor Telepon',
                        ),
                        onChanged: (value) {
                          nomor_telepon = value;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nomor telepon tidak boleh kosong';
                          }
                          return null;
                        },
                      )),
                  Padding(
                      padding: EdgeInsets.all(10),
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Nama Depan',
                        ),
                        onChanged: (value) {
                          _namaDepan = value;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nama depan tidak boleh kosong';
                          }
                          return null;
                        },
                      )),
                  Padding(
                      padding: EdgeInsets.all(10),
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Nama Belakang',
                        ),
                        onChanged: (value) {
                          _namaBelakang = value;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nama belakang tidak boleh kosong';
                          }
                          return null;
                        },
                      )),
                  Padding(
                      padding: EdgeInsets.all(10),
                      child: Container(
                          height: 50,
                          width: 500,
                          child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                            hint: Text("Gender"),
                            value: gender,
                            items: genderList
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? value) {
                              setState(() {
                                gender = value!;
                              });
                            },
                          )))),
                  Padding(
                      padding: EdgeInsets.all(10),
                      child: Container(
                        height: 50,
                        width: 500,
                        child: comboCabang,
                      )),
                  Padding(
                      padding: EdgeInsets.all(10),
                      child: Container(
                        height: 50,
                        width: 500,
                        child: comboJabatan,
                      )),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Container(
                      height: 50,
                      width: 300,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState != null &&
                              !_formKey.currentState!.validate()) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text('Harap Isian diperbaiki')));
                          } else
                            submit(context);
                        },
                        child: Text('Submit'),
                      ),
                    ),
                  )
                ])),
          ),
        )));
  }
}
