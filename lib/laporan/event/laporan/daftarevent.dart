import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:pt_coronet_crown/class/transaksi/eventherocyn.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pt_coronet_crown/drawer.dart';
import 'package:pt_coronet_crown/laporan/event/laporan/buatlaporan.dart';
import 'package:pt_coronet_crown/laporan/event/laporan/detailevent.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

String nama_depan = "",
    nama_belakang = "",
    username = "",
    id_jabatan = "",
    startdate = "",
    enddate = "";

class DaftarEvent extends StatefulWidget {
  int type;
  DaftarEvent({super.key, required this.type});
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
      return Padding(
          padding: EdgeInsets.only(top: 20),
          child: Text("Tidak ada data event pada rentang tanggal tersebut",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold)));
    } else {
      for (var ev in json['data']) {
        EventHerocyn event = EventHerocyn.fromJson(ev);
        event2.add(event);
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
                columnSpacing: 20,
                dataRowHeight: 75,
                columns: [
                  DataColumn(
                      label: Expanded(
                          child:
                              Text("ID Event", textAlign: TextAlign.center))),
                  DataColumn(
                      label: Expanded(
                          child: Text("Nama \nEvent",
                              textAlign: TextAlign.center))),
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
                rows: List<DataRow>.generate(
                    event2.length,
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
                                  child: Tooltip(
                                      message: "Halaman Detail Event",
                                      child: TextButton(
                                        style: ButtonStyle(foregroundColor:
                                            MaterialStateProperty.resolveWith<
                                                    Color>(
                                                (Set<MaterialState> states) {
                                          if (states
                                              .contains(MaterialState.hovered))
                                            return Colors.blue.shade400;
                                          return Colors.blue
                                              .shade600; // null throus error in flutter 2.2+.
                                        })),
                                        onPressed: () {
                                          if (event2[index].status == 0 ||
                                              event2[index].status == 1) {
                                            showDialog<String>(
                                                context: context,
                                                builder: (BuildContext
                                                        context) =>
                                                    AlertDialog(
                                                        title: const Text(
                                                            'Peringatan'),
                                                        content: Container(
                                                            height: 100,
                                                            width: 300,
                                                            child: Text(
                                                                "Event masih belum terselesaikan"))));
                                          } else if (event2[index].status ==
                                              2) {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        BuatLaporanEvent(
                                                          event_id:
                                                              event2[index].id,
                                                          penanggung_jawab:
                                                              event2[index]
                                                                  .penanggung_jawab
                                                                  .toString(),
                                                        )));
                                          } else {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        DetailEvent(
                                                          event_id:
                                                              event2[index].id,
                                                          penanggung_jawab:
                                                              event2[index]
                                                                  .penanggung_jawab
                                                                  .toString(),
                                                        )));
                                          }
                                        },
                                        child: Text(
                                          event2[index].id,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              decoration:
                                                  TextDecoration.underline),
                                        ),
                                      )))),
                              DataCell(Align(
                                  alignment: Alignment.center,
                                  child: Text(event2[index].nama,
                                      textAlign: TextAlign.center))),
                              DataCell(Align(
                                  alignment: Alignment.center,
                                  child: Text(event2[index].alamat.toString(),
                                      textAlign: TextAlign.center))),
                              DataCell(Align(
                                  alignment: Alignment.center,
                                  child: Text(event2[index].tanggal,
                                      textAlign: TextAlign.center))),
                              DataCell(Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                      event2[index].penanggung_jawab.toString(),
                                      textAlign: TextAlign.center))),
                              DataCell(Align(
                                  alignment: Alignment.center,
                                  child: SizedBox(
                                      width: 110,
                                      child: Text(
                                          event2[index].status == 0
                                              ? "Event belum dijalankan"
                                              : event2[index].status == 1
                                                  ? "Event sedang berlangsung"
                                                  : event2[index].status == 2
                                                      ? "Event telah selesai"
                                                      : "Laporan dalam tahap pengecekan",
                                          textAlign: TextAlign.center)))),
                              DataCell(Align(
                                alignment: Alignment.center,
                                child: event2[index].status == 3
                                    ? ListView.builder(
                                        shrinkWrap: true,
                                        itemCount:
                                            event2[index].persetujuan?.length,
                                        itemBuilder:
                                            (BuildContext ctxt, int index) {
                                          return Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                  "${event2[index].persetujuan![index]['jabatan']} "),
                                              Tooltip(
                                                  message: event2[index].persetujuan![index][
                                                              'status_laporan'] ==
                                                          1
                                                      ? "Laporan sedang diproses, harap cek berkala"
                                                      : event2[index].persetujuan![index][
                                                                  'status_laporan'] ==
                                                              2
                                                          ? "Laporan sudah disetujui oleh ${event2[index].persetujuan![index]['jabatan']}"
                                                          : "Proposal ditolak, silahkan tekan tombol X untuk melihat keterangan",
                                                  child: event2[index].persetujuan![index]
                                                              [
                                                              'status_laporan'] ==
                                                          1
                                                      ? Icon(Icons.info_outline,
                                                          color: Colors.yellow)
                                                      : event2[index].persetujuan![index]
                                                                  ['status_laporan'] ==
                                                              2
                                                          ? Icon(
                                                              Icons.check,
                                                              color:
                                                                  Colors.green,
                                                            )
                                                          : Icon(Icons.close, color: Colors.red))
                                            ],
                                          );
                                        })
                                    : Text("-"),
                              )),
                            ]))));
      } else {
        return ListView.builder(
            itemCount: event2.length,
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
                                text: "ID Event: ",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            TextSpan(text: event2[index].id),
                            TextSpan(
                                text: "\n\nNama Event: ",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            TextSpan(text: event2[index].nama),
                            TextSpan(
                                text: "\n\nLokasi: ",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            TextSpan(text: event2[index].alamat),
                            TextSpan(
                                text: "\n\nPenanggung Jawab: ",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            TextSpan(text: event2[index].penanggung_jawab),
                            TextSpan(
                                text: "\n\nHari, tanggal: ",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            TextSpan(text: event2[index].tanggal),
                            TextSpan(
                                text: "\n\nStatus Event: ",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            TextSpan(
                                text: event2[index].status == 0
                                    ? "Event belum dijalankan"
                                    : event2[index].status == 1
                                        ? "Event sedang berlangsung"
                                        : event2[index].status == 2
                                            ? "Event telah selesai"
                                            : "Laporan dalam tahap pengecekan"),
                            // TextSpan(
                            //     text: "\n\nStatus Laporan: ",
                            //     style: const TextStyle(
                            //         fontWeight: FontWeight.bold)),
                            // TextSpan(text: pembelian2[index].jumlah_barang),

                            TextSpan(
                                text: event2[index].status == 0 ||
                                        event2[index].status == 1
                                    ? "\n\nHalaman detail proposal"
                                    : event2[index].status == 2
                                        ? "\n\nBuat laporan event"
                                        : "\n\nHalaman detail event",
                                style: TextStyle(
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    if (event2[index].status == 0 ||
                                        event2[index].status == 1) {
                                    } else if (event2[index].status == 2) {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  BuatLaporanEvent(
                                                    event_id: event2[index].id,
                                                    penanggung_jawab:
                                                        event2[index]
                                                            .penanggung_jawab
                                                            .toString(),
                                                  )));
                                    } else {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => DetailEvent(
                                                    event_id: event2[index].id,
                                                    penanggung_jawab:
                                                        event2[index]
                                                            .penanggung_jawab
                                                            .toString(),
                                                  )));
                                    }
                                  }

                                )
                          ]))));
            });
      }
    }
  }

  // Widget buttonTambahP(BuildContext context) {
  //   return ElevatedButton(
  //                             style: ElevatedButton.styleFrom(
  //                                 backgroundColor:
  //                                     Color.fromARGB(255, 248, 172, 49)),
  //                             onPressed: () {},
  //                             child: Text(
  //                               "Tambah Penjualan",
  //                               style: TextStyle(
  //                                   color: Colors.black, fontSize: 16),
  //                             ));
  // }

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

  Widget buttonProposalSaya(BuildContext context) {
    return SizedBox(
        height: 50,
        width: 130,
        child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 248, 172, 49)),
            onPressed: () {
              setState(() {
                if (widget.type == 1) {
                  widget.type = 0;
                } else {
                  widget.type = 1;
                }
                build(context);
              });
            },
            child: Text(
              widget.type == 0 ? "Keseluruhan \nProposal" : "Proposal Saya",
              style: const TextStyle(color: Colors.black, fontSize: 16),
              textAlign: TextAlign.center,
            )));
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
                padding: const EdgeInsets.all(10),
                alignment: Alignment.topCenter,
                width: 400,
                child: widget.type == 1
                    ? MediaQuery.of(context).size.width > 390
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                                buttonProposalSaya(context),
                                kolomCari()
                              ])
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              buttonProposalSaya(context),
                              kolomCari()
                            ],
                          )
                    : kolomCari()),
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
                            tanggalMulai(context),
                            tanggalSelesai(context)
                          ])
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
    // if (idjabatan == "1" || idjabatan == "2") {
    return Scaffold(
        // appBar: AppBar(
        //   title: Text("Daftar Event"),
        // ),
        drawer: MyDrawer(),
        body: buildContainer(context));
    // } else {
    //   return Scaffold(
    //       // appBar: AppBar(
    //       //   title: Text("Daftar Event"),
    //       // ),
    //       body: buildContainer(context));
    // }
  }
}
