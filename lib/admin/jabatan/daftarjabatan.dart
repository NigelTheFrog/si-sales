import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pt_coronet_crown/class/jabatan.dart';
import 'package:pt_coronet_crown/class/produk.dart';
import 'package:pt_coronet_crown/drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';

class DaftarJabatan extends StatefulWidget {
  DaftarJabatan({Key? key}) : super(key: key);
  @override
  _DaftarJabatanState createState() {
    return _DaftarJabatanState();
  }
}

String id_jabatan = "";

class _DaftarJabatanState extends State<DaftarJabatan> {
  String _txtcari = "", nama_jabatan = "";
  TextEditingController namaJabatanController = TextEditingController();

  Future<String> fetchData() async {
    final response = await http.post(
      Uri.parse("http://192.168.137.1/magang/admin/jabatan/daftarjabatan.php"),
    );
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to read API');
    }
  }

  void submit(BuildContext context) async {
    final response = await http.post(
        Uri.parse(
            "http://192.168.137.1/magang/admin/product/tambahproduct.php"),
        body: {'produk': nama_jabatan});
    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      if (json['result'] == 'success') {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Sukses Menambah Data')));
        Navigator.popAndPushNamed(context, "daftarproduk");
      }
    } else {
      throw Exception('Failed to read API');
    }
  }

  void update(BuildContext context, id) async {
    final response = await http.post(
        Uri.parse("http://192.168.137.1/magang/admin/product/ubahproduct.php"),
        body: {'id': id, 'produk': nama_jabatan});
    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      if (json['result'] == 'success') {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Sukses Mengubah Data')));
        Navigator.popAndPushNamed(context, "daftarproduk");
      }
    } else {
      throw Exception('Failed to read API');
    }
  }

  _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      id_jabatan = prefs.getString("idJabatan") ?? '';
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadData();
  }

  Widget daftarJabatan(data) {
    List<Jabatan> jabatan2 = [];
    Map json = jsonDecode(data);
    if (json['result'] == "error") {
      return Container(
          child: DataTable(columns: [
        DataColumn(label: Text("ID")),
        DataColumn(label: Text("Jenis")),
      ], rows: []));
    } else {
      for (var jab in json['data']) {
        Jabatan jabatan = Jabatan.fromJson(jab);
        jabatan2.add(jabatan);
      }
      return ListView.builder(
          scrollDirection: MediaQuery.of(context).size.width >= 725
              ? Axis.vertical
              : Axis.horizontal,
          itemCount: 1,
          itemBuilder: (BuildContext ctxt, int index) {
            return Container(
                child: DataTable(
                    columns: [
                  DataColumn(
                      label: Expanded(
                          child: Text(
                    "ID",
                    textAlign: TextAlign.center,
                  ))),
                  DataColumn(
                      label: Expanded(
                          child: Text("Jabatan", textAlign: TextAlign.center))),
                  DataColumn(
                      label: Expanded(
                          child:
                              Text("Keterangan", textAlign: TextAlign.center))),
                ],
                    rows: jabatan2
                        .map<DataRow>((element) => DataRow(cells: [
                              DataCell(Align(
                                  alignment: Alignment.center,
                                  child: TextButton(
                                    child: Text(element.id.toString(),
                                        textAlign: TextAlign.center),
                                    onPressed: () {
                                      setState(() {
                                        namaJabatanController.text =
                                            element.jabatan;
                                      });
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: const Text(
                                                  'Mengganti Nama Produk'),
                                              content: TextField(
                                                controller:
                                                    namaJabatanController,
                                                onChanged: (value) {
                                                  setState(() {
                                                    nama_jabatan = value;
                                                  });
                                                },
                                                decoration: const InputDecoration(
                                                    hintText:
                                                        "Isikan nama produk"),
                                              ),
                                              actions: <Widget>[
                                                TextButton(
                                                  child: const Text('CANCEL'),
                                                  onPressed: () {
                                                    setState(() {
                                                      Navigator.pop(context);
                                                      nama_jabatan = "";
                                                    });
                                                  },
                                                ),
                                                TextButton(
                                                  child: const Text('OK'),
                                                  onPressed: () {
                                                    setState(() {
                                                      update(
                                                          context,
                                                          element.id
                                                              .toString());
                                                    });
                                                  },
                                                ),
                                              ],
                                            );
                                          });
                                    },
                                  ))),
                              DataCell(Align(
                                  alignment: Alignment.center,
                                  child: Text(element.jabatan,
                                      textAlign: TextAlign.center))),
                              DataCell(Align(
                                  alignment: Alignment.center,
                                  child: Text(element.keterangan,
                                      textAlign: TextAlign.center))),
                            ]))
                        .toList()));
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (id_jabatan == "1") {
      return Scaffold(
        appBar: AppBar(
          title: Text("Daftar Jabatan"),
        ),
        drawer: MyDrawer(),
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Menambah Produk'),
                      content: TextField(
                        onChanged: (value) {
                          setState(() {
                            nama_jabatan = value;
                          });
                        },
                        decoration: const InputDecoration(
                            hintText: "Isikan nama produk"),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('CANCEL'),
                          onPressed: () {
                            setState(() {
                              Navigator.pop(context);
                              nama_jabatan = "";
                            });
                          },
                        ),
                        TextButton(
                          child: const Text('OK'),
                          onPressed: () {
                            setState(() {
                              submit(context);
                            });
                          },
                        ),
                      ],
                    );
                  });
            },
            child: Tooltip(
              child: const Icon(Icons.add),
              message: "Tambah produk",
            )),
        body: Container(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
              child: Container(
                  alignment: Alignment.topCenter,
                  height: MediaQuery.of(context).size.height,
                  width: 800,
                  child: FutureBuilder(
                      future: fetchData(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return daftarJabatan(snapshot.data.toString());
                        } else {
                          return Center(child: CircularProgressIndicator());
                        }
                      }))),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text("Daftar Jabatan"),
        ),
        body: Center(
          child: Text(
            "Anda tidak memiliki akses ke halaman ini \nSilahkan kontak admin",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
  }
}
