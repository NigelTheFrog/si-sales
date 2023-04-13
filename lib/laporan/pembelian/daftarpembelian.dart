import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
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
            "http://192.168.137.1/magang/laporan/pembelian/daftarpembelian.php"),
        body: {'startdate': startdate, 'enddate': enddate, 'cari': _txtcari});
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
                    child: Text("Pembeli", textAlign: TextAlign.center))),
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
                        Text("Total Pembelian", textAlign: TextAlign.center))),
          ], rows: [])));
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
            return DataTable(
                dataRowHeight: 75,
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
                          child: Text("Tanggal", textAlign: TextAlign.center))),
                  DataColumn(
                      label: Expanded(
                          child: Text("Waktu", textAlign: TextAlign.center))),
                  DataColumn(
                      label: Expanded(
                          child: Text("Jumlah \nbarang",
                              textAlign: TextAlign.center))),
                  DataColumn(
                      label: Expanded(
                          child: Text("Total \nPembelian",
                              textAlign: TextAlign.center))),
                ],
                rows: pembelian2
                    .map<DataRow>((element) => DataRow(cells: [
                          DataCell(Align(
                              alignment: Alignment.center,
                              child: SizedBox(
                                  width: 200,
                                  child: Tooltip(
                                      message: "Foto Nota",
                                      child: TextButton(
                                        style: TextButton.styleFrom(
                                          textStyle: const TextStyle(
                                              fontWeight: FontWeight.normal),
                                        ),
                                        onPressed: () {
                                          showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                  content: kIsWeb
                                                      ? SizedBox(
                                                          width: 500,
                                                          height: 500,
                                                          child: showFotoNota(
                                                              context,
                                                              element.id,
                                                              element.foto))
                                                      : FittedBox(
                                                          child: showFotoNota(
                                                              context,
                                                              element.id,
                                                              element.foto))));
                                        },
                                        child: Text(element.id,
                                            textAlign: TextAlign.center),
                                      ))))),
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
                                  "Rp. ${NumberFormat('###,000').format((element.total_pembelian - element.diskon) + (((element.total_pembelian - element.diskon) * (element.ppn / 100.00))))}",
                                  textAlign: TextAlign.center))),
                        ]))
                    .toList());
          });
    }
  }

  Widget showFotoNota(BuildContext context, id, foto) {
    return Tooltip(
        message: "Halaman Detail Pembelian",
        child: GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DetailPembelian(
                            laporan_id: id,
                          )));
            },
            child: Image.memory(base64Decode(foto))));
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
                      if (snapshot.hasData) {
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
    if (idjabatan == "1" || idjabatan == "2") {
      return Scaffold(
          appBar: AppBar(
            title: Text("Daftar Pembelian"),
          ),
          drawer: MyDrawer(),
          body: buildContainer(context));
    } else if (idjabatan == "3") {
      return Scaffold(
        appBar: AppBar(
          title: Text("Daftar Pembelian"),
          leading: BackButton(
            onPressed: () {
              Navigator.popAndPushNamed(context, "homepage");
            },
          ),
        ),
        body: Center(
          child: Text(
            "Anda tidak memiliki akses ke halaman ini \nSilahkan kontak admin",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      );
    } else {
      return Scaffold(
          appBar: AppBar(
            title: Text("Daftar Pembelian"),
            leading: BackButton(
              onPressed: () {
                Navigator.popAndPushNamed(context, "homepage");
              },
            ),
          ),
          body: buildContainer(context));
    }
  }
}
