import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:pt_coronet_crown/account/login.dart';
import 'package:pt_coronet_crown/class/cabang.dart';
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

class _CreateAccountState extends State<CreateAccount> {
  String _username = "",
      _password = "",
      _passwordCheck = "",
      _namaDepan = "",
      _namaBelakang = "",
      _email = "",
      select_file = "",
      cabang = "";
  int _jabatan = 1;
  var _avatar = null;
  var _avatar_proses = null;
  String error_picture = "", error_username = "";

  final picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

  Future<List> daftarCabang() async {
    Map json;
    final response = await http.post(
      Uri.parse("http://localhost/magang/cabang/daftarcabang.php"),
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
          'jabatan': "1",
          'cabang': "JTM-SDJ-TAMAN",
          'grup': 'JTM-SDJ-TAMAN-1'
        });
    if (response.statusCode == 200) {
      print(response.body);
      Map json = jsonDecode(response.body);
      if (json['result'] == 'success') {
        setState(() {
          error_picture = "";
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Sukses Menambah Data')));
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Login()));
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      generatDaftarCabang();
    });
  }

  void generatDaftarCabang() {
    List<Cabang> cabangs;
    var data = daftarCabang();
    data.then((value) {
      print(value);
      cabangs = List<Cabang>.from(value.map((i) {
        return Cabang.fromJson(i);
      }));
      setState(() {
        comboCabang = DropdownButton(
            dropdownColor: Colors.grey[100],
            hint: Text("Daftar Cabang"),
            isDense: false,
            items: cabangs.map((cabang) {
              return DropdownMenuItem(
                child: Column(children: <Widget>[
                  Text(cabang.nama_cabang, overflow: TextOverflow.visible),
                ]),
                value: cabang.id,
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                cabang = value!;
              });
            });
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
        // List<int> imageBytes = _avatar_proses!.readAsBytesSync();
        // _avatar_proses = imageBytes;
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
                  if (error_picture != "")
                    Text(error_picture, style: TextStyle(color: Colors.red)),
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
                  Padding(padding: EdgeInsets.all(10), child: comboCabang),
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
