import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pt_coronet_crown/class/transaksi/pembelian.dart';
import 'package:pt_coronet_crown/drawer.dart';
import 'package:pt_coronet_crown/mainpage/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../main.dart';

String nama_depan = "", nama_belakang = "", username = "", id_jabatan = "";

class DaftarPembelian extends StatefulWidget {
  DaftarPembelian({Key? key}) : super(key: key);
  @override
  _DaftarPembelianState createState() {
    return _DaftarPembelianState();
  }
}

class _DaftarPembelianState extends State<DaftarPembelian> {
  String _txtcari = "";

  _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString("username") ?? '';
      id_jabatan = prefs.getString("idjabatan") ?? '';
      nama_depan = prefs.getString("nama_depan") ?? '';
      nama_belakang = prefs.getString("nama_belakang") ?? '';
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadData();
  }

  Future<String> fetchData() async {
    final response = await http.post(Uri.parse(
        "http://localhost/magang/admin/personel/personelgroup/daftarpersonelgroup.php"), body: {
          'id_jabatan':id_jabatan
        });
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to read API');
    }
  }

  Widget daftargrup(data) {
    List<Pembelian> pembelian2 = [];
    Map json = jsonDecode(data);
    if (json['result'] == "error") {
      return Container(
          child:  DataTable(columns: [
                  DataColumn(label: Text("ID Laporan")),
                  DataColumn(label: Text("Tanggal")),
                  DataColumn(label: Text("Waktu")),
                  DataColumn(label: Text("Jumlah barang")),
                  DataColumn(label: Text("Total Pembelian")),
                ], rows: []));
    } else {
      for (var pem in json['data']) {
        Pembelian pembelian = Pembelian.fromJson(pem);
        pembelian2.add(pembelian);
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
                    "ID Laporan",
                    textAlign: TextAlign.center,
                  ))),
                  DataColumn(
                      label: Expanded(
                          child: Text("Tanggal", textAlign: TextAlign.center))),
                  DataColumn(
                      label: Expanded(
                          child: Text("Waktu", textAlign: TextAlign.center))),
                  DataColumn(
                      label: Expanded(
                          child: Text("Jumlah barang",
                              textAlign: TextAlign.center))),
                  DataColumn(
                      label: Expanded(
                          child: Text("Total Penjualan",
                              textAlign: TextAlign.center))),
                ],
                    rows: pembelian2
                        .map<DataRow>((element) => DataRow(cells: [
                              DataCell(Align(
                                  alignment: Alignment.center,
                                  child: Text(element.id,
                                      textAlign: TextAlign.center))),
                              DataCell(Align(
                                  alignment: Alignment.center,
                                  child: Text(element.tanggal,
                                      textAlign: TextAlign.center))),
                              DataCell(Align(
                                  alignment: Alignment.center,
                                  child: Text(element.waktu,
                                      textAlign: TextAlign.center))),
                              DataCell(Align(
                                  alignment: Alignment.center,
                                  child: Text(element.jumlah_barang.toString(),
                                      textAlign: TextAlign.center))),
                              DataCell(Align(
                                  alignment: Alignment.center,
                                  child: Text(element.total_pembelian.toString(),
                                      textAlign: TextAlign.center))),
                            ]))
                        .toList()));
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Daftar Pembelian"),
        ),
        drawer: MyDrawer(),
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
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Color.fromARGB(255, 248, 172, 49)),
                            onPressed: () {},
                            child: Text(
                              "Tambah Pembelian",
                              style:
                                  TextStyle(color: Colors.black, fontSize: 16),
                            )),
                        Container(
                          height: 50,
                          width: 175,
                          child: TextFormField(
                            decoration: const InputDecoration(
                              icon: Icon(Icons.search),
                              labelText: 'Cari Nota',
                            ),
                            onChanged: (value) {
                              _txtcari = value;
                              // bacaData();
                            },
                          ),
                        )
                      ]),
                ),
                Container(
                    alignment: Alignment.topCenter,
                    height: MediaQuery.of(context).size.height,
                    width: 800,
                    child: FutureBuilder(
                        future: fetchData(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return daftargrup(snapshot.data.toString());
                          } else {
                            return Center(child: CircularProgressIndicator());
                          }
                        }))
              ],
            ),
          ),
        ));
  }
}
