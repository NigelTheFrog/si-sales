import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pt_coronet_crown/admin/company/daftarkelurahan.dart';
import 'package:pt_coronet_crown/class/admin/kota.dart';
import 'package:pt_coronet_crown/drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';

class DaftarKota extends StatefulWidget {
  DaftarKota({Key? key}) : super(key: key);
  @override
  _DaftarKotaState createState() {
    return _DaftarKotaState();
  }
}

String id_jabatan = "";

class _DaftarKotaState extends State<DaftarKota> {
  String _txtcari = "", id_provinsi = "JTM", controllerprovinsi = "Jawa Timur";
  TextEditingController namaJabatanController = TextEditingController();
  List provinsi = [];

  Future<String> fetchData() async {
    final response = await http.post(
        Uri.parse("http://192.168.137.1/magang/admin/kota/daftarkota.php"),
        body: {'id_provinsi': id_provinsi, 'cari': _txtcari});
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

  Widget daftarKota(data) {
    List<Kota> kota2 = [];
    Map json = jsonDecode(data);
    if (json['result'] == "error") {
      return Container();
    } else {
      for (var kot in json['data']) {
        Kota kota = Kota.fromJson(kot);
        kota2.add(kota);
      }
      return ListView.builder(
          itemCount: kota2.length,
          itemBuilder: (BuildContext ctxt, int index) {
            return Card(
                elevation: 2,
                child: ExpansionTile(
                    leading: Tooltip(
                        child: IconButton(
                            icon: Icon(Icons.edit), onPressed: () {}),
                        message: "Edit Kota"),
                    title: Text(kota2[index].kota),
                    children: <Widget>[
                      FittedBox(
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
                                    child: Text("Kecamatan",
                                        textAlign: TextAlign.center))),
                            DataColumn(
                                label: Expanded(
                                    child: Text("Action",
                                        textAlign: TextAlign.center))),
                          ],
                              rows: kota2[index]
                                  .kecamatan!
                                  .map<DataRow>((element) => DataRow(cells: [
                                        DataCell(Align(
                                            alignment: Alignment.center,
                                            child: Tooltip(
                                              child: TextButton(
                                                  onPressed: () {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                DaftarKelurahan(
                                                                  id: element[
                                                                      'id'],
                                                                  kecamatan:
                                                                      element[
                                                                          'kecamatan'],
                                                                )));
                                                  },
                                                  child: Text(element['id'],
                                                      textAlign:
                                                          TextAlign.center)),
                                              message: "Halaman Kecamatan",
                                            ))),
                                        DataCell(Align(
                                            alignment: Alignment.center,
                                            child: Text(element['kecamatan'],
                                                textAlign: TextAlign.center))),
                                        DataCell(Align(
                                            alignment: Alignment.center,
                                            child: Tooltip(
                                                child: IconButton(
                                                    icon: Icon(Icons.edit),
                                                    onPressed: () {}),
                                                message: "Edit Kecamatan")))
                                      ]))
                                  .toList())),
                      Tooltip(
                        message: "Tambah kecamatan",
                        child: IconButton(
                            onPressed: () {
                              showAddDialog(
                                  2, kota2[index].id, kota2[index].kota);
                            },
                            icon: const Icon(Icons.add)),
                      )
                    ]));
          });
    }
  }

  Widget kolomCari() {
    return SizedBox(
      height: 50,
      width: 175,
      child: TextFormField(
        decoration: const InputDecoration(
          icon: Icon(Icons.search),
          labelText: 'Cari Kota',
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

  Widget ComboProvinsi() {
    return SizedBox(
      height: 55,
      width: 175,
      child: DropdownSearch<dynamic>(
        dropdownSearchDecoration: InputDecoration(
          labelText: "Daftar Provinsi",
        ),
        mode: Mode.MENU,
        showSearchBox: true,
        onFind: (text) async {
          Map json;
          var response = await http.post(
              Uri.parse(
                  "http://192.168.137.1/magang/admin/provinsi/daftarprovinsi.php"),
              body: {'cari': text});

          if (response.statusCode == 200) {
            json = jsonDecode(response.body);
            setState(() {
              provinsi = json['data'];
            });
          }
          return provinsi as List<dynamic>;
        },
        onChanged: (value) {
          setState(() {
            id_provinsi = value['id'];
            controllerprovinsi = value['provinsi'];
          });
        },
        itemAsString: (item) => item['provinsi'],
      ),
    );
  }

  showAddDialog(type, id, kota) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: type == 1
                ? Text('Menambah kota pada provinsi ${controllerprovinsi}')
                : Text('Menambah kecamatan pada kota ${kota}'),
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
                            ? "Isikan Id Kota"
                            : "Isikan Id kecamatan"),
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
          appBar: AppBar(
            title: Text("Daftar Kota Outlet"),
          ),
          drawer: MyDrawer(),
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
                  width: 600,
                  child: Column(children: [
                    Padding(
                      padding: EdgeInsets.only(top:20),
                      child: Text(
                        "PILIH KOTA DAN KECAMATAN OUTLET",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                        margin: const EdgeInsets.all(10),
                        padding: EdgeInsets.all(10),
                        alignment: Alignment.topCenter,
                        height: 100,
                        width: 400,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [kolomCari(), ComboProvinsi()],
                        )),
                    Container(
                      alignment: Alignment.topCenter,
                      height: MediaQuery.of(context).size.height - 218,
                      width: 500,
                      child: FutureBuilder(
                          future: fetchData(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return daftarKota(snapshot.data.toString());
                            } else {
                              return Center(child: CircularProgressIndicator());
                            }
                          }),
                    )
                  ]))));
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
