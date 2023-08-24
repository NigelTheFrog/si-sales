import 'dart:convert';
import 'package:pt_coronet_crown/class/transaksi/eventherocyn.dart';
import 'package:pt_coronet_crown/laporan/event/buatlaporan.dart';
import 'package:pt_coronet_crown/laporan/event/detailevent.dart';
import 'package:pt_coronet_crown/laporan/event/detailproposal.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pt_coronet_crown/drawer.dart';
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

class DaftarEvent extends StatefulWidget {
  DaftarEvent({Key? key}) : super(key: key);
  @override
  _DaftarEventState createState() {
    return _DaftarEventState();
  }
}

class _DaftarEventState extends State<DaftarEvent> {
  String _txtcari = "";
  TextEditingController _startDateController = TextEditingController();
  TextEditingController _endDateController = TextEditingController();

  _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString("username") ?? '';
      id_jabatan = prefs.getString("idjabatan") ?? '';
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
        Uri.parse("https://otccoronet.com/otc/laporan/event/daftarevent.php"),
        body: {'startdate': startdate, 'enddate': enddate, 'cari': _txtcari});
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to read API');
    }
  }

  Widget daftarEvent(data, context) {
    List<EventHerocyn> event2 = [];
    Map json = jsonDecode(data);
    if (json['result'] == "error") {
      return SingleChildScrollView(
          scrollDirection: MediaQuery.of(context).size.width >= 1125
              ? Axis.vertical
              : Axis.horizontal,
          child: Container(
              alignment: Alignment.center,
              child: DataTable(columns: [
                DataColumn(
                    label: Expanded(
                        child: Text("ID Event", textAlign: TextAlign.center))),
                DataColumn(
                    label: Expanded(
                        child:
                            Text("Nama Event", textAlign: TextAlign.center))),
                DataColumn(
                    label: Expanded(
                        child: Text("Lokasi", textAlign: TextAlign.center))),
                DataColumn(
                    label: Expanded(
                        child: Text("Tanggal \nEvent",
                            textAlign: TextAlign.center))),
                DataColumn(
                    label: Expanded(
                        child: Text("Penanggung \nJawab",
                            textAlign: TextAlign.center))),
                DataColumn(
                    label: Expanded(
                        child: Text("Status \nEvent",
                            textAlign: TextAlign.center))),
                DataColumn(
                    label: Expanded(
                        child: Text("Status \nLaporan",
                            textAlign: TextAlign.center))),
              ], rows: [])));
    } else {
      for (var ev in json['data']) {
        EventHerocyn event = EventHerocyn.fromJson(ev);
        event2.add(event);
      }
      return ListView.builder(
          scrollDirection: MediaQuery.of(context).size.width >= 1125
              ? Axis.vertical
              : Axis.horizontal,
          itemCount: 1,
          itemBuilder: (BuildContext ctxt, int index) {
            return DataTable(
                dataRowHeight: 100,
                columns: [
                  DataColumn(
                      label: Expanded(
                          child:
                              Text("ID Event", textAlign: TextAlign.center))),
                  DataColumn(
                      label: Expanded(
                          child:
                              Text("Nama Event", textAlign: TextAlign.center))),
                  DataColumn(
                      label: Expanded(
                          child: Text("Lokasi", textAlign: TextAlign.center))),
                  DataColumn(
                      label: Expanded(
                          child: Text("Tanggal \nEvent",
                              textAlign: TextAlign.center))),
                  DataColumn(
                      label: Expanded(
                          child: Text("Penanggung \nJawab",
                              textAlign: TextAlign.center))),
                  DataColumn(
                      label: Expanded(
                          child: Text("Status \nEvent",
                              textAlign: TextAlign.center))),
                  DataColumn(
                      label: Expanded(
                          child: Text("Status \nLaporan",
                              textAlign: TextAlign.center))),
                ],
                rows: event2
                    .map<DataRow>((element) => DataRow(cells: [
                          DataCell(Align(
                              alignment: Alignment.center,
                              child: Tooltip(
                                  message: "Halaman Detail Event",
                                  child: TextButton(
                                    style: TextButton.styleFrom(
                                      textStyle: const TextStyle(
                                          fontWeight: FontWeight.normal),
                                    ),
                                    onPressed: () {
                                      if (element.status == 0 ||
                                          element.status == 1) {
                                        showDialog<String>(
                                            context: context,
                                            builder: (BuildContext context) =>
                                                AlertDialog(
                                                    title: const Text(
                                                        'Peringatan'),
                                                    content: Container(
                                                        height: 100,
                                                        width: 300,
                                                        child: Text(
                                                            "Event masih belum terselesaikan"))));
                                      } else if (element.status == 2) {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    BuatLaporanEvent(
                                                      event_id: element.id,
                                                      penanggung_jawab: element
                                                          .penanggung_jawab
                                                          .toString(),
                                                    )));
                                      } else {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    DetailEvent(
                                                      event_id: element.id,
                                                      penanggung_jawab: element
                                                          .penanggung_jawab
                                                          .toString(),
                                                    )));
                                      }
                                    },
                                    child: Text(element.id,
                                        textAlign: TextAlign.center),
                                  )))),
                          DataCell(Align(
                              alignment: Alignment.center,
                              child: Text(element.nama,
                                  textAlign: TextAlign.center))),
                          DataCell(Align(
                              alignment: Alignment.center,
                              child: SizedBox(
                                  width: 170,
                                  child: Text(element.alamat.toString(),
                                      textAlign: TextAlign.center)))),
                          DataCell(Container(
                              alignment: Alignment.center,
                              width: 110,
                              child: Text(element.tanggal,
                                  textAlign: TextAlign.center))),
                          DataCell(Container(
                              alignment: Alignment.center,
                              width: 150,
                              child: Text(element.penanggung_jawab.toString(),
                                  textAlign: TextAlign.center))),
                          DataCell(Align(
                              alignment: Alignment.center,
                              child: SizedBox(
                                  width: 110,
                                  child: Text(
                                      element.status == 0
                                          ? "Event belum dijalankan"
                                          : element.status == 1
                                              ? "Event sedang berlangsung"
                                              : element.status == 2
                                                  ? "Event telah selesai"
                                                  : "Laporan dalam tahap pengecekan",
                                      textAlign: TextAlign.center)))),
                          DataCell(Container(
                            alignment: Alignment.center,
                            width: 100,
                            height: 100,
                            child: element.status == 3
                                ? ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: element.persetujuan?.length,
                                    itemBuilder:
                                        (BuildContext ctxt, int index) {
                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                              "${element.persetujuan![index]['jabatan']} "),
                                          Tooltip(
                                              message: element.persetujuan![index]
                                                          ['status_laporan'] ==
                                                      1
                                                  ? "Laporan sedang diproses, harap cek berkala"
                                                  : element.persetujuan![index][
                                                              'status_laporan'] ==
                                                          2
                                                      ? "Laporan sudah disetujui oleh ${element.persetujuan![index]['jabatan']}"
                                                      : "Proposal ditolak, silahkan tekan tombol X untuk melihat keterangan",
                                              child: element.persetujuan![index]
                                                          ['status_laporan'] ==
                                                      1
                                                  ? Icon(Icons.info_outline,
                                                      color: Colors.yellow)
                                                  : element.persetujuan![index][
                                                              'status_laporan'] ==
                                                          2
                                                      ? Icon(
                                                          Icons.check,
                                                          color: Colors.green,
                                                        )
                                                      : Icon(Icons.close,
                                                          color: Colors.red))
                                        ],
                                      );
                                    })
                                : Text("-"),
                          )),
                        ]))
                    .toList());
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
                                onPressed: () {
                                  Navigator.popAndPushNamed(
                                      context, "/ajukanproposal");
                                },
                                child: Text(
                                  "Ajukan Proposal",
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 16),
                                )),
                            Container(
                              height: 50,
                              width: 175,
                              child: TextFormField(
                                decoration: const InputDecoration(
                                  icon: Icon(Icons.search),
                                  labelText: 'Cari Event',
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
              "Pilih rentang tanggal event untuk melakukan filtering data",
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
                        return daftarEvent(snapshot.data.toString(), context);
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
            title: Text("Daftar Event"),
          ),
          drawer: MyDrawer(),
          body: buildContainer(context));
    } else {
      return Scaffold(
          appBar: AppBar(
            title: Text("Daftar Event"),
          ),
          body: buildContainer(context));
    }
  }
}
