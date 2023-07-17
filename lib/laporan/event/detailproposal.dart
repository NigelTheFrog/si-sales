import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:pt_coronet_crown/class/transaksi/eventherocyn.dart';
import 'package:measure_size/measure_size.dart';

class DetailProposal extends StatefulWidget {
  String event_id, nama_depan, nama_belakang, username;
  DetailProposal(
      {super.key,
      required this.event_id,
      required this.nama_depan,
      required this.nama_belakang,
      required this.username});
  @override
  _DetailProposalState createState() {
    return _DetailProposalState();
  }
}

class _DetailProposalState extends State<DetailProposal> {
  EventHerocyn? _event;

  Future<String> fetchData() async {
    final response = await http.post(
        Uri.parse("https://otccoronet.com/otc/laporan/event/detailevent.php"),
        body: {'id': widget.event_id});
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to read API');
    }
  }

  bacaData() {
    fetchData().then((value) {
      Map json = jsonDecode(value);
      _event = EventHerocyn.fromJson(json['data']);
      setState(() {});
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    bacaData();
  }

  Widget tabelPersonil() {
    return Column(children: [
      Text(
        "DAFTAR PERSONIL",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      Container(
        alignment: Alignment.topCenter,
        width: 500,
        child: ListView.builder(
            shrinkWrap: true,
            itemCount: 1,
            itemBuilder: (BuildContext ctxt, int index) {
              return DataTable(
                  columns: [
                    DataColumn(
                        label: Expanded(
                            child: Text(
                      "Username",
                      textAlign: TextAlign.center,
                    ))),
                    DataColumn(
                        label: Expanded(
                            child: Text("Nama", textAlign: TextAlign.center))),
                    DataColumn(
                        label: Expanded(
                            child:
                                Text("Jabatan", textAlign: TextAlign.center))),
                  ],
                  rows: _event!.personil!
                      .map<DataRow>((element) => DataRow(cells: [
                            DataCell(Align(
                                alignment: Alignment.center,
                                child: Text(element['account_username'],
                                    textAlign: TextAlign.center))),
                            DataCell(Align(
                                alignment: Alignment.center,
                                child: Text(
                                    "${element['nama_depan'].toString()} ${element['nama_belakang'].toString()}",
                                    textAlign: TextAlign.center))),
                            DataCell(Align(
                                alignment: Alignment.center,
                                child: Text(element['jabatan'],
                                    textAlign: TextAlign.center))),
                          ]))
                      .toList());
            }),
      )
    ]);
  }

  Widget tabelTarget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Target Kegiatan",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Container(
          padding: EdgeInsets.only(top: 10),
          alignment: Alignment.topCenter,
          child: ListView.builder(
              shrinkWrap: true,
              itemCount: 1,
              itemBuilder: (BuildContext ctxt, int index) {
                return FittedBox(
                    child: DataTable(
                        border: TableBorder.all(
                          width: 0.75,
                        ),
                        columns: [
                          DataColumn(
                              label: Expanded(
                                  child: Text("Parameter",
                                      textAlign: TextAlign.center))),
                          DataColumn(
                              label: Expanded(
                                  child: Text("Bobot",
                                      textAlign: TextAlign.center))),
                          DataColumn(
                              label: Expanded(
                                  child: Text("Target PAP",
                                      textAlign: TextAlign.center))),
                          DataColumn(
                              label: Expanded(
                                  child: Text("Bobot PAP",
                                      textAlign: TextAlign.center))),
                        ],
                        rows: _event!.target!
                            .map<DataRow>((element) => DataRow(cells: [
                                  DataCell(Container(
                                      width: 150,
                                      alignment: Alignment.center,
                                      child: Text(
                                          element['parameter']
                                                      .toString()
                                                      .contains("Pengguna") ||
                                                  element['parameter']
                                                      .toString()
                                                      .contains("Event")
                                              ? "${element['parameter']} (${element['perhitungan']}%)"
                                              : element['parameter']
                                                      .toString()
                                                      .contains("Estimasi")
                                                  ? "${element['parameter']} - ${element['perhitungan']} orang"
                                                  : element['parameter'],
                                          textAlign: TextAlign.center))),
                                  DataCell(Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                          element['bobot'] == null
                                              ? "-"
                                              : element['bobot'].toString(),
                                          textAlign: TextAlign.center))),
                                  DataCell(Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                          element['parameter']
                                                      .toString()
                                                      .contains("Rp") ||
                                                  element['parameter']
                                                      .toString()
                                                      .contains("Biaya")
                                              ? "Rp. ${NumberFormat('###,000').format(element['target_proposal'])}"
                                              : element['parameter']
                                                      .toString()
                                                      .contains("Ratio")
                                                  ? "${element['target_proposal']}%"
                                                  : element['target_proposal']
                                                      .toString(),
                                          textAlign: TextAlign.center))),
                                  DataCell(Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                          element['bobot'] == null
                                              ? "-"
                                              : ((element['target_proposal'] /
                                                          element[
                                                              'target_proposal']) *
                                                      element['bobot'])
                                                  .toString(),
                                          textAlign: TextAlign.center))),
                                ]))
                            .toList()));
              }),
        )
      ],
    );
  }

  Widget tabelKebutuhan() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Estimasi Biaya",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Container(
          padding: EdgeInsets.only(top: 10),
          alignment: Alignment.topCenter,
          child: ListView.builder(
              shrinkWrap: true,
              itemCount: 1,
              itemBuilder: (BuildContext ctxt, int index) {
                return DataTable(
                    border: TableBorder.all(
                      width: 0.75,
                    ),
                    columns: [
                      DataColumn(
                          label: Expanded(
                              child: Text("Komponen Biaya",
                                  textAlign: TextAlign.center))),
                      DataColumn(
                          label: Expanded(
                              child: Text("Estimasi",
                                  textAlign: TextAlign.center))),
                    ],
                    rows: _event!.kebutuhan!
                        .map<DataRow>((element) => DataRow(cells: [
                              DataCell(Container(
                                  width: 150,
                                  alignment: Alignment.center,
                                  child: Text(element['komponen'],
                                      textAlign: TextAlign.center))),
                              DataCell(Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                      "Rp. ${NumberFormat('###,000').format(element['estimasi'])}",
                                      textAlign: TextAlign.center))),
                            ]))
                        .toList());
              }),
        )
      ],
    );
  }

  Widget tabelGimmick() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Tambahan Gimmick",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Container(
          padding: EdgeInsets.only(top: 10),
          alignment: Alignment.topCenter,
          child: ListView.builder(
              shrinkWrap: true,
              itemCount: 1,
              itemBuilder: (BuildContext ctxt, int index) {
                return DataTable(
                    border: TableBorder.all(
                      width: 0.75,
                    ),
                    columns: [
                      DataColumn(
                          label: Expanded(
                              child: Text("Nama Barang",
                                  textAlign: TextAlign.center))),
                      DataColumn(
                          label: Expanded(
                              child:
                                  Text("Harga", textAlign: TextAlign.center))),
                      DataColumn(
                          label: Expanded(
                              child: Text("Estimasi Jumlah",
                                  textAlign: TextAlign.center))),
                    ],
                    rows: _event!.gimmick!
                        .map<DataRow>((element) => DataRow(cells: [
                              DataCell(Container(
                                  width: 150,
                                  alignment: Alignment.center,
                                  child: Text(element['barang'],
                                      textAlign: TextAlign.center))),
                              DataCell(Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                      "Rp. ${NumberFormat('###,000').format(element['harga'])}",
                                      textAlign: TextAlign.center))),
                              DataCell(Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                      element['quantity_proposal'].toString(),
                                      textAlign: TextAlign.center)))
                            ]))
                        .toList());
              }),
        )
      ],
    );
  }

  Widget lokasi() {
    return Column(children: [
      Text(
        "LOKASI",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      ListView.builder(
          shrinkWrap: true,
          itemCount: _event?.lokasi?.length,
          itemBuilder: (BuildContext ctxt, int index) {
            return RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 13.0,
                  color: Colors.black,
                ),
                children: <TextSpan>[
                  TextSpan(text: '\nKelurahan: '),
                  TextSpan(
                      text: _event!.lokasi![index]['kelurahan'],
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: ', Kecamatan: '),
                  TextSpan(
                      text: _event!.lokasi![index]['kecamatan'],
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: '\nKota: '),
                  TextSpan(
                      text: _event!.lokasi![index]['kota'],
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: ', Provinsi: '),
                  TextSpan(
                      text: _event!.lokasi![index]['provinsi'],
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: '\nAlamat: '),
                  TextSpan(
                      text: _event!.lokasi![index]['alamat'],
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            );
            //return RichText(
            //   "\nKelurahan: ${_event!.lokasi![index]['kelurahan']} \nKecamatan: ${_event!.lokasi![index]['kecamatan']} \nKota: ${_event!.lokasi![index]['kota']} \nProvinsi: ${_event!.lokasi![index]['provinsi']} \nAlamat: ${_event!.lokasi![index]['alamat']} \n");
          }),
    ]);
  }

  Widget latarBelakang() {
    return Column(children: [
      Text(
        "LATAR BELAKANG",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      Text(_event!.latar_belakang.toString(),
          style: TextStyle(
            height: 1.5,
          )),
    ]);
  }

  Widget strategi() {
    return Column(children: [
      Text("STRATEGI", style: TextStyle(fontWeight: FontWeight.bold)),
      Text(_event!.strategi.toString(),
          style: TextStyle(
            height: 1.5,
          )),
    ]);
  }

  Widget tujuan() {
    return Column(children: [
      Text("TUJUAN", style: TextStyle(fontWeight: FontWeight.bold)),
      Text(_event!.tujuan.toString(),
          style: TextStyle(
            height: 1.5,
          )),
    ]);
  }

  Widget tampilData(BuildContext context) {
    return SingleChildScrollView(
        child: Container(
      width: 1050,
      alignment: Alignment.topCenter,
      padding: EdgeInsets.only(top: 20, bottom: 20),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Align(
            alignment: Alignment.topLeft,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("ID Event: ${widget.event_id}",
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(
                      "Penanggung Jawab: ${widget.nama_depan} ${widget.nama_belakang}",
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
                ])),
        Container(
          alignment: Alignment.topLeft,
          padding: EdgeInsets.only(top: 20),
          child: Table(
            children: [
              TableRow(children: [
                Container(
                    width: 500,
                    padding: EdgeInsets.only(right: 5),
                    child: lokasi()),
                Container(
                    width: 500,
                    padding: EdgeInsets.only(left: 5),
                    child: tabelPersonil()),
              ])
            ],
          ),
        ),
        Container(
          alignment: Alignment.topLeft,
          padding: EdgeInsets.only(top: 20),
          child: Table(
            children: [
              TableRow(children: [
                Container(
                    width: 500,
                    padding: EdgeInsets.only(right: 5),
                    child: latarBelakang()),
                Container(
                    width: 500,
                    padding: EdgeInsets.only(left: 5),
                    child: tujuan()),
              ])
            ],
          ),
        ),
        Container(
          alignment: Alignment.topLeft,
          padding: EdgeInsets.only(top: 20),
          child: Table(
            children: [
              TableRow(children: [
                Container(
                    width: 500,
                    padding: EdgeInsets.only(right: 5),
                    child: strategi()),
                Container(
                    width: 500,
                    padding: EdgeInsets.only(left: 5),
                    child: tabelTarget()),
              ])
            ],
          ),
        ),
        Container(
          alignment: Alignment.topLeft,
          padding: EdgeInsets.only(top: 20),
          child: Table(
            children: [
              TableRow(children: [
                Container(
                    width: 500,
                    padding: EdgeInsets.only(right: 5),
                    child: tabelKebutuhan()),
                Container(
                    width: 500,
                    padding: EdgeInsets.only(left: 5),
                    child: tabelGimmick()),
              ])
            ],
          ),
        ),
      ]),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Detail PAP"),
        ),
        body: _event == null
            ? Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                alignment: Alignment.center,
                child: const CircularProgressIndicator(),
              )
            : Container(
                padding: EdgeInsets.only(top: 20),
                // height: MediaQuery.of(context).size.height,
                // width: MediaQuery.of(context).size.width,
                alignment: Alignment.topCenter,
                child: tampilData(context)));

    //ListView(children: [tampilData()])));
  }
}
