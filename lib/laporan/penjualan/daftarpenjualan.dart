import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pt_coronet_crown/class/transaksi/penjualan.dart';
import 'package:pt_coronet_crown/drawer.dart';
import 'package:pt_coronet_crown/laporan/penjualan/detailpenjualan.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../main.dart';

String nama_depan = "",
    nama_belakang = "",
    username = "",
    id_jabatan = "",
    startdate = "",
    enddate = "";

class DaftarPenjualan extends StatefulWidget {
  DaftarPenjualan({Key? key}) : super(key: key);
  @override
  _DaftarPenjualanState createState() {
    return _DaftarPenjualanState();
  }
}

class _DaftarPenjualanState extends State<DaftarPenjualan> {
  String _txtcari = "";
  TextEditingController _startDateController = TextEditingController();
  TextEditingController _endDateController = TextEditingController();

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
    initializeDateFormatting();
    _startDateController.text =
        DateFormat.yMMMMEEEEd('id').format(DateTime.now());
    startdate = DateTime.now().toString().substring(0, 10);
    enddate = DateTime.now().toString().substring(0, 10);
    _endDateController.text =
        DateFormat.yMMMMEEEEd('id').format(DateTime.now());
  }

  Future<String> fetchData() async {
    final response = await http.post(
        Uri.parse(
            "http://localhost/magang/laporan/penjualan/daftarpenjualan.php"),
        body: {'startdate': startdate, 'enddate': enddate, 'cari': _txtcari});
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to read API');
    }
  }

  Widget daftarpenjualan(data, context) {
    List<Penjualan> penjualan2 = [];
    Map json = jsonDecode(data);
    if (json['result'] == "error") {
      return SingleChildScrollView(
          scrollDirection: MediaQuery.of(context).size.width >= 725
              ? Axis.vertical
              : Axis.horizontal,
          child: Container(
              child: DataTable(columns: [
            DataColumn(
                label: Expanded(
                    child: Text(
              "ID Laporan",
              textAlign: TextAlign.center,
            ))),
            DataColumn(
                label: Expanded(
                    child: Text("Penjual", textAlign: TextAlign.center))),
            DataColumn(
                label: Expanded(
                    child: Text("Tanggal", textAlign: TextAlign.center))),
            DataColumn(
                label: Expanded(
                    child: Text("Waktu", textAlign: TextAlign.center))),
            DataColumn(
                label: Expanded(
                    child: Text("Jumlah barang", textAlign: TextAlign.center))),
            DataColumn(
                label: Expanded(
                    child:
                        Text("Total Penjualan", textAlign: TextAlign.center))),
          ], rows: [])));
    } else {
      for (var pen in json['data']) {
        Penjualan penjualan = Penjualan.fromJson(pen);
        penjualan2.add(penjualan);
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
                          child: Text("Penjual", textAlign: TextAlign.center))),
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
                    rows: penjualan2
                        .map<DataRow>((element) => DataRow(cells: [
                              DataCell(Align(
                                  alignment: Alignment.center,
                                  child: element.foto == null
                                      ? Tooltip(
                                          message: "Halaman Detail",
                                          child: TextButton(
                                            style: TextButton.styleFrom(
                                              textStyle: const TextStyle(
                                                  fontWeight:
                                                      FontWeight.normal),
                                            ),
                                            onPressed: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          DetailPenjualan(
                                                            laporan_id:
                                                                element.id,
                                                          )));
                                            },
                                            child: Text(element.id,
                                                textAlign: TextAlign.center),
                                          ))
                                      : Tooltip(
                                          message: "Foto Nota",
                                          child: TextButton(
                                            style: TextButton.styleFrom(
                                              textStyle: const TextStyle(
                                                  fontWeight:
                                                      FontWeight.normal),
                                            ),
                                            onPressed: () {
                                              showDialog(
                                                  context: context,
                                                  builder: (context) => AlertDialog(
                                                      content: Container(
                                                          width: 500,
                                                          height: 500,
                                                          child: Tooltip(
                                                              message: "Halaman Detail Penjualan",
                                                              child: GestureDetector(
                                                                  onTap: () {
                                                                    Navigator.push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                            builder: (context) => DetailPenjualan(
                                                                                  laporan_id: element.id,
                                                                                )));
                                                                  },
                                                                  child: Image.memory(base64Decode(element.foto as String)))))));
                                            },
                                            child: Text(element.id,
                                                textAlign: TextAlign.center),
                                          )))),
                              DataCell(Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                      "${element.nama_depan} ${element.nama_belakang}",
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
                                  child: Text(element.jumlah_barang,
                                      textAlign: TextAlign.center))),
                              DataCell(Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                      "Rp. ${NumberFormat('###,000').format((element.total_penjualan - element.diskon) + (((element.total_penjualan - element.diskon) * (element.ppn / 100.00))))}",
                                      textAlign: TextAlign.center))),
                            ]))
                        .toList()));
          });
    }
  }

  Widget buildContainer(BuildContext context) {
    return Container(
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
                child: MediaQuery.of(context).size.width > 390
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Color.fromARGB(255, 248, 172, 49)),
                                onPressed: () {},
                                child: Text(
                                  "Tambah Penjualan",
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 16),
                                )),
                            Container(
                              height: 50,
                              width: 175,
                              child: TextFormField(
                                decoration: const InputDecoration(
                                  icon: Icon(Icons.search),
                                  labelText: 'Cari Laporan',
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _txtcari = value;
                                  });
                                  // bacaData();
                                },
                              ),
                            )
                          ])
                    : Column(
                        children: <Widget>[
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Color.fromARGB(255, 248, 172, 49)),
                              onPressed: () {},
                              child: Text(
                                "Tambah Penjualan",
                                style: TextStyle(
                                    color: Colors.black, fontSize: 16),
                              )),
                          Container(
                            height: 50,
                            width: 175,
                            child: TextFormField(
                              decoration: const InputDecoration(
                                icon: Icon(Icons.search),
                                labelText: 'Cari Laporan',
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _txtcari = value;
                                });
                              },
                            ),
                          )
                        ],
                      )),
            Text(
              "Pilih tanggal untuk melakukan filtering data",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Container(
                margin: const EdgeInsets.all(10),
                padding: EdgeInsets.all(10),
                alignment: Alignment.topCenter,
                width: 700,
                child: MediaQuery.of(context).size.width >= 650
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            height: 50,
                            width: 300,
                            child: Row(children: [
                              Expanded(
                                  child: TextFormField(
                                decoration: InputDecoration(
                                  labelText: "Start Date",
                                ),
                                controller: _startDateController,
                              )),
                              ElevatedButton(
                                  onPressed: () {
                                    showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime(2000),
                                            lastDate: DateTime(2200))
                                        .then((value) {
                                      setState(() {
                                        startdate =
                                            value.toString().substring(0, 10);
                                        String formattedDate =
                                            DateFormat.yMMMMEEEEd('id')
                                                .format(value!);
                                        _startDateController.text =
                                            formattedDate;
                                      });
                                    });
                                  },
                                  child: Icon(
                                    Icons.calendar_today_sharp,
                                    color: Colors.white,
                                    size: 24.0,
                                  ))
                            ]),
                          ),
                          Container(
                            height: 50,
                            width: 300,
                            child: Row(children: [
                              Expanded(
                                  child: TextFormField(
                                decoration: InputDecoration(
                                  labelText: "End Date",
                                ),
                                controller: _endDateController,
                              )),
                              ElevatedButton(
                                  onPressed: () {
                                    showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime(2000),
                                            lastDate: DateTime(2200))
                                        .then((value) {
                                      setState(() {
                                        enddate =
                                            value.toString().substring(0, 10);
                                        String formattedDate =
                                            DateFormat.yMMMMEEEEd('id')
                                                .format(value!);
                                        _endDateController.text = formattedDate;
                                      });
                                    });
                                  },
                                  child: Icon(
                                    Icons.calendar_today_sharp,
                                    color: Colors.white,
                                    size: 24.0,
                                  ))
                            ]),
                          ),
                        ],
                      )
                    : Column(
                        children: <Widget>[
                          Container(
                            height: 50,
                            width: 300,
                            child: Row(children: [
                              Expanded(
                                  child: TextFormField(
                                decoration: InputDecoration(
                                  labelText: "Start Date",
                                ),
                                controller: _startDateController,
                              )),
                              ElevatedButton(
                                  onPressed: () {
                                    showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime(2000),
                                            lastDate: DateTime(2200))
                                        .then((value) {
                                      setState(() {
                                        startdate =
                                            value.toString().substring(0, 10);
                                        String formattedDate =
                                            DateFormat.yMMMMEEEEd('id')
                                                .format(value!);
                                        _startDateController.text =
                                            formattedDate;
                                      });
                                    });
                                  },
                                  child: Icon(
                                    Icons.calendar_today_sharp,
                                    color: Colors.white,
                                    size: 24.0,
                                  ))
                            ]),
                          ),
                          Container(
                            height: 50,
                            width: 300,
                            child: Row(children: [
                              Expanded(
                                  child: TextFormField(
                                decoration: InputDecoration(
                                  labelText: "End Date",
                                ),
                                controller: _endDateController,
                              )),
                              ElevatedButton(
                                  onPressed: () {
                                    showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime(2000),
                                            lastDate: DateTime(2200))
                                        .then((value) {
                                      setState(() {
                                        enddate =
                                            value.toString().substring(0, 10);
                                        String formattedDate =
                                            DateFormat.yMMMMEEEEd('id')
                                                .format(value!);
                                        _endDateController.text = formattedDate;
                                      });
                                    });
                                  },
                                  child: Icon(
                                    Icons.calendar_today_sharp,
                                    color: Colors.white,
                                    size: 24.0,
                                  ))
                            ]),
                          ),
                        ],
                      )),
            Container(
                alignment: Alignment.topCenter,
                height: MediaQuery.of(context).size.height,
                child: FutureBuilder(
                    future: fetchData(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return daftarpenjualan(
                            snapshot.data.toString(), context);
                      } else {
                        return Center(child: CircularProgressIndicator());
                      }
                    }))
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (idjabatan == "1" || idjabatan == "2") {
      return Scaffold(
          appBar: AppBar(
            title: Text("Daftar Penjualan"),
          ),
          drawer: MyDrawer(),
          body: buildContainer(context));
    } else {
      return Scaffold(
          appBar: AppBar(
            title: Text("Daftar Penjualan"),
          ),
          body: buildContainer(context));
    }
  }
}
