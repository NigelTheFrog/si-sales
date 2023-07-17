import 'dart:convert';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:pt_coronet_crown/class/transaksi/eventherocyn.dart';
import 'package:measure_size/measure_size.dart';

class dynamicWidgetPersonil extends StatefulWidget {
  String id_cabang;
  dynamicWidgetPersonil({super.key, required this.id_cabang});
  @override
  _dynamicWidgetPersonilState createState() {
    return _dynamicWidgetPersonilState();
  }
}

class _dynamicWidgetPersonilState extends State<dynamicWidgetPersonil> {
  String id = "";
  List pengguna = [];
  Widget comboPersonil() {
    return SizedBox(
      width: 480,
      child: DropdownSearch<dynamic>(
        dropdownSearchDecoration: InputDecoration(
          labelText: "Daftar Personil",
        ),
        mode: Mode.MENU,
        showSearchBox: true,
        onFind: (text) async {
          Map json;
          var response = await http.post(
              Uri.parse(
                  "https://otccoronet.com/otc/laporan/event/properties/eventpersonel.php"),
              body: {'cari': text, 'id': widget.id_cabang});

          if (response.statusCode == 200) {
            json = jsonDecode(response.body);
            setState(() {
              pengguna = json['data'];
            });
          }
          return pengguna as List<dynamic>;
        },
        onChanged: (value) {
          id = value['username'];
        },
        itemAsString: (item) =>
            "${item['username']} - ${item['nama_depan']} ${item['nama_belakang']} - ${item['jabatan']}",
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return comboPersonil();
  }
}

class dynamicWidgetTarget extends StatefulWidget {
  dynamicWidgetTarget({super.key});
  @override
  _dynamicWidgetTargetState createState() {
    return _dynamicWidgetTargetState();
  }
}

class _dynamicWidgetTargetState extends State<dynamicWidgetTarget> {
  int id = 0;
  String isiTarget = "";
  List parameter = [];
  double targetWidth = 450, textfieldWidth = 0;
  bool isNeedTextField = false;

  Widget comboTarget() {
    return DropdownSearch<dynamic>(
        dropdownSearchDecoration: InputDecoration(labelText: "Target"),
        mode: Mode.MENU,
        showSearchBox: false,
        onFind: (text) async {
          Map json;
          var response = await http.post(
            Uri.parse(
                "https://otccoronet.com/otc/laporan/event/properties/eventtarget.php"),
          );
          if (response.statusCode == 200) {
            json = jsonDecode(response.body);
            setState(() {
              parameter = json['data'];
            });
          }
          return parameter as List<dynamic>;
        },
        onChanged: (value) {
          setState(() {
            id = value['id'];
            isiTarget = value['parameter'];
            if (isiTarget.contains("Estimasi") ||
                isiTarget.contains("Penjualan")) {
              targetWidth = 370;
              textfieldWidth = 90;
              isNeedTextField = true;
            } else {
              targetWidth = 480;
              textfieldWidth = 0;
              isNeedTextField = false;
            }
          });
        },
        itemAsString: (item) =>
            item['parameter'].toString().contains("Pengguna") ||
                    item['parameter'].toString().contains("Event")
                ? "${item['parameter']} (${item['perhitungan']}%)"
                : item['parameter'].toString().contains("Estimasi")
                    ? "${item['parameter']} - ${item['perhitungan']} orang"
                    : item['parameter']);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 480,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          SizedBox(
            width: targetWidth,
            child: comboTarget(),
          ),
          if (isNeedTextField = true)
            SizedBox(
                width: textfieldWidth,
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Target PAP',
                  ),
                  keyboardType: TextInputType.number,
                )),
        ],
      ),
    );
  }
}

class BuatProposal extends StatefulWidget {
  String id_cabang;
  BuatProposal({super.key, required this.id_cabang});
  @override
  _BuatProposalState createState() {
    return _BuatProposalState();
  }
}

class _BuatProposalState extends State<BuatProposal> {
  TextEditingController controllerLatarBelakang = TextEditingController(),
      controllerTujuan = TextEditingController(),
      controllerStrategi = TextEditingController();
  List personel = [], target = [];
  List<dynamicWidgetPersonil> dynamicPersonel = [];
  List<dynamicWidgetTarget> dynamicTarget = [];
  double heightAddPersonel = 0, heightAddTarget = 0;

  addDynamicPersonel() {
    setState(() {
      if (personel.isNotEmpty) {
        personel = [];
      }
      dynamicPersonel.add(dynamicWidgetPersonil(id_cabang: widget.id_cabang));
      heightAddPersonel += 55;
    });
  }

  addDynamicTarget() {
    setState(() {
      if (target.isNotEmpty) {
        target = [];
      }
      dynamicTarget.add(dynamicWidgetTarget());
      heightAddTarget += 55;
    });
  }

