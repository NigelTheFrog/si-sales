import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pt_coronet_crown/class/admin/absen/kunjungan.dart';
import 'package:pt_coronet_crown/class/transaksi/penjualan.dart';
import 'package:pt_coronet_crown/drawer.dart';
import 'package:pt_coronet_crown/laporan/penjualan/detailpenjualan.dart';
import 'package:pt_coronet_crown/mainpage/kunjungan/detailkunjungan.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../../main.dart';

String nama_depan = "",
    nama_belakang = "",
    username = "",
    id_jabatan = "",
    startdate = "",
    enddate = "",
    id_cabang = "",
    id_grup = "";

class DailyVisit extends StatefulWidget {
  DailyVisit({Key? key}) : super(key: key);
  @override
  _DailyVisitState createState() {
    return _DailyVisitState();
  }
}

class _DailyVisitState extends State<DailyVisit> {
  String _txtcari = "";

  TextEditingController _startDateController = TextEditingController();
  TextEditingController _endDateController = TextEditingController();

  late Timer timer;

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
        Uri.parse("http://192.168.137.1/magang/absensi/visit/historyvisit.php"),
        body: {
          'startdate': startdate,
          'enddate': enddate,
          'cari': _txtcari,
          'idjabatan': id_jabatan,
        });
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to read API');
    }
  }

  Widget kolomCari() {
    return SizedBox(
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
    );
  }

  Widget tanggalSelesai(BuildContext context) {
    return SizedBox(
      height: 60,
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
                  enddate = value.toString().substring(0, 10);
                  String formattedDate =
                      DateFormat.yMMMMEEEEd('id').format(value!);
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
    );
  }

  Widget tanggalMulai(BuildContext context) {
    return SizedBox(
      height: 60,
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
                  startdate = value.toString().substring(0, 10);
                  String formattedDate =
                      DateFormat.yMMMMEEEEd('id').format(value!);
                  _startDateController.text = formattedDate;
                });
              });
            },
            child: Icon(
              Icons.calendar_today_sharp,
              color: Colors.white,
              size: 24.0,
            ))
      ]),
    );
  }

  Widget daftarVisit(data, context) {
    List<Kunjungan> kunjungan2 = [];
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
                    child: Text("ID Kunjungan", textAlign: TextAlign.center))),
            DataColumn(
                label: Expanded(
                    child: Text("Personil", textAlign: TextAlign.center))),
            DataColumn(
                label: Expanded(
                    child: Text("Tanggal", textAlign: TextAlign.center))),
            DataColumn(
                label: Expanded(
                    child: Text("Outlet", textAlign: TextAlign.center))),
            DataColumn(
                label: Expanded(
                    child: Text("Check in", textAlign: TextAlign.center))),
            DataColumn(
                label: Expanded(
                    child: Text("Check out", textAlign: TextAlign.center))),
            DataColumn(
                label: Expanded(
                    child: Text("Status", textAlign: TextAlign.center))),
          ], rows: [])));
    } else {
      for (var vis in json['data']) {
        Kunjungan kunjungan = Kunjungan.fromJson(vis);
        kunjungan2.add(kunjungan);
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
                          child: Text("ID Kunjungan",
                              textAlign: TextAlign.center))),
                  DataColumn(
                      label: Expanded(
                          child:
                              Text("Personil", textAlign: TextAlign.center))),
                  DataColumn(
                      label: Expanded(
                          child: Text("Tanggal", textAlign: TextAlign.center))),
                  DataColumn(
                      label: Expanded(
                          child: Text("Outlet", textAlign: TextAlign.center))),
                  DataColumn(
                      label: Expanded(
                          child:
                              Text("Check in", textAlign: TextAlign.center))),
                  DataColumn(
                      label: Expanded(
                          child:
                              Text("Check out", textAlign: TextAlign.center))),
                  DataColumn(
                      label: Expanded(
                          child: Text("Status", textAlign: TextAlign.center))),
                ],
                    rows: kunjungan2
                        .map<DataRow>((element) => DataRow(cells: [
                              DataCell(Align(
                                  alignment: Alignment.center,
                                  child: Tooltip(
                                      message: "Halaman Detail",
                                      child: TextButton(
                                        style: TextButton.styleFrom(
                                          textStyle: const TextStyle(
                                              fontWeight: FontWeight.normal),
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      DetailVisit(
                                                        id_visit: element.id,
                                                        type: 3,
                                                      )));
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
                                  child: Text(element.nama_toko,
                                      textAlign: TextAlign.center))),
                              DataCell(Align(
                                  alignment: Alignment.center,
                                  child: Text(element.waktu_in,
                                      textAlign: TextAlign.center))),
                              DataCell(Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                      element.status == 1
                                          ? element.waktu_out.toString()
                                          : "Belum check out",
                                      textAlign: TextAlign.center))),
                              DataCell(Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                      element.status == 1
                                          ? "Sudah check out"
                                          : "Belum check out",
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
                        mainAxisAlignment:
                            id_jabatan == "1" || id_jabatan == "2"
                                ? MainAxisAlignment.spaceBetween
                                : MainAxisAlignment.center,
                        children: <Widget>[kolomCari()])
                    : Column(
                        mainAxisAlignment:
                            id_jabatan == "1" || id_jabatan == "2"
                                ? MainAxisAlignment.spaceBetween
                                : MainAxisAlignment.center,
                        children: <Widget>[kolomCari()],
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
                          tanggalMulai(context),
                          tanggalSelesai(context)
                        ],
                      )
                    : Column(
                        children: <Widget>[
                          tanggalMulai(context),
                          tanggalSelesai(context)
                        ],
                      )),
            Container(
                alignment: Alignment.topCenter,
                height: MediaQuery.of(context).size.height,
                child: FutureBuilder(
                    future: fetchData(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return daftarVisit(snapshot.data.toString(), context);
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
    if (idjabatan != "3") {
      if (idjabatan == "1" || idjabatan == "2") {
        return Scaffold(
            appBar: AppBar(
              title: Text("Daftar Kunjungan"),
            ),
            drawer: MyDrawer(),
            body: buildContainer(context));
      } else {
        return Scaffold(
            appBar: AppBar(
              leading: BackButton(
                onPressed: () {
                  Navigator.popAndPushNamed(context, "homepage");
                },
              ),
              title: Text("Daftar Kunjungan"),
            ),
            body: buildContainer(context));
      }
    } else {
      return Scaffold(
          appBar: AppBar(
            title: Text("Daftar Kunjungan"),
          ),
          body: Center(
            child: Text(
              "Anda tidak memiliki akses ke halaman ini \nSilahkan kontak admin",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ));
    }
  }
}
