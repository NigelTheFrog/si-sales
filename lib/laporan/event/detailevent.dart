import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:pt_coronet_crown/class/transaksi/eventherocyn.dart';
import 'package:measure_size/measure_size.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailEvent extends StatefulWidget {
  String event_id, penanggung_jawab;
  DetailEvent({
    super.key,
    required this.event_id,
    required this.penanggung_jawab,
  });
  @override
  _DetailEventState createState() {
    return _DetailEventState();
  }
}

class _DetailEventState extends State<DetailEvent> {
  String username = "", keterangan = "";
  bool status_alasan = false;
  EventHerocyn? _event;

  Future<String> fetchData() async {
    final response = await http.post(
        Uri.parse(
            "https://otccoronet.com/otc/laporan/event/detailevent.php"),
        body: {'id': widget.event_id});
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to read API');
    }
  }

  void persetujuan(BuildContext context, type, value) async {
    final response = await http.post(
        Uri.parse(
            "https://otccoronet.com/otc/laporan/event/persetujuanevent.php"),
        body: {
          'id': widget.event_id,
          'username': username,
          'type': type,
          'value': value,
          'keterangan': keterangan
        });
    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      if (json['result'] == 'success') {
        if (!mounted) return;
      }
    } else {
      throw Exception('Failed to read API');
    }
  }

  _loadDataJabatan() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString("username") ?? '';
    });
  }

  bacaData() {
    fetchData().then((value) {
      Map json = jsonDecode(value);
      _event = EventHerocyn.fromJson(json['data']);
      setState(() {
        for (var stat in _event!.persetujuan!) {
          if (stat['status_proposal'] == 0) {
            status_alasan = true;
            break;
          }
        }
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    _loadDataJabatan();
    bacaData();
    super.initState();
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
                                child: Text(element['username'],
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
                if (_event!.kebutuhan != null) {
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
                } else {
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
                      rows: []);
                }
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
                              child: Text("Estimasi\nJumlah",
                                  textAlign: TextAlign.center))),
                      DataColumn(
                          label: Expanded(
                              child: Text("Total\nBiaya",
                                  textAlign: TextAlign.center))),
                    ],
                    rows: _event!.gimmick!
                        .map<DataRow>((element) => DataRow(cells: [
                              DataCell(Container(
                                  width: 100,
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
                                      textAlign: TextAlign.center))),
                              DataCell(Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                      "Rp. ${NumberFormat('###,000').format(element['total_biaya'])}",
                                      textAlign: TextAlign.center)))
                            ]))
                        .toList());
              }),
        )
      ],
    );
  }

  Widget alasan() {
    if (status_alasan == true) {
      return Tooltip(
          message: "Lihat alasan / keterangan penolakan",
          child: IconButton(
            icon: Icon(Icons.comment),
            onPressed: () {
              showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                      title: const Text('Keterangan / Alasan Penolakan'),
                      content: Container(
                          height: 300,
                          width: 300,
                          child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: _event?.persetujuan?.length,
                              itemBuilder: (BuildContext ctxt, int index) {
                                if (_event?.persetujuan?[index]
                                        ['status_proposal'] ==
                                    0) {
                                  return Text(
                                      "${_event?.persetujuan?[index]['jabatan']}:\n${_event?.persetujuan?[index]['keterangan_proposal']}\n");
                                } else {
                                  return Container();
                                }
                              }))));
            },
          ));
    } else {
      return Container();
    }
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

  Widget? accButton() {
    for (var stat in _event!.persetujuan!) {
      if (stat["username"] == username && stat['status_proposal'] == 1) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 500,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                            title: const Text('Peringatan'),
                            content: Text(
                                "Apakah anda yakin hendak melakukan persetujuan? \nStatus persetujuan tidak dapat diubah setelah anda menyetujui"),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  persetujuan(context, "1", "2");
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Anda telah menyetujui proposal')));
                                  Navigator.popAndPushNamed(
                                      context, "/daftarproposal");
                                },
                                child: const Text('Iya'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, 'Tidak'),
                                child: const Text('Tidak'),
                              ),
                            ],
                          ));
                },
                child: Text(
                  'Setujui Proposal',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(
              width: 500,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Keterangan / Alasan Penolakan"),
                        content: Container(
                            height: 300,
                            width: 300,
                            child: TextField(
                              maxLines: 12,
                              onChanged: (value) {
                                keterangan = value;
                              },
                              decoration: InputDecoration(
                                  hintText: "Isikan keterangan/alasan",
                                  border: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.blue))),
                            )),
                        actions: [
                          TextButton(
                            child: Text("Cancel"),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          TextButton(
                            child: Text("Submit"),
                            onPressed: () {
                              persetujuan(context, "1", "0");
                              Navigator.pop(context);

                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Keterangan perbaikan telah dikirimkan pada penyelenggara Event')));
                              Navigator.popAndPushNamed(
                                  context, "/daftarproposal");
                            },
                          )
                        ],
                      );
                    },
                  );
                },
                child: Text(
                  'Tolak Proposal',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            )
          ],
        );
      }
    }
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
                  Text("Penanggung Jawab: ${widget.penanggung_jawab}",
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
        Container(
          margin: EdgeInsets.only(top: 50),
          height: 50,
          width: 1050,
          child: accButton(),
        )
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
                child: SizedBox(
                    width: 1150,
                    child: Stack(
                      children: [
                        Align(alignment: Alignment.centerLeft, child: alasan()),
                        Align(
                            alignment: Alignment.topCenter,
                            child: tampilData(context)),
                      ],
                    ))));

    //ListView(children: [tampilData()])));
  }
}
