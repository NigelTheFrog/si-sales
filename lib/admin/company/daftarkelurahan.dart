import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pt_coronet_crown/class/admin/kelurahan.dart';
import 'package:pt_coronet_crown/class/jabatan.dart';
import 'package:pt_coronet_crown/drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';

class DaftarKelurahan extends StatefulWidget {
  String id, kecamatan;
  DaftarKelurahan({super.key, required this.id, required this.kecamatan});
  @override
  _DaftarKelurahanState createState() {
    return _DaftarKelurahanState();
  }
}

String id_jabatan = "";

class _DaftarKelurahanState extends State<DaftarKelurahan> {
  String _txtcari = "";
  TextEditingController namaJabatanController = TextEditingController();
  List kelurahan = [];

  Future<String> fetchData() async {
    final response = await http.post(
        Uri.parse(
            "http://192.168.137.1/magang/admin/kelurahan/daftarkelurahan.php"),
        body: {'id_kecamatan': widget.id, 'cari': _txtcari});
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to read API');
    }
  }

  // void submit(BuildContext context) async {
  //   final response = await http.post(
  //       Uri.parse(
  //           "http://192.168.137.1/magang/admin/product/tambahproduct.php"),
  //       body: {'produk': nama_jabatan});
  //   if (response.statusCode == 200) {
  //     Map json = jsonDecode(response.body);
  //     if (json['result'] == 'success') {
  //       if (!mounted) return;
  //       ScaffoldMessenger.of(context)
  //           .showSnackBar(SnackBar(content: Text('Sukses Menambah Data')));
  //       Navigator.popAndPushNamed(context, "daftarproduk");
  //     }
  //   } else {
  //     throw Exception('Failed to read API');
  //   }
  // }

  // void update(BuildContext context, id) async {
  //   final response = await http.post(
  //       Uri.parse("http://192.168.137.1/magang/admin/product/ubahproduct.php"),
  //       body: {'id': id, 'produk': nama_jabatan});
  //   if (response.statusCode == 200) {
  //     Map json = jsonDecode(response.body);
  //     if (json['result'] == 'success') {
  //       if (!mounted) return;
  //       ScaffoldMessenger.of(context)
  //           .showSnackBar(SnackBar(content: Text('Sukses Mengubah Data')));
  //       Navigator.popAndPushNamed(context, "daftarproduk");
  //     }
  //   } else {
  //     throw Exception('Failed to read API');
  //   }
  // }

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

  Widget daftarKelurahan(data) {
    List<Kelurahan> kelurahan2 = [];
    Map json = jsonDecode(data);
    if (json['result'] == "error") {
      return Text("Tidak terdapat data kelurahan");
    } else {
      for (var kel in json['data']) {
        Kelurahan kelurahan = Kelurahan.fromJson(kel);
        kelurahan2.add(kelurahan);
      }
      return ListView.builder(
          itemCount: kelurahan2.length,
          itemBuilder: (BuildContext ctxt, int index) {
            return Card(
                elevation: 2,
                child: ExpansionTile(
                    leading: Tooltip(
                        child: IconButton(
                            icon: Icon(Icons.edit), onPressed: () {}),
                        message: "Edit Kota"),
                    title: Text(kelurahan2[index].kelurahan),
                    children: <Widget>[
                      FittedBox(
                          child: kelurahan2[index].outlet != null
                              ? DataTable(
                                  border: TableBorder(
                                      verticalInside: BorderSide(
                                          width: 1,
                                          style: BorderStyle.solid,
                                          color: Color.fromARGB(75, 0, 0, 0))),
                                  headingRowColor:
                                      MaterialStateColor.resolveWith(
                                          (states) => Colors.grey.shade600),
                                  dataRowHeight: 65,
                                  columns: [
                                    DataColumn(
                                        label: Expanded(
                                            child: Text(
                                      "Nama Toko",
                                      textAlign: TextAlign.center,
                                    ))),
                                    DataColumn(
                                        label: Expanded(
                                            child: Text("Alamat",
                                                textAlign: TextAlign.center))),
                                    DataColumn(
                                        label: Expanded(
                                            child: Text("Kode pos",
                                                textAlign: TextAlign.center))),
                                    DataColumn(
                                        label: Expanded(
                                            child: Text("Action",
                                                textAlign: TextAlign.center))),
                                  ],
                                  rows: List<DataRow>.generate(
                                      kelurahan2[index].outlet!.length,
                                      (item) => DataRow(
                                              color: MaterialStateProperty
                                                  .resolveWith<Color>(
                                                      (Set<MaterialState>
                                                          states) {
                                                // Even rows will have a grey color.
                                                if (item % 2 == 0) {
                                                  return Colors.grey.shade300;
                                                } else {
                                                  return Colors.grey
                                                      .shade400; // Use default value for other states and odd rows.
                                                }
                                              }),
                                              cells: [
                                                DataCell(Align(
                                                    alignment: Alignment.center,
                                                    child: Tooltip(
                                                      child: TextButton(
                                                          onPressed: () {
                                                            print(kelurahan2[
                                                                        index]
                                                                    .outlet![
                                                                item]['id']);
                                                          },
                                                          child: Text(
                                                              kelurahan2[index]
                                                                          .outlet![
                                                                      item]
                                                                  ['nama_toko'],
                                                              textAlign:
                                                                  TextAlign
                                                                      .center)),
                                                      message: "Halaman Outlet",
                                                    ))),
                                                DataCell(Container(
                                                    alignment: Alignment.center,
                                                    width: 270,
                                                    child: Text(
                                                        kelurahan2[index]
                                                                .outlet![item]
                                                            ['alamat'],
                                                        style: TextStyle(
                                                            fontSize: 14),
                                                        textAlign: TextAlign
                                                            .justify))),
                                                DataCell(Align(
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                        kelurahan2[index]
                                                                .outlet![item]
                                                            ['kodepos'],
                                                        textAlign:
                                                            TextAlign.center))),
                                                DataCell(Align(
                                                    alignment: Alignment.center,
                                                    child: Tooltip(
                                                        child: IconButton(
                                                            icon: Icon(
                                                                Icons.edit),
                                                            onPressed: () {}),
                                                        message: "Edit Toko")))
                                              ])).toList())
                              : Text(
                                  "Tidak ada data outlet",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                )),
                      Tooltip(
                        message: "Tambah Outlet",
                        child: IconButton(
                            onPressed: () {
                              showAddDialog(2, kelurahan2[index].id,
                                  kelurahan2[index].kelurahan);
                            },
                            icon: const Icon(Icons.add)),
                      )
                    ]));
          });
    }
  }

  showAddDialog(type, id, kelurahan) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: type == 1
                ? Text('Menambah kelurahan')
                : Text('Menambah outlet pada kelurahan ${kelurahan}'),
            content: SizedBox(
                height: type == 1 ? 100 : 200,
                child: Column(children: [
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        // nama_jabatan = value;
                      });
                    },
                    decoration: InputDecoration(
                        hintText: type == 1
                            ? "Isikan Id Kelurahan"
                            : "Isikan Id Outlet"),
                  ),
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        // nama_jabatan = value;
                      });
                    },
                    decoration: InputDecoration(
                        hintText: type == 1
                            ? "Isikan nama kelurahan"
                            : "Isikan nama outlet"),
                  ),
                  if (type != 1)
                    Column(
                      children: [
                        TextField(
                          onChanged: (value) {
                            setState(() {
                              // nama_jabatan = value;
                            });
                          },
                          decoration:
                              InputDecoration(hintText: "Isikan alamat outlet"),
                        ),
                        TextField(
                          onChanged: (value) {
                            setState(() {
                              // nama_jabatan = value;
                            });
                          },
                          decoration: InputDecoration(
                              hintText: "Isikan kodepos outlet"),
                        ),
                      ],
                    )
                ])),
            actions: <Widget>[
              TextButton(
                child: const Text('CANCEL'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                    // nama_jabatan = "";
                  });
                },
              ),
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  setState(() {
                    // submit(context);
                  });
                },
              ),
            ],
          );
        });
  }

  Widget kolomCari() {
    return SizedBox(
      height: 50,
      width: 175,
      child: TextFormField(
        decoration: const InputDecoration(
          icon: Icon(Icons.search),
          labelText: 'Cari Kelurahan',
        ),
        onChanged: (value) {
          setState(() {
            _txtcari = value;
          });
          // bacaData();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (id_jabatan == "1") {
      return Scaffold(
          appBar: AppBar(
            leading: BackButton(onPressed: () => main()),
            title: Text("Daftar Kelurahan"),
          ),
          floatingActionButton: FloatingActionButton(
              onPressed: () {
                showAddDialog(1, "", "");
              },
              child: Tooltip(
                child: const Icon(Icons.add),
                message: "Tambah Kota",
              )),
          body: Align(
              alignment: Alignment.topCenter,
              child: Container(
                  alignment: Alignment.topCenter,
                  height: MediaQuery.of(context).size.height,
                  width: 800,
                  child: Column(children: [
                    Container(
                        margin: const EdgeInsets.all(10),
                        padding: EdgeInsets.all(10),
                        alignment: Alignment.topCenter,
                        child: kolomCari()),
                    Container(
                      alignment: Alignment.topCenter,
                      height: MediaQuery.of(context).size.height - 200,
                      width: 600,
                      child: FutureBuilder(
                          future: fetchData(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return daftarKelurahan(snapshot.data.toString());
                            } else {
                              return Center(child: CircularProgressIndicator());
                            }
                          }),
                    )
                  ]))));
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
