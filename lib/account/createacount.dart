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

class CreateAccount extends StatefulWidget {
  CreateAccount({Key? key}) : super(key: key);
  @override
  _CreateAccountState createState() {
    return _CreateAccountState();
  }
}

const List<String> genderList = <String>['Pria', 'Wanita'];

class _CreateAccountState extends State<CreateAccount> {
  String _username = "",
      _password = "",
      _passwordCheck = "",
      _namaDepan = "",
      _namaBelakang = "",
      _email = "",
      cabang = "",
      gender = "",
      nomor_telepon = "",
      jabatan = "";

  final _formKey = GlobalKey<FormState>();

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
    final response = await http.post(
        Uri.parse("https://otccoronet.com/otc/account/createaccount.php"),
        body: {
          'username': _username,
          'namaDepan': _namaDepan,
          'namaBelakang': _namaBelakang,
          'email': _email,
          'password': _password,
          'gender': gender,
          'no_telp': nomor_telepon,
          'jabatan': jabatan,
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    Navigator.popAndPushNamed(context, "/homepage");
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Daftarkan Pegawai Baru",
            style: TextStyle(color: Colors.white),
          ),
          leading: BackButton(
            onPressed: () => dispose(),
            color: Colors.white,
          ),
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
                        child: Text(
                          'Submit',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  )
                ])),
          ),
        )));
  }
}
