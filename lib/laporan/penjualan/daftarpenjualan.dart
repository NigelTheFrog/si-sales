import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pt_coronet_crown/class/transaksi/penjualan.dart';
import 'package:pt_coronet_crown/drawer.dart';
import 'package:pt_coronet_crown/laporan/penjualan/detailpenjualan.dart';
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

  late Timer timer;

  _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString("username") ?? '';
      id_jabatan = prefs.getString("idjabatan") ?? '';
      nama_depan = prefs.getString("nama_depan") ?? '';
      nama_belakang = prefs.getString("nama_belakang") ?? '';
      id_cabang = prefs.getString("idCabang") ?? '';
      id_grup = prefs.getString("idGrup") ?? '';
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
            "http://192.168.137.1/magang/laporan/penjualan/daftarpenjualan.php"),
        body: {
          'startdate': startdate,
          'enddate': enddate,
          'cari': _txtcari,
          'idjabatan': id_jabatan,
          'idcabang': id_cabang,
          'username': username,
          'id_grup': id_grup
        });
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to read API');
    }
  }

  // _write(var text, String filename) async {
  //   Directory directory = await getApplicationDocumentsDirectory();
  //   File file = File('${directory.path}/$filename.jpg');
  //   file.writeAsBytesSync(text);
  // }
  // _write(String text) async {
  //   final Directory directory = await getApplicationDocumentsDirectory();
  //   final File file = File('${directory.path}/my_file.txt');
  //   await file.writeAsString(text);
  // }

  // Future<void> _createPDF() async {
  //   //Create a PDF document.
  //   PdfDocument document = PdfDocument();
  //   //Add a page and draw text
  //   document.pages.add().graphics.drawString(
  //       'Hello World!', PdfStandardFont(PdfFontFamily.helvetica, 20),
  //       brush: PdfSolidBrush(PdfColor(0, 0, 0)),
  //       bounds: Rect.fromLTWH(20, 60, 150, 30));
  //   //Save the document
  //   List<int> bytes = await document.save();
  //   //Dispose the document
  //   document.dispose();
  //   AnchorElement(
  //       href:
  //           "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(bytes)}")
  //     ..setAttribute("download", "output.pdf")
  //     ..click();
  // }

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
                                  child: element.foto == null ||
                                          element.foto == ""
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
                                                      content: kIsWeb
                                                          ? SizedBox(
                                                              width: 500,
                                                              height: 500,
                                                              child:
                                                                  showFotoNota(
                                                                      context,
                                                                      element
                                                                          .id,
                                                                      element
                                                                          .foto))
                                                          : FittedBox(
                                                              child: showFotoNota(
                                                                  context,
                                                                  element.id,
                                                                  element
                                                                      .foto))));
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

  Widget showFotoNota(BuildContext context, id, foto) {
    return Tooltip(
        message: "Halaman Detail Penjualan",
        child: GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DetailPenjualan(
                            laporan_id: id,
                          )));
            },
            child: Image.memory(base64Decode(foto))));
  }

  Widget buttonTambahPenjualan(BuildContext context) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromARGB(255, 248, 172, 49)),
        onPressed: () {
          Navigator.popAndPushNamed(context, "/tambahlaporanpenjualan");
        },
        child: Text(
          "Tambah Penjualan",
          style: TextStyle(color: Colors.black, fontSize: 16),
        ));
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
                        children: <Widget>[
                            if (id_jabatan == "1" || id_jabatan == "2")
                              buttonTambahPenjualan(context),
                            kolomCari()
                          ])
                    : Column(
                        mainAxisAlignment:
                            id_jabatan == "1" || id_jabatan == "2"
                                ? MainAxisAlignment.spaceBetween
                                : MainAxisAlignment.center,
                        children: <Widget>[
                          if (id_jabatan == "1" || id_jabatan == "2")
                            buttonTambahPenjualan(context),
                          kolomCari()
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
            leading: BackButton(
              onPressed: () {
                Navigator.popAndPushNamed(context, "homepage");
              },
            ),
            title: Text("Daftar Penjualan"),
          ),
          body: buildContainer(context));
    }
  }
}
