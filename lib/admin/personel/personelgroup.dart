import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pt_coronet_crown/class/personel/grup.dart';
import 'package:pt_coronet_crown/drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';

class PersonelGroup extends StatefulWidget {
  PersonelGroup({Key? key}) : super(key: key);
  @override
  _PersonelGroupState createState() {
    return _PersonelGroupState();
  }
}

String id_jabatan = "";

class _PersonelGroupState extends State<PersonelGroup> {
  String _txtcari = "";

  Future<String> fetchData() async {
    final response = await http.post(
        Uri.parse(
            "https://otccoronet.com/otc/admin/personel/personeldata/daftarpersonelgrup.php"),
        body: {'cari': ""});
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to read API');
    }
  }

  _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      id_jabatan = prefs.getString("idJabatan") ?? '';
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadData();
  }

  Widget daftargrup(data) {
    List<Grup> grup2 = [];
    Map json = jsonDecode(data);
    if (json['result'] == "error") {
      return DataTable(
          headingRowColor:
              MaterialStateColor.resolveWith((states) => Colors.grey.shade600),
          columns: [
            DataColumn(label: Text("Nama")),
            DataColumn(label: Text("Total pegawai")),
            DataColumn(label: Text("TL")),
            DataColumn(label: Text("Cabang")),
            DataColumn(label: Text("Kota")),
            DataColumn(label: Text("Provinsi")),
            DataColumn(label: Text("SPV")),
            DataColumn(label: Text("Area")),
            DataColumn(label: Text("AM")),
            DataColumn(label: Text("Action")),
          ],
          rows: []);
    } else {
      for (var gru in json['data']) {
        Grup grup = Grup.fromJson(gru);
        grup2.add(grup);
      }
      if (MediaQuery.of(context).size.width >= 850) {
        return DataTable(
            border: TableBorder(
                verticalInside: BorderSide(
                    width: 1,
                    style: BorderStyle.solid,
                    color: Color.fromARGB(75, 0, 0, 0))),
            columnSpacing: 10,
            headingRowColor: MaterialStateColor.resolveWith(
                (states) => Colors.grey.shade600),
            columns: [
              DataColumn(
                  label: Expanded(
                      child: Text(
                "Nama",
                textAlign: TextAlign.center,
              ))),
              DataColumn(
                  label: Expanded(
                      child: Text("Total \nPegawai",
                          textAlign: TextAlign.center))),
              DataColumn(
                  label:
                      Expanded(child: Text("TL", textAlign: TextAlign.center))),
              DataColumn(
                  label: Expanded(
                      child: Text("Cabang", textAlign: TextAlign.center))),
              DataColumn(
                  label: Expanded(
                      child: Text("Kota", textAlign: TextAlign.center))),
              DataColumn(
                  label: Expanded(
                      child: Text("Provinsi", textAlign: TextAlign.center))),
              DataColumn(
                  label: Expanded(
                      child: Text("SPV", textAlign: TextAlign.center))),
              DataColumn(
                  label: Expanded(
                      child: Text("Area", textAlign: TextAlign.center))),
              DataColumn(
                  label:
                      Expanded(child: Text("AM", textAlign: TextAlign.center))),
              DataColumn(
                  label: Expanded(
                      child: Text("Action", textAlign: TextAlign.center))),
            ],
            rows: List<DataRow>.generate(
                grup2.length,
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
                              child: Text(
                                  "${grup2[index].id} - \n${grup2[index].nama_grup}",
                                  textAlign: TextAlign.center))),
                          DataCell(Align(
                              alignment: Alignment.center,
                              child: Text(
                                  grup2[index].jumlah_pegawai.toString(),
                                  textAlign: TextAlign.center))),
                          DataCell(Align(
                              alignment: Alignment.center,
                              child: Text(
                                  grup2[index].tl == null
                                      ? "-"
                                      : grup2[index].tl.toString(),
                                  textAlign: TextAlign.center))),
                          DataCell(Align(
                              alignment: Alignment.center,
                              child: Text(grup2[index].nama_cabang,
                                  textAlign: TextAlign.center))),
                          DataCell(Align(
                              alignment: Alignment.center,
                              child: Text(grup2[index].kota,
                                  textAlign: TextAlign.center))),
                          DataCell(Align(
                              alignment: Alignment.center,
                              child: Text(grup2[index].provinsi,
                                  textAlign: TextAlign.center))),
                          DataCell(Align(
                              alignment: Alignment.center,
                              child: Text(
                                  grup2[index].spv == null
                                      ? "-"
                                      : grup2[index].spv.toString(),
                                  textAlign: TextAlign.center))),
                          DataCell(Align(
                              alignment: Alignment.center,
                              child: Text(grup2[index].area,
                                  textAlign: TextAlign.center))),
                          DataCell(Align(
                              alignment: Alignment.center,
                              child: Text(
                                  grup2[index].am == null
                                      ? "-"
                                      : grup2[index].am.toString(),
                                  textAlign: TextAlign.center))),
                          DataCell(
                            Align(
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Tooltip(
                                      message: 'Assign Personnel',
                                      child: IconButton(
                                        icon: Icon(Icons.person_add),
                                        iconSize: 20,
                                        onPressed: () {},
                                      ),
                                    ),
                                    Tooltip(
                                      message: 'Edit group',
                                      child: IconButton(
                                        icon: Icon(Icons.edit),
                                        iconSize: 20,
                                        onPressed: () {},
                                      ),
                                    ),
                                    Tooltip(
                                      message: 'Delete group',
                                      child: IconButton(
                                        icon: Icon(Icons.delete),
                                        iconSize: 20,
                                        onPressed: () {},
                                      ),
                                    ),
                                  ],
                                )),
                          )
                        ])));
      } else {
        return ListView.builder(
            itemCount: grup2.length,
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
                      padding: EdgeInsets.only(left: 10, top: 10, bottom: 10),
                      child: RichText(
                          text: TextSpan(
                              style: TextStyle(
                                fontSize: 13.0,
                                color: Colors.black,
                              ),
                              children: [
                            TextSpan(
                                text: "Nama: ",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            TextSpan(text: grup2[index].nama_grup),
                            TextSpan(
                                text: ", Total pegawai: ",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            TextSpan(
                                text: grup2[index].jumlah_pegawai.toString()),
                            TextSpan(
                                text: "\n\nCabang: ",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            TextSpan(text: grup2[index].nama_cabang),
                            TextSpan(
                                text: "\nTL: ",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            TextSpan(text: grup2[index].tl),
                            TextSpan(
                                text: "\n\nKota: ",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            TextSpan(text: grup2[index].kota),
                            TextSpan(
                                text: ", Provinsi: ",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            TextSpan(text: grup2[index].provinsi),
                            TextSpan(
                                text: "\nSPV: ",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            TextSpan(text: grup2[index].spv),
                            TextSpan(
                                text: "\n\nArea: ",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            TextSpan(text: grup2[index].area),
                            TextSpan(
                                text: ", AM: ",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            TextSpan(text: "${grup2[index].am}\n\n"),
                          ]))));
            });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (id_jabatan == "1") {
      return Scaffold(
          // appBar: AppBar(
          //   title: Text("Personnel Group"),
          // ),
          // drawer: MyDrawer(),
          body: Container(
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
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Color.fromARGB(255, 248, 172, 49)),
                          onPressed: () {
                            Navigator.popAndPushNamed(context, "tambahgrup");
                          },
                          child: Text(
                            "Add New Group",
                            style: TextStyle(color: Colors.black, fontSize: 16),
                          )),
                      Container(
                        height: 50,
                        width: 175,
                        child: TextFormField(
                          decoration: const InputDecoration(
                            icon: Icon(Icons.search),
                            labelText: 'Cari Group',
                          ),
                          onChanged: (value) {
                            _txtcari = value;
                            // bacaData();
                          },
                        ),
                      )
                    ]),
              ),
              Container(
                  padding: EdgeInsets.only(left: 5, right: 5),
                  alignment: Alignment.topCenter,
                  height: MediaQuery.of(context).size.height,
                  child: FutureBuilder(
                      future: fetchData(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return daftargrup(snapshot.data.toString());
                        } else {
                          return Center(child: CircularProgressIndicator());
                        }
                      }))
            ],
          ),
        ),
      ));
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text("Personnel Group"),
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
    }
  }
}
