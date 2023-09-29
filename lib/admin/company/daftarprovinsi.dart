import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pt_coronet_crown/admin/company/daftarkelurahan.dart';
import 'package:pt_coronet_crown/class/admin/provinsi.dart';
import 'package:pt_coronet_crown/drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';

class DaftarProvinsi extends StatefulWidget {
  DaftarProvinsi({Key? key}) : super(key: key);
  @override
  _DaftarProvinsiState createState() {
    return _DaftarProvinsiState();
  }
}

String id_jabatan = "";

class _DaftarProvinsiState extends State<DaftarProvinsi> {
  String _txtcari = "",
      id_area = "",
      controllerarea = "";
  TextEditingController namaJabatanController = TextEditingController();
  List area = [];

  Future<String> fetchData() async {
    final response = await http.post(
        Uri.parse(
            "https://otccoronet.com/otc/admin/provinsi/daftarprovinsi.php"),
        body: {'id_area': id_area, 'cari': _txtcari});
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

  Widget daftarProvinsi(data) {
    List<Provinsi> prov2 = [];
    Map json = jsonDecode(data);
    if (json['result'] == "error") {
      return Container();
    } else {
      for (var p in json['data']) {
        Provinsi prov = Provinsi.fromJson(p);
        prov2.add(prov);
      }
      return ListView.builder(
          padding: EdgeInsets.only(left: 5, right: 5),
          itemCount: prov2.length,
          itemBuilder: (BuildContext ctxt, int index) {
            return Card(
                elevation: 2,
                child: ExpansionTile(
                    leading: Tooltip(
                        child: IconButton(
                            icon: Icon(Icons.edit), onPressed: () {}),
                        message: "Edit Provinsi"),
                    title: Text(prov2[index].provinsi),
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
                                        child: Text(
                                  "ID",
                                  textAlign: TextAlign.center,
                                ))),
                                DataColumn(
                                    label: Expanded(
                                        child: Text("Kota",
                                            textAlign: TextAlign.center))),
                                DataColumn(
                                    label: Expanded(
                                        child: Text("Action",
                                            textAlign: TextAlign.center))),
                              ],
                              rows: List<DataRow>.generate(
                                  prov2[index].kota!.length,
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
                                                  message: "Halaman Kecamatan",
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
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        DaftarKelurahan(
                                                                          id: prov2[index].kota![item]
                                                                              [
                                                                              'id'],
                                                                          kecamatan:
                                                                              prov2[index].kota![item]['kecamatan'],
                                                                        )));
                                                      },
                                                      child: Text(
                                                          prov2[index].kota![item]
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
                                                    prov2[index].kota![item]
                                                        ['kota'],
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
                        message: "Tambah Kota",
                        child: IconButton(
                            onPressed: () {
                              showAddDialog(
                                  2, prov2[index].id, prov2[index].provinsi);
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
          labelText: 'Cari Provinsi',
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

  Widget ComboArea() {
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
                  labelText: "Daftar Area",
                ),
                mode: Mode.MENU,
                showSearchBox: false,
                onFind: (text) async {
                  Map json;
                  var response = await http.post(Uri.parse(
                      "https://otccoronet.com/otc/admin/area/daftararea.php"));
                  if (response.statusCode == 200) {
                    json = jsonDecode(response.body);
                    setState(() {
                      area = json['data'];
                    });
                  }
                  return area;
                },
                onChanged: (value) {
                  setState(() {
                    id_area = value['id'].toString();
                    controllerarea = value['area'];
                  });
                },
                itemAsString: (item) => item['area']),
          ),
          SizedBox(
              height: 55,
              width: 20,
              child: Tooltip(
                  message: "Tambah Area",
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
                ? Text('Menambah provinsi pada area ${controllerarea}')
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
                    "DAFTAR PROVINSI DAN KOTA OUTLET",
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
                      children: [kolomCari(), ComboArea()],
                    )),
                Container(
                  alignment: Alignment.topCenter,
                  height: MediaQuery.of(context).size.height - 219,
                  width: 450,
                  child: FutureBuilder(
                      future: fetchData(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return daftarProvinsi(snapshot.data.toString());
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
