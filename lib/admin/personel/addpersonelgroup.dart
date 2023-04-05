import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pt_coronet_crown/admin/personel/personelgroup.dart';
import 'package:pt_coronet_crown/class/cabang.dart';
import 'package:http/http.dart' as http;
import 'package:pt_coronet_crown/class/personel/personel.dart';

class CreateGroup extends StatefulWidget {
  CreateGroup({Key? key}) : super(key: key);
  @override
  _CreateGroupState createState() {
    return _CreateGroupState();
  }
}

class _CreateGroupState extends State<CreateGroup> {
  late Timer timer;
  String _idgroup = "",
      _namagroup = "",
      cabang = "",
      controllerCabang = "",
      controllerPegawai = "",
      _pegawai = "";

  bool nullChecker = true;

  final _formKey = GlobalKey<FormState>();

  Future<List> daftarCabang() async {
    Map json;
    final response = await http.post(
      Uri.parse("http://192.168.137.1/magang/admin/cabang/daftarcabang.php"),
    );
    if (response.statusCode == 200) {
      json = jsonDecode(response.body);
      return json['data'];
    } else {
      throw Exception('Failed to read API');
    }
  }

  Future<List> daftarPegawai() async {
    Map json;
    final response = await http.post(
        Uri.parse(
            "http://192.168.137.1/magang/admin/personel/personelgroup/daftarPegawai.php"),
        body: {'id_cabang': cabang});
    if (response.statusCode == 200) {
      json = jsonDecode(response.body);
      var data;
      if (json['result'] == "success") {
        nullChecker = false;
        data = json['data'];
      } else if (json['result'] == "error") {
        nullChecker = true;
        data = json['error'];
      }
      return data;
    } else {
      throw Exception('Failed to read API');
    }
  }

  void submit(BuildContext context) async {
    final response = await http.post(
        Uri.parse(
            "http://192.168.137.1/magang/admin/personel/personelgroup/tambahgrup.php"),
        body: {
          'id': _idgroup,
          'nama_group': _namagroup,
          'username': _pegawai,
          'id_cabang': cabang,
        });
    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      if (json['result'] == 'success') {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Sukses Menambah Data')));
        dispose();
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => PersonelGroup()));
      }
    } else {
      throw Exception('Failed to read API');
    }
  }

  Widget comboCabang = Text("");
  Widget comboPegawai = Text("");

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    timer = Timer.periodic(const Duration(milliseconds: 250), (timer) {
      setState(() {
        generatDaftarCabang();
        generatDaftarPegawai();
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
                    print(cabang);
                    controllerCabang = value[1].toString();
                  });
                }));
      });
    });
  }

  void generatDaftarPegawai() {
    List<Person> persons;
    var data = daftarPegawai();
    if (nullChecker == true) {
      setState(() {
        comboPegawai = DropdownButtonHideUnderline(
            child: DropdownButton(
                hint: Text("Daftar Pegawai"),
                isDense: false,
                items: [
                  DropdownMenuItem(
                    child: Text('Tidak ada cabang terpilih'),
                    value: "Tidak ada cabang terpilih'",
                  )
                ],
                onChanged: (value) {
                  setState(() {});
                }));
      });
    } else {
      data.then((value) {
        persons = List<Person>.from(value.map((i) {
          return Person.fromJson(i);
        }));
        setState(() {
          comboPegawai = DropdownButtonHideUnderline(
              child: DropdownButton(
                  hint: controllerPegawai == ""
                      ? Text("Daftar Pegawai")
                      : Text(
                          controllerPegawai,
                          style: TextStyle(color: Colors.black),
                        ),
                  isDense: false,
                  items: persons.map((person) {
                    return DropdownMenuItem(
                      child:
                          Text("${person.nama_depan} ${person.nama_belakang}"),
                      value: [
                        person.username,
                        "${person.nama_depan} ${person.nama_belakang}"
                      ],
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _pegawai = value![0].toString();
                      print(_pegawai);
                      controllerPegawai = value[1].toString();
                    });
                  }));
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Tambah Grup Baru"),
        ),
        body: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            child: Align(
                alignment: Alignment.center,
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Container(
                        width: 500,
                        child: Column(children: <Widget>[
                          Padding(
                              padding: EdgeInsets.all(10),
                              child: TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Id Group',
                                ),
                                onChanged: (value) {
                                  _idgroup = value;
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Id Group tidak boleh kosong';
                                  }
                                  return null;
                                },
                              )),
                          Padding(
                              padding: EdgeInsets.all(10),
                              child: TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Nama Group',
                                ),
                                onChanged: (value) {
                                  _namagroup = value;
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Nama group tidak boleh kosong';
                                  }
                                  return null;
                                },
                              )),
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
                                child: comboPegawai,
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
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Harap Isian diperbaiki')));
                                  } else
                                    submit(context);
                                },
                                child: Text('Submit'),
                              ),
                            ),
                          )
                        ])),
                  ),
                ))));
  }
}
