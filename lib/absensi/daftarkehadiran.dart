import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:pt_coronet_crown/absensi/buatkehadiran.dart';
import 'package:pt_coronet_crown/class/admin/absen/absen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

String username = "", id_jabatan = "", startdate = "", enddate = "";

class DaftarKehadiran extends StatefulWidget {
  int type;
  DaftarKehadiran({super.key, required this.type});
  @override
  _DaftarKehadiranState createState() {
    return _DaftarKehadiranState();
  }
}

class _DaftarKehadiranState extends State<DaftarKehadiran>
    with WidgetsBindingObserver {
  String _txtcari = "", id_grup = "";
  TextEditingController _startDateController = TextEditingController();
  TextEditingController _endDateController = TextEditingController();
  // Timer? timer;

  Future<String> fetchData() async {
    final response = await http.post(
        Uri.parse("https://otccoronet.com/otc/account/absensi/daftarabsen.php"),
        body: {
          'username': username,
          'id_jabatan': id_jabatan,
          'startdate': startdate,
          'enddate': enddate,
          'id_grup': id_grup,
          'cari': _txtcari,
          'type': widget.type.toString()
        });
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to read API');
    }
  }

  _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString("username") ?? '';
      id_jabatan = prefs.getString("idJabatan") ?? '';
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
    // initTimer();
  }

  Widget tableContent(isHeader, content) {
    if (isHeader == true) {
      return Expanded(child: Text(content, textAlign: TextAlign.center));
    } else {
      return Align(
          alignment: Alignment.center,
          child: Text(content, textAlign: TextAlign.center));
    }
  }

  TextSpan cardContent(isHeader, content) {
    if (content == true) {
      return TextSpan(
          text: content, style: const TextStyle(fontWeight: FontWeight.bold));
    } else {
      return TextSpan(text: content);
    }
  }

  Widget daftarKehadiran(data, context) {
    List<Absen> absen2 = [];
    Map json = jsonDecode(data);
    if (json['result'] == "error") {
      return Text("Tidak ada data tersedia");
    } else {
      for (var abs in json['data']) {
        Absen absen = Absen.fromJson(abs);
        absen2.add(absen);
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
                    dataRowMaxHeight: 75,
                    columnSpacing: 20,
                    columns: [
                      DataColumn(label: tableContent(true, "ID Absen")),
                      DataColumn(label: tableContent(true, "Username")),
                      DataColumn(label: tableContent(true, "Nama Pegawai")),
                      DataColumn(label: tableContent(true, "Tanggal")),
                      DataColumn(label: tableContent(true, "Waktu")),
                      DataColumn(label: tableContent(true, "Status")),
                      // DataColumn(label: tableContent(true, "ID Lokasi")),
                      DataColumn(label: tableContent(true, "Bukti")),
                    ],
                    rows: List<DataRow>.generate(
                        absen2.length,
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
                                  DataCell(
                                      tableContent(false, absen2[index].id)),
                                  DataCell(tableContent(false,
                                      absen2[index].username.toString())),
                                  DataCell(tableContent(false,
                                      "${absen2[index].nama_depan.toString()} ${absen2[index].nama_belakang.toString()}")),
                                  DataCell(tableContent(
                                      false, absen2[index].tanggal)),
                                  DataCell(
                                      tableContent(false, absen2[index].waktu)),
                                  DataCell(tableContent(
                                    false,
                                    absen2[index].status == 0
                                        ? "Status: Absen"
                                        : "Status: Sudah Check-Out",
                                  )),
                                  // DataCell(tableContent(
                                  //     false, absen2[index].id_lokasi)),
                                  DataCell(Align(
                                      alignment: Alignment.center,
                                      child: IconButton(
                                          icon: Icon(Icons.remove_red_eye),
                                          onPressed: () => showBukti(
                                              context, absen2[index].bukti)))),
                                ])))
                : DataTable(
                    border: TableBorder(
                        verticalInside: BorderSide(
                            width: 1,
                            style: BorderStyle.solid,
                            color: Color.fromARGB(75, 0, 0, 0))),
                    headingRowColor: MaterialStateColor.resolveWith(
                        (states) => Colors.grey.shade600),
                    dataRowMaxHeight: 75,
                    columnSpacing: 20,
                    columns: [
                      DataColumn(label: tableContent(true, "ID Absen")),
                      DataColumn(label: tableContent(true, "Tanggal")),
                      DataColumn(label: tableContent(true, "Waktu")),
                      DataColumn(label: tableContent(true, "Status")),
                      DataColumn(label: tableContent(true, "Bukti")),
                    ],
                    rows: List<DataRow>.generate(
                        absen2.length,
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
                                  DataCell(
                                      tableContent(false, absen2[index].id)),
                                  DataCell(tableContent(
                                      false, absen2[index].tanggal)),
                                  DataCell(
                                      tableContent(false, absen2[index].waktu)),
                                  DataCell(tableContent(
                                    false,
                                    absen2[index].status == 0
                                        ? "Status: Belum Check-Out"
                                        : "Status: Sudah Check-Out",
                                  )),
                                  DataCell(Align(
                                      alignment: Alignment.center,
                                      child: IconButton(
                                          icon: Icon(Icons.remove_red_eye),
                                          onPressed: () => showBukti(
                                              context, absen2[index].bukti)))),
                                ]))));
      } else {
        return ListView.builder(
            padding: EdgeInsets.only(left: 5, right: 5),
            itemCount: absen2.length,
            itemBuilder: (BuildContext ctxt, int index) {
              return SingleChildScrollView(
                  child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Card(
                      elevation: 5,
                      clipBehavior: Clip.hardEdge,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Container(
                          color: index % 2 == 0
                              ? Colors.grey.shade200
                              : Colors.grey.shade400,
                          width: MediaQuery.of(context).size.width,
                          padding:
                              EdgeInsets.only(left: 10, top: 10, bottom: 10),
                          child: widget.type == 1
                              ? RichText(
                                  text: TextSpan(
                                      style: TextStyle(
                                        fontSize: 13.0,
                                        color: Colors.black,
                                      ),
                                      children: [
                                      cardContent(true, "ID Absen: "),
                                      cardContent(false, absen2[index].id),
                                      cardContent(true, "\n\nUsername: "),
                                      cardContent(
                                          false, absen2[index].username),
                                      cardContent(true, ", Nama: "),
                                      cardContent(false,
                                          "${absen2[index].nama_depan.toString()} ${absen2[index].nama_belakang.toString()}"),
                                      cardContent(true, "\n\nHari, tanggal: "),
                                      cardContent(false, absen2[index].tanggal),
                                      cardContent(true, ", Waktu: "),
                                      cardContent(false, absen2[index].waktu),
                                      cardContent(true, ", \nStatus: : "),
                                      cardContent(
                                          false,
                                          absen2[index].status == 0
                                              ? "Belum Check-Out"
                                              : absen2[index].status == 2
                                                  ? "Belum Acc TL"
                                                  : absen2[index].status == 3
                                                      ? "Belum Acc SPV"
                                                      : absen2[index].status ==
                                                              4
                                                          ? "Belum Acc AM"
                                                          : absen2[index]
                                                                      .status ==
                                                                  5
                                                              ? "Belum Acc Admin"
                                                              : "Sudah Check-Out"),
                                      cardContent(true, ", Bukti: "),
                                      WidgetSpan(
                                          alignment:
                                              PlaceholderAlignment.middle,
                                          child: IconButton(
                                              onPressed: () => showBukti(
                                                  context, absen2[index].bukti),
                                              icon: Icon(
                                                Icons.remove_red_eye,
                                                size: 25,
                                              ))),
                                      cardContent(true, "\nKeterangan: "),
                                      cardContent(
                                          false, absen2[index].keterangan),
                                    ]))
                              : RichText(
                                  text: TextSpan(
                                      style: TextStyle(
                                        fontSize: 13.0,
                                        color: Colors.black,
                                      ),
                                      children: [
                                      cardContent(true, "ID Absen: "),
                                      cardContent(false, absen2[index].id),
                                      cardContent(true, "\n\nHari, tanggal: "),
                                      cardContent(false, absen2[index].tanggal),
                                      cardContent(true, ", Waktu: "),
                                      cardContent(false, absen2[index].waktu),
                                      cardContent(true, ", \nStatus: : "),
                                      cardContent(
                                          false,
                                          absen2[index].status == 0
                                              ? "Belum Check-Out"
                                              : absen2[index].status == 2
                                                  ? "Belum Acc TL"
                                                  : absen2[index].status == 3
                                                      ? "Belum Acc SPV"
                                                      : absen2[index].status ==
                                                              4
                                                          ? "Belum Acc AM"
                                                          : absen2[index]
                                                                      .status ==
                                                                  5
                                                              ? "Belum Acc Admin"
                                                              : "Sudah Check-Out"),
                                      cardContent(true, ", Bukti: "),
                                      WidgetSpan(
                                          alignment:
                                              PlaceholderAlignment.middle,
                                          child: IconButton(
                                              onPressed: () => showBukti(
                                                  context, absen2[index].bukti),
                                              icon: Icon(
                                                Icons.remove_red_eye,
                                                size: 25,
                                              ))),
                                      cardContent(true, "\nKeterangan: "),
                                      cardContent(
                                          false, absen2[index].keterangan),
                                    ]))))
                ],
              ));
            });
      }
    }
  }

  showBukti(BuildContext context, foto) {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
            content: SizedBox(
                height: 500,
                width: 500,
                child: Image.memory(base64Decode(foto)))));
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
              widget.type == 0 ? "Keseluruhan \nKehadiran" : "Kehadiran Saya",
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
          labelText: 'Cari Kehadiran',
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
                startdate = value.toString().substring(0, 10);
                String formattedDate =
                    DateFormat.yMMMMEEEEd('id').format(value!);
                _startDateController.text = formattedDate;
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
                child: widget.type == 1 || id_jabatan != "3"
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
                        return daftarKehadiran(
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
        Geolocator.getCurrentPosition(
                desiredAccuracy: LocationAccuracy.best,
                forceAndroidLocationManager: true)
            .then((Position position) {
          setState(() {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => BuatKehadiran(
                        lintang: position.latitude,
                        bujur: position.longitude)));
          });
        });
        // Navigator.push(
        //     context, MaterialPageRoute(builder: (context) => BuatKehadiran(lintang: Geolocator.,)));
      }
    }
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
            message: "Lakukan Absensi",
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
