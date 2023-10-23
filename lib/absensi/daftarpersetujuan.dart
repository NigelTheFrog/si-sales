import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:pt_coronet_crown/class/admin/absen/absen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class DaftarPersetujuan extends StatefulWidget {
  DaftarPersetujuan({super.key});
  @override
  _DaftarPersetujuanState createState() => _DaftarPersetujuanState();
}

class _DaftarPersetujuanState extends State<DaftarPersetujuan> {
  String _txtcari = "";
  String username = "",
      id_jabatan = "",
      date = "",
      id_area = "",
      id_provinsi = "",
      id_grup = "";
  TextEditingController dateController = TextEditingController();

  Future<String> fetchData() async {
    final response = await http.post(
        Uri.parse("https://otccoronet.com/otc/account/absensi/daftarabsen.php"),
        body: {
          'id_jabatan': id_jabatan,
          'date': date,
          'cari': _txtcari,
          'type': "2",
          'id_grup': id_grup,
          'id_provinsi': id_provinsi,
          'id_area': id_area
        });
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to read API');
    }
  }

  void submit(BuildContext context, id, value) async {
    final response = await http.post(
        Uri.parse(
            "https://otccoronet.com/otc/account/absensi/buatkehadiran.php"),
        body: {
          'id': id,
          'value': value,
          "type": "2",
        });
    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      if (json['result'] == 'success') {
        if (!mounted) return;
        setState(() {
          // build(context);
        });
      }
    } else {
      throw Exception('Failed to read API');
    }
  }

  Future<String> fetchDataGambar(id_absen) async {
    final response = await http.post(
        Uri.parse("https://otccoronet.com/otc/account/absensi/daftarabsen.php"),
        body: {'id_absen': id_absen, "type": "4"});
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to read API');
    }
  }

  showBukti(id_absen) {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
            content: SizedBox(
                height: 500,
                width: 500,
                child: FutureBuilder(
                    future: fetchDataGambar(id_absen),
                    builder: (context, snapshot) {
                      if (snapshot.hasData &&
                          snapshot.connectionState == ConnectionState.done) {
                        Map json = jsonDecode(snapshot.data.toString());
                        return Image.memory(
                            base64Decode(json['data'][0]['bukti']));
                      } else {
                        return Center(child: CircularProgressIndicator());
                      }
                    }))));
  }

  _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString("username") ?? '';
      id_jabatan = prefs.getString("idJabatan") ?? '';
      id_provinsi = prefs.getString("username") ?? '';
      id_grup = prefs.getString("idGrup") ?? '';
      id_area = prefs.getString("username") ?? '';
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadData();
    initializeDateFormatting();
    dateController.text = DateFormat.yMMMMEEEEd('id').format(DateTime.now());
    date = DateTime.now().toString().substring(0, 10);
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
            child: DataTable(
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
                  DataColumn(label: tableContent(true, "Bukti")),
                  DataColumn(
                      label: tableContent(
                          true,
                          id_jabatan == "1" || id_jabatan == "2"
                              ? "Status\nValidasi"
                              : "Action")),
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
                              DataCell(tableContent(false, absen2[index].id)),
                              DataCell(tableContent(
                                  false, absen2[index].username.toString())),
                              DataCell(tableContent(false,
                                  "${absen2[index].nama_depan.toString()} ${absen2[index].nama_belakang.toString()}")),
                              DataCell(
                                  tableContent(false, absen2[index].tanggal)),
                              DataCell(
                                  tableContent(false, absen2[index].waktu)),
                              DataCell(Align(
                                  alignment: Alignment.center,
                                  child: IconButton(
                                      icon: Icon(Icons.remove_red_eye),
                                      onPressed: () =>
                                          showBukti(absen2[index].id)))),
                              DataCell(Align(
                                  alignment: Alignment.center,
                                  child: id_jabatan == "1" || id_jabatan == "2"
                                      ? tableContent(
                                          false,
                                          absen2[index].status == 10
                                              ? "Disetujui"
                                              : absen2[index].status == 11
                                                  ? "Ditolak"
                                                  : "Belum\nDiperiksa",
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Tooltip(
                                                message: "Setujui Permohonan",
                                                child: IconButton(
                                                    icon: Icon(
                                                      Icons.check,
                                                      color: Colors.green,
                                                    ),
                                                    onPressed: () => submit(
                                                        context,
                                                        absen2[index].id,
                                                        "10"))),
                                            Tooltip(
                                                message: "Tolak Permohonan",
                                                child: IconButton(
                                                    icon: Icon(
                                                      Icons.close,
                                                      color: Colors.red,
                                                    ),
                                                    onPressed: () => submit(
                                                        context,
                                                        absen2[index].id,
                                                        "11")))
                                          ],
                                        )))
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
                          child: RichText(
                              text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 13.0,
                                    color: Colors.black,
                                  ),
                                  children: [
                                TextSpan(
                                    text: "ID Absen: ",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                TextSpan(text: absen2[index].id),
                                TextSpan(
                                    text: "\n\nHari, tanggal: ",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                TextSpan(text: absen2[index].tanggal),
                                TextSpan(
                                    text: ", Waktu: ",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                TextSpan(text: absen2[index].waktu),
                                TextSpan(
                                    text: "\nAction: ",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                TextSpan(
                                    text: absen2[index].status == 0
                                        ? "Belum Check-Out"
                                        : absen2[index].status == 2
                                            ? "Belum Acc TL"
                                            : absen2[index].status == 3
                                                ? "Belum Acc SPV"
                                                : absen2[index].status == 4
                                                    ? "Belum Acc AM"
                                                    : absen2[index].status == 5
                                                        ? "Belum Acc Admin"
                                                        : "Sudah Check-Out"),
                                TextSpan(
                                    text: ", Bukti: ",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                WidgetSpan(
                                    alignment: PlaceholderAlignment.middle,
                                    child: IconButton(
                                        onPressed: () =>
                                            showBukti(absen2[index].id),
                                        icon: Icon(
                                          Icons.remove_red_eye,
                                          size: 25,
                                        ))),
                                TextSpan(
                                    text: "\nKeterangan: ",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                TextSpan(text: absen2[index].keterangan),
                              ]))))
                ],
              ));
            });
      }
    }
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

  Widget tanggalMulai(BuildContext context) {
    return SizedBox(
      height: 60,
      width: 300,
      child: Row(children: [
        Expanded(
            child: TextFormField(
          decoration: InputDecoration(
            labelText: "Tanggal",
          ),
          controller: dateController,
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
                  date = value.toString().substring(0, 10);
                  String formattedDate =
                      DateFormat.yMMMMEEEEd('id').format(value!);
                  dateController.text = formattedDate;
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
                width: 550,
                child: MediaQuery.of(context).size.width >= 550
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          kolomCari(),
                          tanggalMulai(context),
                        ],
                      )
                    : Column(
                        children: <Widget>[
                          kolomCari(),
                          tanggalMulai(context),
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

  @override
  Widget build(BuildContext context) {
    // if (idjabatan != "3") {
    //   if (idjabatan == "1" || idjabatan == "2") {
    return Scaffold(
        // appBar: AppBar(
        //   title: Text("Daftar Pembelian"),
        // ),
        // drawer: MyDrawer(),

        body: buildContainer(context));
  }
}