  Widget addPersonel() {
    return Column(children: [
      Text(
        "PERSONIL",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      SizedBox(
          height: heightAddPersonel,
          child: ListView.builder(
            itemCount: dynamicPersonel.length,
            itemBuilder: (_, index) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  dynamicPersonel[index],
                  Tooltip(
                    message: "Delete personel",
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          dynamicPersonel.removeAt(index);
                          heightAddPersonel -= 50;
                        });
                      },
                      icon: Icon(Icons.delete),
                    ),
                  )
                ],
              );
            },
          )),
      Container(
        margin: EdgeInsets.only(top: 10),
        height: 50,
        width: 50,
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              addDynamicPersonel();
            });
          },
          child: Text(
            '+',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    ]);
  }

  Widget addTarget() {
    return Column(children: [
      Text(
        "TARGET",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      SizedBox(
          height: heightAddTarget,
          child: ListView.builder(
            itemCount: dynamicTarget.length,
            itemBuilder: (_, index) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  dynamicTarget[index],
                  Tooltip(
                    message: "Delete parameter",
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          dynamicTarget.removeAt(index);
                          heightAddTarget -= 55;
                          print(dynamicTarget);
                        });
                      },
                      icon: Icon(Icons.delete),
                    ),
                  )
                ],
              );
            },
          )),
      Container(
        margin: EdgeInsets.only(top: 10),
        height: 50,
        width: 50,
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              addDynamicTarget();
              print(dynamicTarget);
            });
          },
          child: Text(
            '+',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    ]);
  }

  Widget lokasi() {
    return Column(children: [
      Text(
        "LOKASI",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      
    ]);
  }

  Widget latarBelakang() {
    return Column(children: [
      Text(
        "LATAR BELAKANG",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      TextField(
        controller: controllerLatarBelakang,
        minLines: 1,
        maxLines: 50,
        decoration: const InputDecoration(
          labelText: 'Latar Belakang',
        ),
      )
    ]);
  }

  Widget strategi() {
    return Column(children: [
      Text("STRATEGI", style: TextStyle(fontWeight: FontWeight.bold)),
      TextField(
        controller: controllerStrategi,
        minLines: 1,
        maxLines: 50,
        decoration: const InputDecoration(
          labelText: 'Strategi',
        ),
      )
    ]);
  }

  Widget tujuan() {
    return Column(children: [
      Text("TUJUAN", style: TextStyle(fontWeight: FontWeight.bold)),
      TextField(
        controller: controllerTujuan,
        minLines: 1,
        maxLines: 50,
        decoration: const InputDecoration(
          labelText: 'Tujuan',
        ),
      )
    ]);
  }

  Widget tampilData(BuildContext context) {
    return SingleChildScrollView(
        child: Container(
      width: 1050,
      alignment: Alignment.topCenter,
      padding: EdgeInsets.only(top: 20, bottom: 20),
      child: Column(children: [
        // Align(
        //     alignment: Alignment.topLeft,
        //     child: Row(
        //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //         children: [
        //           Text("ID Event: ${widget.event_id}",
        //               textAlign: TextAlign.center,
        //               style:
        //                   TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        //           Text(
        //               "Penanggung Jawab: ${widget.nama_depan} ${widget.nama_belakang}",
        //               textAlign: TextAlign.center,
        //               style:
        //                   TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
        //         ])),
        Container(
          alignment: Alignment.topLeft,
          padding: EdgeInsets.only(top: 20),
          child: Table(
            children: [
              TableRow(children: [
                Container(width: 500, padding: EdgeInsets.only(right: 5)),
                //     child: lokasi()),
                Container(
                    width: 500,
                    padding: EdgeInsets.only(left: 5),
                    child: addPersonel()),
              ])
            ],
          ),
        ),
        Container(
          alignment: Alignment.topLeft,
          padding: EdgeInsets.only(top: 20),
          child: Table(
            children: [
              TableRow(children: [
                Container(
                    width: 500,
                    padding: EdgeInsets.only(right: 5),
                    child: latarBelakang()),
                Container(
                    width: 500,
                    padding: EdgeInsets.only(left: 5),
                    child: tujuan()),
              ])
            ],
          ),
        ),
        Container(
          alignment: Alignment.topLeft,
          padding: EdgeInsets.only(top: 20),
          child: Table(
            children: [
              TableRow(children: [
                Container(
                    width: 500,
                    padding: EdgeInsets.only(right: 5),
                    child: strategi()),
                Container(
                    width: 500,
                    padding: EdgeInsets.only(left: 5),
                    child: addTarget()),
              ])
            ],
          ),
        ),
        // Container(
        //   alignment: Alignment.topLeft,
        //   padding: EdgeInsets.only(top: 20),
        //   child: Table(
        //     children: [
        //       TableRow(children: [
        //         Container(
        //             width: 500,
        //             padding: EdgeInsets.only(right: 5),
        //             child: tabelKebutuhan()),
        //         Container(
        //             width: 500,
        //             padding: EdgeInsets.only(left: 5),
        //             child: tabelGimmick()),
        //       ])
        //     ],
        //   ),
        // ),
      ]),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Buat Proposal Event"),
          leading: BackButton(
            onPressed: () {
              Navigator.popAndPushNamed(context, "/daftarproposal");
            },
          ),
        ),
        body: Container(
            padding: EdgeInsets.only(top: 20),
            alignment: Alignment.topCenter,
            child: tampilData(context)));

    //ListView(children: [tampilData()])));
  }
}
