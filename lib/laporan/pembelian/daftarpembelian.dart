import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pt_coronet_crown/class/transaksi/pembelian.dart';
import 'package:pt_coronet_crown/drawer.dart';
import 'package:pt_coronet_crown/laporan/pembelian/detailpembelian.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../main.dart';

String nama_depan = "",
    nama_belakang = "",
    username = "",
    id_jabatan = "",
    startdate = "",
    enddate = "";

class DaftarPembelian extends StatefulWidget {
  DaftarPembelian({Key? key}) : super(key: key);
  @override
  _DaftarPembelianState createState() {
    return _DaftarPembelianState();
  }
}

class _DaftarPembelianState extends State<DaftarPembelian> {
  String _txtcari = "";
  TextEditingController _startDateController = TextEditingController();
  TextEditingController _endDateController = TextEditingController();
  Timer? timer;

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
    initTimer();
  }

  void initTimer() {
    if (timer != null && timer!.isActive) return;

    timer = Timer.periodic(const Duration(seconds: 20), (timer) {
      //job
      setState(() {});
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<String> fetchData() async {
    final response = await http.post(
        Uri.parse(
            "https://otccoronet.com/otc/laporan/pembelian/daftarpembelian.php"),
        body: {
          'startdate': startdate,
          'enddate': enddate,
          'cari': _txtcari,
          'type': "1"
        });
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to read API');
    }
  }

  Widget daftarpembelian(data, context) {
    List<Pembelian> pembelian2 = [];
    Map json = jsonDecode(data);
    if (json['result'] == "error") {
      return Text("Tidak ada data pembelian pada rentang tanggal tersebut",
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold));
    } else {
      for (var pem in json['data']) {
        Pembelian pembelian = Pembelian.fromJson(pem);
        pembelian2.add(pembelian);
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
                          child: Text("Pembeli", textAlign: TextAlign.center))),
                  DataColumn(
                      label: Expanded(
                          child: Text("Hari,\nTanggal",
                              textAlign: TextAlign.center))),
                  DataColumn(
                      label: Expanded(
                          child: Text("Waktu", textAlign: TextAlign.center))),
                  DataColumn(
                      label: Expanded(
                          child:
                              Text("Supplier", textAlign: TextAlign.center))),
                  DataColumn(
                      label: Expanded(
                          child: Text("Jumlah \nbarang",
                              textAlign: TextAlign.center))),
                  DataColumn(
                      label: Expanded(
                          child: Text("Total \nPembelian",
                              textAlign: TextAlign.center))),
                  DataColumn(
                      label: Expanded(
                          child:
                              Text("Foto \nNota", textAlign: TextAlign.center)))
                ],
                rows: List<DataRow>.generate(
                    pembelian2.length,
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
                                          message: "Halaman Detail Pembelian",
                                          child: TextButton(
                                              style: ButtonStyle(
                                                  foregroundColor:
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
                                              child: Text(pembelian2[index].id,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      decoration: TextDecoration
                                                          .underline)),
                                              onPressed: () => Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          DetailPembelian(
                                                            laporan_id:
                                                                pembelian2[
                                                                        index]
                                                                    .id,
                                                          )))))))),
                              DataCell(Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                      "${pembelian2[index].nama_depan} ${pembelian2[index].nama_belakang}",
                                      textAlign: TextAlign.center))),
                              DataCell(Align(
                                  alignment: Alignment.center,
                                  child: Text(pembelian2[index].tanggal,
                                      textAlign: TextAlign.center))),
                              DataCell(Align(
                                  alignment: Alignment.center,
                                  child: Text(pembelian2[index].waktu,
                                      textAlign: TextAlign.center))),
                              DataCell(Align(
                                  alignment: Alignment.center,
                                  child: Text(pembelian2[index].nama_supplier,
                                      textAlign: TextAlign.center))),
                              DataCell(Align(
                                  alignment: Alignment.center,
                                  child: Text(pembelian2[index].jumlah_barang,
                                      textAlign: TextAlign.center))),
                              DataCell(Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                      "Rp. ${NumberFormat('###,000').format((pembelian2[index].total_pembelian - pembelian2[index].diskon) + (((pembelian2[index].total_pembelian - pembelian2[index].diskon) * (pembelian2[index].ppn / 100.00))))}",
                                      textAlign: TextAlign.center))),
                              DataCell(Align(
                                  alignment: Alignment.center,
                                  child: Tooltip(
                                      message: "Foto Nota",
                                      child: IconButton(
                                          onPressed: () => showFotoNota(
                                              context, pembelian2[index].foto),
                                          icon: Icon(Icons.remove_red_eye))))),
                            ]))));
      } else {
        return ListView.builder(
            itemCount: pembelian2.length,
            padding: EdgeInsets.only(left: 5, right: 5),
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
                            TextSpan(text: pembelian2[index].id),
                            TextSpan(
                                text: "\n\nPembeli: ",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            TextSpan(
                                text:
                                    "${pembelian2[index].nama_depan} ${pembelian2[index].nama_depan}"),
                            TextSpan(
                                text: "\n\nHari, tanggal: ",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            TextSpan(text: pembelian2[index].tanggal),
                            TextSpan(
                                text: ", Waktu: ",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            TextSpan(text: pembelian2[index].waktu),
                            TextSpan(
                                text: "\n\nSupplier: ",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            TextSpan(text: pembelian2[index].nama_supplier),
                            TextSpan(
                                text: ", Jumlah Barang: ",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            TextSpan(text: pembelian2[index].jumlah_barang),
                            TextSpan(
                                text: "\nTotal Pembelian: ",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            TextSpan(
                                text:
                                    "Rp. ${NumberFormat('###,000').format((pembelian2[index].total_pembelian - pembelian2[index].diskon) + (((pembelian2[index].total_pembelian - pembelian2[index].diskon) * (pembelian2[index].ppn / 100.00))))}"),
                            TextSpan(
                                text: ", Foto Nota: ",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: IconButton(
                                    onPressed: () => showFotoNota(
                                        context, pembelian2[index].foto),
                                    icon: Icon(
                                      Icons.remove_red_eye,
                                      size: 25,
                                    ))),
                            TextSpan(
                                text: "\nHalaman detail pembelian",
                                style: TextStyle(
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => DetailPembelian(
                                                laporan_id:
                                                    pembelian2[index].id,
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

  Widget buttonTambahPembelian(BuildContext context) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromARGB(255, 248, 172, 49)),
        onPressed: () {
          Navigator.popAndPushNamed(context, "/tambahlaporanpembelian");
        },
        child: Text(
          "Tambah Pembelian",
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                            buttonTambahPembelian(context),
                            kolomCari()
                          ])
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          buttonTambahPembelian(context),
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
                        return daftarpembelian(
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
            //   title: Text("Daftar Pembelian"),
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
              title: Text("Daftar Pembelian"),
            ),
            body: buildContainer(context));
      }
    } else {
      return Scaffold(
          appBar: AppBar(
            title: Text("Daftar Pembelian"),
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
