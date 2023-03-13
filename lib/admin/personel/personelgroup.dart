import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pt_coronet_crown/class/personel/personelgrup.dart';
import 'package:pt_coronet_crown/drawer.dart';

import '../../main.dart';

class PersonelGroup extends StatefulWidget {
  PersonelGroup({Key? key}) : super(key: key);
  @override
  _PersonelGroupState createState() {
    return _PersonelGroupState();
  }
}

class _PersonelGroupState extends State<PersonelGroup> {
  String _txtcari = "";

  Future<String> fetchData() async {
    final response = await http.post(Uri.parse(
        "http://localhost/magang/admin/personel/personelgroup/daftarpersonelgroup.php"));
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to read API');
    }
  }

  Widget daftargrup(data) {
    List<Grup> grup2 = [];
    Map json = jsonDecode(data);
    if (json['result'] == "error") {
      return Container(
          child: DataTable(columns: [
        DataColumn(label: Text("Nama")),
        DataColumn(label: Text("Admin")),
        DataColumn(label: Text("Total pegawai")),
        DataColumn(label: Text("Cabang")),
        DataColumn(label: Text("Action")),
      ], rows: []));
    } else {
      for (var gru in json['data']) {
        Grup grup = Grup.fromJson(gru);
        grup2.add(grup);
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
                    "Nama",
                    textAlign: TextAlign.center,
                  ))),
                  DataColumn(
                      label: Expanded(
                          child: Text("Leader", textAlign: TextAlign.center))),
                  DataColumn(
                      label: Expanded(
                          child: Text("Jumlah \nPegawai",
                              textAlign: TextAlign.center))),
                  DataColumn(
                      label: Expanded(
                          child: Text("Cabang", textAlign: TextAlign.center))),
                  DataColumn(
                      label: Expanded(
                          child: Text("Action", textAlign: TextAlign.center))),
                ],
                    rows: grup2
                        .map<DataRow>((element) => DataRow(cells: [
                              DataCell(Align(
                                  alignment: Alignment.center,
                                  child: Text(element.nama_grup,
                                      textAlign: TextAlign.center))),
                              DataCell(Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                      "${element.nama_depan} ${element.nama_belakang}",
                                      textAlign: TextAlign.center))),
                              DataCell(Align(
                                  alignment: Alignment.center,
                                  child: Text(element.jumlah_pegawai.toString(),
                                      textAlign: TextAlign.center))),
                              DataCell(Align(
                                  alignment: Alignment.center,
                                  child: Text(element.nama_cabang,
                                      textAlign: TextAlign.center))),
                              DataCell(
                                Align(
                                    alignment: Alignment.center,
                                    child: Container(
                                        child: Row(
                                      children: [
                                        Tooltip(
                                          message: 'Assign Personnel',
                                          child: IconButton(
                                            icon: Icon(Icons.person_add),
                                            onPressed: () {},
                                          ),
                                        ),
                                        Tooltip(
                                          message: 'Edit group',
                                          child: IconButton(
                                            icon: Icon(Icons.edit),
                                            onPressed: () {},
                                          ),
                                        ),
                                        Tooltip(
                                          message: 'Delete group',
                                          child: IconButton(
                                            icon: Icon(Icons.delete),
                                            onPressed: () {},
                                          ),
                                        ),
                                      ],
                                    ))),
                              )
                            ]))
                        .toList()));
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Personnel Group"),
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
                            onPressed: () {
                              Navigator.popAndPushNamed(context, "tambahgrup");
                            },
                            child: Text(
                              "Add New Group",
                              style:
                                  TextStyle(color: Colors.black, fontSize: 16),
                            )),
                        Container(
                          height: 50,
                          width: 175,
                          child: TextFormField(
                            decoration: const InputDecoration(
                              icon: Icon(Icons.search),
                              labelText: 'Cari Group',
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
