import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/gestures.dart';
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
      id_jabatan = prefs.getString("idJabatan") ?? '';
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
            "https://otccoronet.com/otc/laporan/penjualan/daftarpenjualan.php"),
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
      return Text("Tidak ada data penjualan pada rentang tanggal tersebut",
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold));
    } else {
      for (var pen in json['data']) {
        Penjualan penjualan = Penjualan.fromJson(pen);
        penjualan2.add(penjualan);
      }
      if (MediaQuery.of(context).size.width >= 740) {
        return Padding(
            padding: EdgeInsets.only(left: 5, right: 5),
            child: DataTable(
                border: TableBorder(
                    verticalInside: BorderSide(
                        width: 1,
                        style: BorderStyle.solid,
                        color: Color.fromARGB(75, 0, 0, 0))),
                headingRowColor: MaterialStateColor.resolveWith(
                    (states) => Colors.grey.shade600),
                dataRowHeight: 75,
                columnSpacing: 20,
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
                          child: Text("Outlet", textAlign: TextAlign.center))),
                  DataColumn(
                      label: Expanded(
                          child: Text("Jumlah \nbarang",
                              textAlign: TextAlign.center))),
                  DataColumn(
                      label: Expanded(
                          child: Text("Total Penjualan",
                              textAlign: TextAlign.center))),
                  DataColumn(
                      label: Expanded(
                          child:
                              Text("Foto Nota", textAlign: TextAlign.center))),
                ],
                rows: List<DataRow>.generate(
                    penjualan2.length,
                    (index) => DataRow(
                            color: MaterialStateProperty.resolveWith<Color>(
                                (Set<MaterialState> states) {
                              // Even rows will have a grey color.
                              if (index % 2 == 0) {
                                return Colors.grey.shade300;
                              } else {
                                return Colors.grey
                                    .shade400; // Use default value for other states and odd rows.
                              }
                            }),
                            cells: [
                              DataCell(Align(
                                alignment: Alignment.center,
                                child: SizedBox(
                                    width: 200,
                                    child: Tooltip(
                                        message: "Halaman Detail Penjualan",
                                        child: TextButton(
                                            style: ButtonStyle(foregroundColor:
                                                MaterialStateProperty
                                                    .resolveWith<Color>(
                                                        (Set<MaterialState>
                                                            states) {
                                              if (states.contains(
                                                  MaterialState.hovered))
                                                return Colors.blue.shade400;
                                              return Colors.blue
                                                  .shade600; // null throus error in flutter 2.2+.
                                            })),
                                            child: Text(penjualan2[index].id,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    decoration: TextDecoration
                                                        .underline)),
                                            onPressed: () => Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        DetailPenjualan(
                                                          laporan_id:
                                                              penjualan2[index]
                                                                  .id,
                                                        )))))),
                              )),
                              DataCell(Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                      "${penjualan2[index].nama_depan} ${penjualan2[index].nama_belakang}",
                                      textAlign: TextAlign.center))),
                              DataCell(Align(
                                  alignment: Alignment.center,
                                  child: Text(penjualan2[index].tanggal,
                                      textAlign: TextAlign.center))),
                              DataCell(Align(
                                  alignment: Alignment.center,
                                  child: Text(penjualan2[index].waktu,
                                      textAlign: TextAlign.center))),
                              DataCell(Align(
                                  alignment: Alignment.center,
                                  child: Text(penjualan2[index].nama_toko,
                                      textAlign: TextAlign.center))),
                              DataCell(Align(
                                  alignment: Alignment.center,
                                  child: Text(penjualan2[index].jumlah_barang,
                                      textAlign: TextAlign.center))),
                              DataCell(Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                      "Rp. ${NumberFormat('###,000').format((penjualan2[index].total_penjualan - penjualan2[index].diskon) + (((penjualan2[index].total_penjualan - penjualan2[index].diskon) * (penjualan2[index].ppn / 100.00))))}",
                                      textAlign: TextAlign.center))),
                              DataCell(Align(
                                  alignment: Alignment.center,
                                  child: penjualan2[index].foto == null
                                      ? Text(
                                          "Penjualan ini tidak\nmenggunakan nota")
                                      : Tooltip(
                                          message: "Foto Nota",
                                          child: IconButton(
                                              style: ButtonStyle(
                                                  foregroundColor:
                                                      MaterialStateProperty
                                                          .resolveWith<
                                                              Color>((Set<
                                                                  MaterialState>
                                                              states) {
                                                if (states.contains(
                                                    MaterialState.hovered))
                                                  return Colors.grey;
                                                return Colors
                                                    .black; // null throus error in flutter 2.2+.
                                              })),
                                              onPressed: () => showFotoNota(
                                                  context,
                                                  penjualan2[index].foto),
                                              icon:
                                                  Icon(Icons.remove_red_eye)))))
                            ]))));
      } else {
        return ListView.builder(
            padding: EdgeInsets.only(left: 5, right: 5),
            itemCount: penjualan2.length,
            itemBuilder: (BuildContext ctxt, int index) {
              return Card(
                  elevation: 5,
                  clipBehavior: Clip.hardEdge,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Container(
                      color: index % 2 == 0
                          ? Colors.grey.shade200
                          : Colors.grey.shade400,
                      width: MediaQuery.of(context).size.width * 0.5,
                      padding: EdgeInsets.only(left: 10, top: 10, bottom: 10),
                      child: RichText(
                          text: TextSpan(
                              style: TextStyle(
                                fontSize: 13.0,
                                color: Colors.black,
                              ),
                              children: [
                            TextSpan(
                                text: "ID Laporan: ",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            TextSpan(text: penjualan2[index].id),
                            TextSpan(
                                text: "\n\nPenjual: ",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            TextSpan(
                                text:
                                    "${penjualan2[index].nama_depan} ${penjualan2[index].nama_depan}"),
                            TextSpan(
                                text: "\n\nHari, tanggal: ",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            TextSpan(text: penjualan2[index].tanggal),
                            TextSpan(
                                text: ", Waktu: ",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            TextSpan(text: penjualan2[index].waktu),
                            TextSpan(
                                text: "\n\nOutlet: ",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            TextSpan(text: penjualan2[index].nama_toko),
                            TextSpan(
                                text: ", Jumlah Barang: ",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            TextSpan(text: penjualan2[index].jumlah_barang),
                            TextSpan(
                                text: "\nTotal Pembelian: ",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            TextSpan(
                                text:
                                    "Rp. ${NumberFormat('###,000').format((penjualan2[index].total_penjualan - penjualan2[index].diskon) + (((penjualan2[index].total_penjualan - penjualan2[index].diskon) * (penjualan2[index].ppn / 100.00))))}"),
                            TextSpan(
                                text: ", Foto Nota: ",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: IconButton(
                                    onPressed: () => showFotoNota(
                                        context, penjualan2[index].foto),
                                    icon: Icon(
                                      Icons.remove_red_eye,
                                      size: 25,
                                    ))),
                            TextSpan(
                                text: "\nHalaman detail penjualan",
                                style: TextStyle(
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => DetailPenjualan(
                                                laporan_id:
                                                    penjualan2[index].id,
                                              ))))
                          ]))));
            });
      }
    }
  }

  showFotoNota(BuildContext context, foto) {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
            content: SizedBox(
                height: 500,
                width: 500,
                child: Image.memory(base64Decode(foto)))));
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
                              // buttonTambahPenjualan(context),
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
                      if (snapshot.hasData &&
                          snapshot.connectionState == ConnectionState.done) {
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
    if (idjabatan != "3") {
      if (idjabatan == "1" || idjabatan == "2") {
        return Scaffold(
            // appBar: AppBar(
            //   title: Text("Daftar Penjualan"),
            // ),
            // drawer: MyDrawer(),
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
    } else {
      return Scaffold(
          // appBar: AppBar(
          //   title: Text("Daftar Penjualan"),
          // ),
          // drawer: MyDrawer(),
          body: buildContainer(context));
    }
  }
}
