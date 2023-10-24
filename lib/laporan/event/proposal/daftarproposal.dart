import 'dart:convert';
import 'package:pt_coronet_crown/class/transaksi/eventherocyn.dart';
// import "package:universal_html/html.dart";
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pt_coronet_crown/drawer.dart';
import 'package:pt_coronet_crown/laporan/event/proposal/detailproposal.dart';
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

class DaftarProposal extends StatefulWidget {
  int type;
  DaftarProposal({super.key, required this.type});
  @override
  _DaftarProposalState createState() {
    return _DaftarProposalState();
  }
}

class _DaftarProposalState extends State<DaftarProposal> {
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
        Uri.parse(
            "https://otccoronet.com/otc/laporan/event/daftarproposal.php"),
        body: {'startdate': startdate, 'enddate': enddate, 'cari': _txtcari});
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to read API');
    }
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

  Widget daftarProposal(data, context) {
    List<EventHerocyn> event2 = [];
    Map json = jsonDecode(data);
    if (json['result'] == "error") {
      return const Text(
        "Tidak ada proposal yang diajukan",
        style: TextStyle(fontWeight: FontWeight.bold),
      );
    } else {
      for (var pen in json['data']) {
        EventHerocyn event = EventHerocyn.fromJson(pen);
        event2.add(event);
      }
      // if (MediaQuery.of(context).size.width >= 740) {
      return Padding(
          padding: const EdgeInsets.only(left: 5, right: 5),
          child: widget.type == 1
              ? DataTable(
                  border: const TableBorder(
                      verticalInside: BorderSide(
                          width: 1,
                          style: BorderStyle.solid,
                          color: Color.fromARGB(75, 0, 0, 0))),
                  headingRowColor: MaterialStateColor.resolveWith(
                      (states) => Colors.grey.shade600),
                  columns: [
                    DataColumn(label: tableContent(true, "ID Event")),
                    DataColumn(label: tableContent(true, "Nama Event")),
                    DataColumn(label: tableContent(true, "Lokasi")),
                    DataColumn(
                        label: tableContent(true, "Tanggal \nPengajuan")),
                    DataColumn(label: tableContent(true, "Penanggung \nJawab")),
                    DataColumn(label: tableContent(true, "Status \nProposal")),
                    DataColumn(label: tableContent(true, "Tanggal \nEvent")),
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
                                        message: "Halaman Detail",
                                        child: TextButton(
                                            style: ButtonStyle(foregroundColor:
                                                MaterialStateProperty
                                                    .resolveWith<Color>(
                                                        (Set<MaterialState>
                                                            states) {
                                              if (states.contains(
                                                  MaterialState.hovered))
                                                return Colors.blue.shade400;
                                              else
                                                return Colors.blue.shade600;
                                            })),
                                            child: Text(event2[index].id,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                    decoration: TextDecoration
                                                        .underline)),
                                            onPressed: () => Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        DetailProposal(
                                                          event_id:
                                                              event2[index].id,
                                                          penanggung_jawab:
                                                              event2[index]
                                                                  .penanggung_jawab
                                                                  .toString(),
                                                        ))))))),
                                DataCell(
                                    tableContent(false, event2[index].nama)),
                                DataCell(
                                    tableContent(false, event2[index].alamat)),
                                DataCell(tableContent(
                                    false, event2[index].pengajuan)),
                                DataCell(tableContent(
                                    false, event2[index].penanggung_jawab)),
                                DataCell(Container(
                                    alignment: Alignment.topCenter,
                                    width: 100,
                                    height: 100,
                                    child: ListView.builder(
                                        shrinkWrap: true,
                                        itemCount:
                                            event2[index].persetujuan?.length,
                                        itemBuilder: (BuildContext ctxt,
                                                int index) =>
                                            Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                      "${event2[index].persetujuan![index]['jabatan']} "),
                                                  Tooltip(
                                                      message: event2[index]
                                                                      .persetujuan![index][
                                                                  'status_proposal'] ==
                                                              1
                                                          ? "Proposal sedang diproses, harap cek berkala"
                                                          : event2[index].persetujuan![index]['status_proposal'] ==
                                                                  2
                                                              ? "Proposal sudah disetujui oleh ${event2[index].persetujuan![index]['jabatan']}"
                                                              : "Proposal ditolak, silahkan tekan tombol X untuk melihat keterangan",
                                                      child: event2[index].persetujuan![index][
                                                                  'status_proposal'] ==
                                                              1
                                                          ? const Icon(Icons.info_outline,
                                                              color:
                                                                  Colors.yellow)
                                                          : event2[index].persetujuan![index]['status_proposal'] ==
                                                                  2
                                                              ? const Icon(
                                                                  Icons.check,
                                                                  color: Colors
                                                                      .green,
                                                                )
                                                              : const Icon(
                                                                  Icons.close,
                                                                  color: Colors.red))
                                                ])))),
                                DataCell(
                                    tableContent(false, event2[index].tanggal))
                              ])).toList())
              : DataTable(
                  border: const TableBorder(
                      verticalInside: BorderSide(
                          width: 1,
                          style: BorderStyle.solid,
                          color: Color.fromARGB(75, 0, 0, 0))),
                  headingRowColor: MaterialStateColor.resolveWith(
                      (states) => Colors.grey.shade600),
                  columns: [
                    DataColumn(label: tableContent(true, "ID Event")),
                    DataColumn(label: tableContent(true, "Nama Event")),
                    DataColumn(label: tableContent(true, "Lokasi")),
                    DataColumn(
                        label: tableContent(true, "Tanggal \nPengajuan")),
                    DataColumn(label: tableContent(true, "Penanggung \nJawab")),
                    DataColumn(label: tableContent(true, "Tanggal \nEvent")),
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
                                        message: "Halaman Detail",
                                        child: TextButton(
                                            style: ButtonStyle(foregroundColor:
                                                MaterialStateProperty
                                                    .resolveWith<Color>(
                                                        (Set<MaterialState>
                                                            states) {
                                              if (states.contains(
                                                  MaterialState.hovered))
                                                return Colors.blue.shade400;
                                              else
                                                return Colors.blue.shade600;
                                            })),
                                            child: Text(event2[index].id,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                    decoration: TextDecoration
                                                        .underline)),
                                            onPressed: () => Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        DetailProposal(
                                                          event_id:
                                                              event2[index].id,
                                                          penanggung_jawab:
                                                              event2[index]
                                                                  .penanggung_jawab
                                                                  .toString(),
                                                        ))))))),
                                DataCell(
                                    tableContent(false, event2[index].nama)),
                                DataCell(
                                    tableContent(false, event2[index].alamat)),
                                DataCell(tableContent(
                                    false, event2[index].pengajuan)),
                                DataCell(tableContent(
                                    false, event2[index].penanggung_jawab)),
                                DataCell(
                                    tableContent(false, event2[index].tanggal))
                              ])).toList()));
    }
  }

  Widget kolomCari() {
    return SizedBox(
      height: 50,
      width: 175,
      child: TextFormField(
        decoration: const InputDecoration(
          icon: Icon(Icons.search),
          labelText: 'Cari Proposal',
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

  Widget buttonKunjunganSaya(BuildContext context) {
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
              widget.type == 0 ? "Keseluruhan \nKunjungan" : "Kunjungan Saya",
              style: const TextStyle(color: Colors.black, fontSize: 16),
              textAlign: TextAlign.center,
            )));
  }

  Widget tanggalSelesai(BuildContext context) {
    return SizedBox(
      height: 60,
      width: 300,
      child: Row(children: [
        Expanded(
            child: TextFormField(
          decoration: const InputDecoration(
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
            child: const Icon(
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
          decoration: const InputDecoration(
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
            child: const Icon(
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
                padding: const EdgeInsets.all(10),
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
              const Text(
                "Pilih tanggal untuk melakukan filtering data",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            if (widget.type == 1)
              Container(
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.all(10),
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
                        return daftarProposal(
                            snapshot.data.toString(), context);
                      } else {
                        return const Center(child: CircularProgressIndicator());
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
        floatingActionButton: Tooltip(
            message: "Buat Proposal",
            child: FloatingActionButton(
              onPressed: () =>
                  Navigator.popAndPushNamed(context, "/ajukanproposal"),
              child: const Icon(Icons.add, color: Colors.white),
            )),
        drawer: MyDrawer(),
        body: buildContainer(context));
    // } else {
    //   return Scaffold(
    //       appBar: AppBar(
    //         title: Text("Daftar Proposal Event"),
    //       ),
    //       body: buildContainerDesktop(context));
    // }
  }
}

// DataCell(Align(
                        //     alignment: Alignment.center,
                        //     child: SizedBox(
                        //         width: 75,
                        //         child: Text(
                        //             "${element.nama_depan} \n${element.nama_belakang}",
                        //             textAlign: TextAlign.center),
                        //         // child: Tooltip(
                        //         //     message: "Unduh File proposal",
                        //         //     child: TextButton(
                        //         //       style: TextButton.styleFrom(
                        //         //         textStyle: const TextStyle(
                        //         //             fontWeight: FontWeight.normal),
                        //         //       ),
                        //         //       onPressed: () {
                        //         //         // if (kIsWeb) {
                        //         //         //   AnchorElement(
                        //         //         //       href:
                        //         //         //           "data:application/octet-stream;charset=utf-16le;base64,${element.proposal}")
                        //         //         //     ..setAttribute("download",
                        //         //         //         "proposal-${element.id}.pdf")
                        //         //         //     ..click();
                        //         //         // }
                        //         //       },
                        //         //       child: Text("File Proposal",
                        //         //           textAlign: TextAlign.center),
                        //         //     ))
                        //             ))),
