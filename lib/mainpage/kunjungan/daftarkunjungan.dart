import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:pt_coronet_crown/mainpage/kunjungan/buatkunjungan.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../class/admin/absen/kunjungan.dart';
import '../../main.dart';
import 'detailkunjungan.dart';

String username = "", id_jabatan = "", startdate = "", enddate = "";

class DaftarKunjungan extends StatefulWidget {
  int type;
  DaftarKunjungan({super.key, required this.type});
  @override
  _DaftarKunjunganState createState() {
    return _DaftarKunjunganState();
  }
}

class _DaftarKunjunganState extends State<DaftarKunjungan> {
  String _txtcari = "";
  TextEditingController _startDateController = TextEditingController();
  TextEditingController _endDateController = TextEditingController();
  // Timer? timer;

  Future<String> fetchData() async {
    final response = await http.post(
        Uri.parse(
            "https://otccoronet.com/otc/account/kunjungan/daftarkunjungan.php"),
        body: {
          'username': username,
          'idjabatan': id_jabatan,
          'startdate': startdate,
          'enddate': enddate,
          'cari': _txtcari,
          'type': widget.type.toString()
        });
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to read API');
    }
  }

  void checkKunjungan() async {
    final response = await http.post(
        Uri.parse(
            "https://otccoronet.com/otc/account/kunjungan/daftarkunjungan.php"),
        body: {'username': username, "type": "3"});
    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      if (json['result'] == 'success') {
        Navigator.popAndPushNamed(context, "/kunjunganmasuk");
      } else if (json['result'] == 'error') {
        warningDialog(json['message']);
      }
    } else {
      throw Exception('Failed to read API');
    }
  }

  warningDialog(message) {
    return showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Text('Peringatan'),
              content: Text(message),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context, 'OK'),
                  child: const Text('OK'),
                ),
              ],
            ));
  }

  _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString("username") ?? '';
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
    // initTimer();
  }

  // void initTimer() {
  //   if (timer != null && timer!.isActive) return;

  //   timer = Timer.periodic(const Duration(seconds: 20), (timer) {
  //     //job
  //     setState(() {});
  //   });
  // }
  Widget tableContent(isHeader, content) {
    if (isHeader == true) {
      return Expanded(child: Text(content, textAlign: TextAlign.center));
    } else {
      return Align(
          alignment: Alignment.center,
          child: Text(content, textAlign: TextAlign.center));
    }
  }

  Widget daftarKunjungan(data, context) {
    List<Kunjungan> visit2 = [];
    Map json = jsonDecode(data);
    if (json['result'] == "error") {
      return Text("Tidak ada data tersedia");
    } else {
      for (var vis in json['data']) {
        Kunjungan visit = Kunjungan.fromJson(vis);
        visit2.add(visit);
      }
      if (MediaQuery.of(context).size.width >= 740) {
        return Padding(
            padding: EdgeInsets.only(left: 5, right: 5),
            child: widget.type == 1
                ? DataTable(
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
                      DataColumn(label: tableContent(true, "ID Kunjungan")),
                      DataColumn(label: tableContent(true, "Nama Toko")),
                      DataColumn(label: tableContent(true, "Username Sales")),
                      DataColumn(label: tableContent(true, "Nama Sales")),
                      DataColumn(label: tableContent(true, "Tanggal")),
                      DataColumn(label: tableContent(true, "Waktu In")),
                      DataColumn(label: tableContent(true, "Waktu Out")),
                      DataColumn(label: tableContent(true, "Status")),
                    ],
                    rows: List<DataRow>.generate(
                        visit2.length,
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
                                            message: "Halaman Detail Kunjungan",
                                            child: TextButton(
                                                style: ButtonStyle(foregroundColor:
                                                    MaterialStateProperty
                                                        .resolveWith<Color>(
                                                            (Set<MaterialState>
                                                                states) {
                                                  if (states.contains(
                                                      MaterialState.hovered))
                                                    return Colors.blue.shade400;
                                                  return Colors.blue.shade600;
                                                })),
                                                child: Text(visit2[index].id,
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        decoration:
                                                            TextDecoration
                                                                .underline)),
                                                onPressed: () => Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            DetailVisit(
                                                              id_visit:
                                                                  visit2[index]
                                                                      .id,
                                                              type: 0,
                                                              username: visit2[
                                                                      index]
                                                                  .username
                                                                  .toString(),
                                                              status:
                                                                  visit2[index]
                                                                      .status,
                                                            )))))),
                                  )),
                                  DataCell(tableContent(
                                      false, visit2[index].nama_toko)),
                                  DataCell(tableContent(false,
                                      visit2[index].username.toString())),
                                  DataCell(tableContent(false,
                                      "${visit2[index].nama_depan}\n${visit2[index].nama_belakang}")),
                                  DataCell(tableContent(
                                      false, visit2[index].tanggal)),
                                  DataCell(tableContent(
                                      false, visit2[index].waktu_in)),
                                  DataCell(tableContent(
                                    false,
                                    visit2[index].waktu_out == null
                                        ? "-"
                                        : visit2[index].waktu_out.toString(),
                                  )),
                                  DataCell(tableContent(
                                    false,
                                    visit2[index].status == 0
                                        ? "Status: Belum Check-Out"
                                        : "Status: Sudah Check-Out",
                                  )),
                                ])))
                : DataTable(
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
                      DataColumn(label: tableContent(true, "ID Kunjungan")),
                      DataColumn(label: tableContent(true, "Nama Toko")),
                      DataColumn(label: tableContent(true, "Tanggal")),
                      DataColumn(label: tableContent(true, "Waktu In")),
                      DataColumn(label: tableContent(true, "Waktu Out")),
                      DataColumn(label: tableContent(true, "Status")),
                    ],
                    rows: List<DataRow>.generate(
                        visit2.length,
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
                                            message: "Halaman Detail Kunjungan",
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
                                                child: Text(visit2[index].id,
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        decoration:
                                                            TextDecoration
                                                                .underline)),
                                                onPressed: () => Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            DetailVisit(
                                                              id_visit:
                                                                  visit2[index]
                                                                      .id,
                                                              type: 0,
                                                              status:
                                                                  visit2[index]
                                                                      .status,
                                                              username: visit2[
                                                                      index]
                                                                  .username
                                                                  .toString(),
                                                            )))))),
                                  )),
                                  DataCell(tableContent(
                                      false, visit2[index].nama_toko)),
                                  DataCell(tableContent(
                                      false, visit2[index].tanggal)),
                                  DataCell(tableContent(
                                      false, visit2[index].waktu_in)),
                                  DataCell(tableContent(
                                    false,
                                    visit2[index].waktu_out == null
                                        ? "-"
                                        : visit2[index].waktu_out.toString(),
                                  )),
                                  DataCell(tableContent(
                                    false,
                                    visit2[index].status == 0
                                        ? "Status: Belum Check-Out"
                                        : "Status: Sudah Check-Out",
                                  )),
                                ]))));
      } else {
        return ListView.builder(
            padding: EdgeInsets.only(left: 5, right: 5),
            itemCount: visit2.length,
            itemBuilder: (BuildContext ctxt, int index) {
              return SingleChildScrollView(
                  child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DetailVisit(
                                      type: 0,
                                      id_visit: visit2[index].id,
                                      username:
                                          visit2[index].username.toString(),
                                      status: visit2[index].status,
                                    )));
                      },
                      child: Card(
                          elevation: 5,
                          child: SizedBox(
                              width: 800,
                              height: 75,
                              child: ListTile(
                                  title: Align(
                                      alignment: Alignment.topCenter,
                                      child: Column(children: [
                                        Container(
                                            alignment: Alignment.topCenter,
                                            width: double.infinity,
                                            child: Text(
                                              visit2[index].nama_toko,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold),
                                            )),
                                        Divider(),

                                        // SizedBox(
                                        //     width: double.infinity,
                                        //     child: Divider())
                                      ])),
                                  leading: Container(
                                      padding: EdgeInsets.only(top: 15),
                                      child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(visit2[index].tanggal,
                                                style: TextStyle(fontSize: 11),
                                                textAlign: TextAlign.left),
                                            Text(
                                                visit2[index].status == 0
                                                    ? "Status: Belum Check-Out"
                                                    : "Status: Sudah Check-Out",
                                                style: TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.grey),
                                                textAlign: TextAlign.left)
                                          ])),
                                  // title: Text(visit2[index].tanggal,
                                  //     style: TextStyle(fontSize: 11)),
                                  trailing: Padding(
                                      padding: EdgeInsets.only(top: 15),
                                      child: Column(children: [
                                        Text(
                                            "Waktu In: ${visit2[index].waktu_in}",
                                            style: TextStyle(fontSize: 11)),
                                        Text(
                                            visit2[index].status == 0
                                                ? "Waktu Out: -"
                                                : "Waktu Out: ${visit2[index].waktu_out}",
                                            style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey))
                                      ]))))))
                ],
              ));
            });
      }
    }
  }

  showDialogPermission(content) {
    return showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(title: Text("Peringatan"), content: Text(content)));
  }

  void permission() async {
    LocationPermission permission;
    if (kIsWeb) {
      showDialogPermission(
          "Fitur absensi tidak tersedia pada versi website atau desktop. \nSilahkan akses dari aplikasi ponsel anda");
    } else {
      if (await Permission.camera.status.isDenied) {
        Permission.camera.request();
      } else if (await Permission.camera.status.isPermanentlyDenied) {
        showDialogPermission("Anda belum mengizinkan penggunaan kamera");
        openAppSettings();
      }

      permission = await Geolocator.checkPermission();
      if (!await Geolocator.isLocationServiceEnabled()) {
        showDialogPermission(
            "Anda belum aktivasi lokasi pada perangkat mobile");
      }
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          showDialogPermission(
              "Harap izinkan aplikasi dalam mengakses aplikasi");
        }
      } else if (permission == LocationPermission.deniedForever) {
        showDialogPermission(
            "Aplikasi anda melarang akses lokasi, silahkan lakukan perubahan hak akses di setting");
      } else {
        checkKunjungan();
      }
    }
  }

  Widget buttonKunjunganSaya(BuildContext context) {
    return SizedBox(
        height: 50,
        width: 130,
        child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 248, 172, 49)),
            onPressed: () {
              setState(() {
                if (widget.type == 1)
                  widget.type = 0;
                else
                  widget.type = 1;
                build(context);
              });
            },
            child: Text(
              widget.type == 0 ? "Keseluruhan \nKunjungan" : "Kunjungan Saya",
              style: TextStyle(color: Colors.black, fontSize: 16),
              textAlign: TextAlign.center,
            )));
  }

  Widget kolomCari() {
    return SizedBox(
      height: 50,
      width: 175,
      child: TextFormField(
        decoration: const InputDecoration(
          icon: Icon(Icons.search),
          labelText: 'Cari Kunjungan',
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
                child: widget.type == 1
                    ? MediaQuery.of(context).size.width > 390
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                                buttonKunjunganSaya(context),
                                kolomCari()
                              ])
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              buttonKunjunganSaya(context),
                              kolomCari()
                            ],
                          )
                    : kolomCari()),
            if (widget.type == 1)
              Text(
                "Pilih tanggal untuk melakukan filtering data",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            if (widget.type == 1)
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
                        return daftarKunjungan(
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
    // if (idjabatan != "3") {
    //   if (idjabatan == "1" || idjabatan == "2") {
    return Scaffold(
        // appBar: AppBar(
        //   title: Text("Daftar Pembelian"),
        // ),
        // drawer: MyDrawer(),
        floatingActionButton: Tooltip(
            message: "Lakukan Kunjungan",
            child: FloatingActionButton(
              onPressed: () => permission(),
              child: Icon(Icons.add, color: Colors.white),
            )),
        body: buildContainer(context));
    // } else {
    //   return Scaffold(
    //       appBar: AppBar(
    //         leading: BackButton(
    //           onPressed: () {
    //             Navigator.popAndPushNamed(context, "homepage");
    //           },
    //         ),
    //         title: Text("Daftar Pembelian"),
    //       ),
    //       body: buildContainer(context));
    // }
    //}
  }
}
