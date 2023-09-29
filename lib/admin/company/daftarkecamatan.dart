import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pt_coronet_crown/admin/company/daftarkelurahan.dart';
import 'package:pt_coronet_crown/class/admin/kelurahan.dart';
import 'package:pt_coronet_crown/class/admin/provinsi.dart';
import 'package:pt_coronet_crown/drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';

class DaftarKecamatan extends StatefulWidget {
  String id_kota;
  DaftarKecamatan({
    super.key,
    required this.id_kota,
  });
  @override
  _DaftarKecamatanState createState() {
    return _DaftarKecamatanState();
  }
}

String id_jabatan = "";

class _DaftarKecamatanState extends State<DaftarKecamatan> {
  String _txtcari = "",
      id_kecamatan = "3",
      controllerKecamatan = "Jawa Timur, Bali, NTT, NTB";
  TextEditingController namaJabatanController = TextEditingController();
  List kecamatan = [];

  Future<String> fetchData() async {
    final response = await http.post(
        Uri.parse(
            "https://otccoronet.com/otc/admin/kelurahan/daftarkelurahan.php"),
        body: {'id_kecamatan': kecamatan.first['id'], 'cari': _txtcari});
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
    List<Kelurahan> kel2 = [];
    Map json = jsonDecode(data);
    if (json['result'] == "error") {
      return Container();
    } else {
      for (var k in json['data']) {
        Kelurahan kel = Kelurahan.fromJson(k);
        kel2.add(kel);
      }
      return ListView.builder(
          padding: EdgeInsets.only(left: 5, right: 5),
          itemCount: kel2.length,
          itemBuilder: (BuildContext ctxt, int index) {
            return Card(
                elevation: 2,
                child: ExpansionTile(
                    leading: Tooltip(
                        child: IconButton(
                            icon: Icon(Icons.edit), onPressed: () {}),
                        message: "Edit Provinsi"),
                    title: Text(kel2[index].kelurahan),
                    children: <Widget>[
                      FittedBox(
                          child: DataTable(
                              border: TableBorder(
                                  verticalInside: BorderSide(
                                      width: 1,
                                      style: BorderStyle.solid,
                                      color: Color.fromARGB(75, 0, 0, 0))),
                              headingRowColor: MaterialStateColor.resolveWith(
                                  (states) => Colors.grey.shade600),
                              columns: [
                                DataColumn(
                                    label: Expanded(
                                        child: Text("Nama Outlet",
                                            textAlign: TextAlign.center))),
                                DataColumn(
                                    label: Expanded(
                                        child: Text("Jenis Outlet",
                                            textAlign: TextAlign.center))),
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
                                            textAlign: TextAlign.center)))
                              ],
                              rows: List<DataRow>.generate(
                                  kel2[index].outlet!.length,
                                  (item) => DataRow(
                                          color: MaterialStateProperty
                                              .resolveWith<Color>(
                                                  (Set<MaterialState> states) {
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
                                                  message:
                                                      "Halaman Detail Outlet",
                                                  child: TextButton(
                                                      style: ButtonStyle(foregroundColor:
                                                          MaterialStateProperty
                                                              .resolveWith<Color>(
                                                                  (Set<MaterialState>
                                                                      states) {
                                                        if (states.contains(
                                                            MaterialState
                                                                .hovered))
                                                          return Colors
                                                              .blue.shade400;
                                                        return Colors.blue
                                                            .shade600; // null throus error in flutter 2.2+.
                                                      })),
                                                      onPressed: () {
                                                        // Navigator.push(
                                                        //     context,
                                                        //     MaterialPageRoute(
                                                        //         builder:
                                                        //             (context) =>
                                                        //                 DaftarKelurahan(
                                                        //                   id: prov2[index].kota![item]
                                                        //                       [
                                                        //                       'id'],
                                                        //                   kecamatan:
                                                        //                       prov2[index].kota![item]['kecamatan'],
                                                        //                 )));
                                                      },
                                                      child: Text(
                                                          kel2[index].outlet![item]
                                                              ['id'],
                                                          style: TextStyle(
                                                              decoration:
                                                                  TextDecoration
                                                                      .underline),
                                                          textAlign: TextAlign.center)),
                                                ))),
                                            DataCell(Align(
                                                alignment: Alignment.center,
                                                child: Text(
                                                    kel2[index].outlet![item]
                                                        ['nama_toko'],
                                                    textAlign:
                                                        TextAlign.center))),
                                            DataCell(Align(
                                                alignment: Alignment.center,
                                                child: Text(
                                                    kel2[index].outlet![item]
                                                        ['jenis'],
                                                    textAlign:
                                                        TextAlign.center))),
                                            DataCell(Align(
                                                alignment: Alignment.center,
                                                child: Text(
                                                    kel2[index].outlet![item]
                                                        ['alamat'],
                                                    textAlign:
                                                        TextAlign.center))),
                                            DataCell(Align(
                                                alignment: Alignment.center,
                                                child: Text(
                                                    kel2[index].outlet![item]
                                                        ['kodepos'],
                                                    textAlign:
                                                        TextAlign.center))),
                                            DataCell(Align(
                                                alignment: Alignment.center,
                                                child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Tooltip(
                                                          message: "Edit Kota",
                                                          child: IconButton(
                                                              icon: Icon(
                                                                  Icons.edit),
                                                              onPressed:
                                                                  () {})),
                                                      Tooltip(
                                                          message: "Hapus Kota",
                                                          child: IconButton(
                                                              icon: Icon(
                                                                  Icons.delete),
                                                              onPressed: () {}))
                                                    ])))
                                          ])).toList())),
                      Tooltip(
                        message: "Tambah Outlet",
                        child: IconButton(
                            onPressed: () {
                              showAddDialog(
                                  2, kel2[index].id, kel2[index].kelurahan);
                            },
                            icon: const Icon(Icons.add)),
                      )
                    ]));
          });
    }
  }

  Widget kolomCari() {
    return SizedBox(
      height: 55,
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

  Widget ComboKecamatan() {
    return SizedBox(
        height: 55,
        width: 200,
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          SizedBox(
            height: 55,
            width: 175,
            child: DropdownSearch<dynamic>(
              dropdownSearchDecoration: InputDecoration(
                labelText: "Daftar Kecamatan",
              ),
              mode: Mode.MENU,
              showSearchBox: true,
              onFind: (text) async {
                Map json;
                var response = await http.post(
                    Uri.parse(
                        "https://otccoronet.com/otc/admin/kecamatan/daftarkecamatan.php"),
                    body: {'id_kota': widget.id_kota, 'cari': text});
                if (response.statusCode == 200) {
                  json = jsonDecode(response.body);
                  setState(() {
                    kecamatan = json['data'];
                  });
                }
                return kecamatan;
              },
              onChanged: (value) {
                setState(() {
                  id_kecamatan = value['id'].t;
                  controllerKecamatan = value['kecamatan'];
                });
              },
              itemAsString: (item) => item['kecamatan'],
            ),
          ),
          SizedBox(
              height: 55,
              width: 20,
              child: Tooltip(
                  message: "Tambah Kecamatan",
                  child: IconButton(
                      icon: Icon(Icons.add),
                      padding: EdgeInsets.zero,
                      onPressed: () => showAddDialog(1, "", ""))))
        ]));
  }

  showAddDialog(type, id, provinsi) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: type == 1
                ? Text('Menambah provinsi pada area ${controllerKecamatan}')
                : Text('Menambah kota pada provinsi ${provinsi}'),
            content: SizedBox(
                height: 100,
                child: Column(children: [
                  Container(
                      child: TextField(
                    onChanged: (value) {
                      setState(() {
                        // nama_jabatan = value;
                      });
                    },
                    decoration: InputDecoration(
                        hintText: type == 1
                            ? "Isikan Id Provinsi"
                            : "Isikan Id Kota"),
                  )),
                  Container(
                      child: TextField(
                    onChanged: (value) {
                      setState(() {
                        // nama_jabatan = value;
                      });
                    },
                    decoration: InputDecoration(
                        hintText: type == 1
                            ? "Isikan nama Kota"
                            : "Isikan nama kecamatan"),
                  )),
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

  @override
  Widget build(BuildContext context) {
    if (id_jabatan == "1") {
      return Scaffold(
          // appBar: AppBar(
          //   title: Text("Daftar Kota Outlet"),
          // ),
          drawer: MyDrawer(),
          // floatingActionButton: FloatingActionButton(
          //     onPressed: () {
          //       showAddDialog(1, "", "");
          //     },
          //     child: Tooltip(
          //       child: const Icon(Icons.add),
          //       message: "Tambah Provinsi",
          //     )),
          body: Container(
              alignment: Alignment.topCenter,
              // height: MediaQuery.of(context).size.height,
              child: Column(children: [
                Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text(
                    "DAFTAR OUTLET",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                    margin: const EdgeInsets.all(10),
                    padding: EdgeInsets.all(10),
                    alignment: Alignment.topCenter,
                    height: 100,
                    width: 410,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [kolomCari(), ComboKecamatan()],
                    )),
                Container(
                  alignment: Alignment.topCenter,
                  height: MediaQuery.of(context).size.height - 219,
                  width: 450,
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
              ])));
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text("Daftar Kota Outlet"),
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
