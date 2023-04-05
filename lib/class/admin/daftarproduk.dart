import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pt_coronet_crown/class/personel/personelgrup.dart';
import 'package:pt_coronet_crown/class/produk.dart';
import 'package:pt_coronet_crown/drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';

class DaftarProduk extends StatefulWidget {
  DaftarProduk({Key? key}) : super(key: key);
  @override
  _DaftarProdukState createState() {
    return _DaftarProdukState();
  }
}

String id_jabatan = "";

class _DaftarProdukState extends State<DaftarProduk> {
  String _txtcari = "", nama_produk = "";
  TextEditingController productname = TextEditingController();

  Future<String> fetchData() async {
    final response = await http.post(
        Uri.parse("http://192.168.137.1/magang/admin/product/daftarproduct.php"),
        body: {'cari': _txtcari});
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to read API');
    }
  }

  void submit(BuildContext context) async {
    final response = await http.post(
        Uri.parse("http://192.168.137.1/magang/admin/product/tambahproduct.php"),
        body: {'produk': nama_produk});
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
        body: {'id': id, 'produk': nama_produk});
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

  Widget daftarProduk(data) {
    List<Produk> produk2 = [];
    Map json = jsonDecode(data);
    if (json['result'] == "error") {
      return Container(
          child: DataTable(columns: [
        DataColumn(label: Text("ID")),
        DataColumn(label: Text("Jenis")),
      ], rows: []));
    } else {
      for (var prod in json['data']) {
        Produk produk = Produk.fromJson(prod);
        produk2.add(produk);
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
                          child: Text("Jenis", textAlign: TextAlign.center))),
                ],
                    rows: produk2
                        .map<DataRow>((element) => DataRow(cells: [
                              DataCell(Align(
                                  alignment: Alignment.center,
                                  child: TextButton(
                                    child: Text(element.id.toString(),
                                        textAlign: TextAlign.center),
                                    onPressed: () {
                                      setState(() {
                                        productname.text = element.jenis;
                                      });
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: const Text(
                                                  'Mengganti Nama Produk'),
                                              content: TextField(
                                                controller: productname,
                                                onChanged: (value) {
                                                  setState(() {
                                                    nama_produk = value;
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
                                                      nama_produk = "";
                                                    });
                                                  },
                                                ),
                                                TextButton(
                                                  child: const Text('OK'),
                                                  onPressed: () {
                                                    setState(() {
                                                      update(
                                                          context, element.id.toString());
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
                                  child: Text(element.jenis,
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
            title: Text("Daftar Produk"),
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
                              nama_produk = value;
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
                                nama_produk = "";
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.all(10),
                    padding: EdgeInsets.all(10),
                    alignment: Alignment.topCenter,
                    width: 400,
                    child: TextFormField(
                      decoration: const InputDecoration(
                        icon: Icon(Icons.search),
                        labelText: 'Cari Produk',
                      ),
                      onChanged: (value) {
                        setState(() {
                          _txtcari = value;
                        });
                        // bacaData();
                      },
                    ),
                  ),
                  Container(
                      alignment: Alignment.topCenter,
                      height: MediaQuery.of(context).size.height,
                      width: 800,
                      child: FutureBuilder(
                          future: fetchData(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return daftarProduk(snapshot.data.toString());
                            } else {
                              return Center(child: CircularProgressIndicator());
                            }
                          }))
                ],
              ),
            ),
          ));
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text("Daftar Produk"),
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
