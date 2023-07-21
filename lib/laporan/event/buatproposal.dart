import 'dart:convert';
import 'dart:math';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:pt_coronet_crown/class/transaksi/eventherocyn.dart';
import 'package:measure_size/measure_size.dart';

class dynamicWidgetPersonil extends StatelessWidget {
  String id_cabang;
  dynamicWidgetPersonil({super.key, required this.id_cabang});

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
              body: {'cari': text, 'id': id_cabang});

          if (response.statusCode == 200) {
            json = jsonDecode(response.body);
            pengguna = json['data'];
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

class dynamicWidgetGimmick extends StatelessWidget {
  String id_cabang;
  dynamicWidgetGimmick({super.key, required this.id_cabang});
  String id = "";
  List gimmick = [];
  int quantity = 0;
  Widget comboPersonil() {
    return SizedBox(
        width: 480,
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          SizedBox(
            width: 400,
            child: DropdownSearch<dynamic>(
                dropdownSearchDecoration: InputDecoration(
                  labelText: "Jenis Gimmick",
                ),
                mode: Mode.MENU,
                showSearchBox: true,
                onFind: (text) async {
                  Map json;
                  var response = await http.post(
                      Uri.parse(
                          "https://otccoronet.com/otc/laporan/event/properties/eventpersonel.php"),
                      body: {'cari': text, 'id': id_cabang});

                  if (response.statusCode == 200) {
                    json = jsonDecode(response.body);
                    gimmick = json['data'];
                  }
                  return gimmick as List<dynamic>;
                },
                onChanged: (value) {
                  id = value['username'];
                },
                itemAsString: (item) => item['barang']),
          ),
          SizedBox(
              width: 75,
              height: 55,
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                ),
                onChanged: (value) {
                  quantity = int.parse(value);
                },
              )),
        ]));
  }

  @override
  Widget build(BuildContext context) {
    return comboPersonil();
  }
}

class dynamicWidgetKebutuhanTambahan extends StatelessWidget {
  String komponen = "";
  int estimasi = 0;
  Widget comboPersonil() {
    return SizedBox(
        width: 480,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
                width: 330,
                height: 55,
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Komponen',
                  ),
                  onChanged: (value) {
                    komponen = value;
                  },
                )),
            SizedBox(
                width: 110,
                height: 55,
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Estimasi Biaya (dalam Rp.)',
                  ),
                  onChanged: (value) {
                    estimasi = int.parse(value);
                  },
                ))
          ],
        ));
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
  String id_cabang, username;
  BuatProposal({super.key, required this.id_cabang, required this.username});
  @override
  _BuatProposalState createState() {
    return _BuatProposalState();
  }
}

class _BuatProposalState extends State<BuatProposal> {
  TextEditingController controllerLatarBelakang = TextEditingController(),
      controllerTujuan = TextEditingController(),
      controllerStrategi = TextEditingController(),
      startTimeController = TextEditingController(),
      endTimeController = TextEditingController(),
      dateController = TextEditingController();
  String id_kota = "",
      id_event = "",
      alamat = "",
      kota = "",
      provinsi = "",
      nama = "",
      date = "",
      time = "",
      id_kecamatan = "",
      id_kelurahan = "";
  List personel = [],
      target = [],
      gimmick = [],
      kebutuhanTambahan = [],
      parameter = [],
      kecamatan = [],
      kelurahan = [];
  List<dynamicWidgetPersonil> dynamicPersonel = [];
  List<dynamicWidgetTarget> dynamicTarget = [];
  List<dynamicWidgetGimmick> dynamicGimmick = [];
  List<dynamicWidgetKebutuhanTambahan> dynamicKebutuhanTambahan = [];
  double heightAddPersonel = 0,
      heightAddTarget = 0,
      heightAddGimmick = 0,
      heightAddKebutuhanTambahan = 0;

  addDynamicPersonel() {
    setState(() {
      if (personel.isNotEmpty) {
        personel = [];
      }
      dynamicPersonel.add(dynamicWidgetPersonil(id_cabang: widget.id_cabang));
      heightAddPersonel += 55;
    });
  }

  addDynamicGimmick() {
    setState(() {
      if (gimmick.isNotEmpty) {
        gimmick = [];
      }
      dynamicGimmick.add(dynamicWidgetGimmick(id_cabang: widget.id_cabang));
      heightAddGimmick += 55;
    });
  }

  addDynamicKebutuhanTambahan() {
    setState(() {
      if (kebutuhanTambahan.isNotEmpty) {
        kebutuhanTambahan = [];
      }
      dynamicKebutuhanTambahan.add(dynamicWidgetKebutuhanTambahan());
      heightAddKebutuhanTambahan += 55;
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

  void bacaData() async {
    final response = await http.post(
        Uri.parse(
            "https://otccoronet.com/otc/laporan/event/properties/lokasi.php"),
        body: {'id': widget.id_cabang, 'type': '0'});
    if (response.statusCode == 200) {
      setState(() {
        Map json = jsonDecode(response.body);
        kota = json['data'][0]['kota'];
        provinsi = json['data'][0]['provinsi'];
      });
    } else {
      throw Exception('Failed to read API');
    }
  }

  // void submit(BuildContext context) async {
  //   final response = await http.post(
  //       Uri.parse(
  //           "https://otccoronet.com/otc/laporan/penjualan/buatlaporan.php"),
  //       body: {
  //         'id': widget.id.toString(),
  //         'nama': nama,
  //         'lokasi': alamat,
  //         'tanggal': base64Image,
  //         'waktu_mulai': _diskon,
  //         'waktu_selesai': _ppn,
  //         'strategi': idCabang,
  //         'tujuan': _ppn,
  //         'latar_belakang': idCabang,
  //         'parameter': jsonEncode(parameter),
  //         'target': jsonEncode(target),
  //         'id_produk': jsonEncode(personel)
  //       });
  //   if (response.statusCode == 200) {
  //     Map json = jsonDecode(response.body);
  //     if (json['result'] == 'success') {
  //       if (!mounted) return;
  //       ScaffoldMessenger.of(context)
  //           .showSnackBar(SnackBar(content: Text('Sukses Menambah Data')));
  //       Navigator.popAndPushNamed(context, "/daftarproposal");
  //     }
  //     // else if (json['Error'] ==
  //     //     "Got a packet bigger than 'max_allowed_packet' bytes") {
  //     //   setState(() {
  //     //     warningDialog(context, "Ukuran gambar terlalu besar");
  //     //   });
  //     // } else {
  //     //   setState(() {
  //     //     warningDialog(context,
  //     //         "${json['Error']}\nSilahkan contact leader anda untuk menambahkan jumlah stock pada sistem");
  //     //   });

  //     // }
  //   } else {
  //     throw Exception('Failed to read API');
  //   }
  // }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    bacaData();
    initializeDateFormatting();
    dateController.text = DateFormat.yMMMMEEEEd('id').format(DateTime.now());
    date = DateTime.now().toString().substring(0, 10);
    startTimeController.text = DateFormat.Hm()
        .format(DateTime.now().copyWith(hour: 8, minute: 0, second: 0));
    endTimeController.text = DateFormat.Hm()
        .format(DateTime.now().copyWith(hour: 16, minute: 0, second: 0));
    int rand = Random().nextInt(100);
    setState(() {
      id_event = "${rand.toString()}/${widget.username}/${widget.id_cabang}";
    });
  }

  Widget datePicker() {
    return SizedBox(
      height: 55,
      width: 260,
      child: Row(children: [
        Expanded(
            child: TextFormField(
          decoration: InputDecoration(
            labelText: "Tanggal Event",
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

  Widget startTimePicker() {
    return SizedBox(
      height: 55,
      width: 125,
      child: Row(children: [
        Expanded(
            child: TextFormField(
          decoration: InputDecoration(
            labelText: "Mulai",
          ),
          controller: startTimeController,
        )),
        ElevatedButton(
            onPressed: () {
              showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              ).then((value) {
                setState(() {
                  startTimeController.text = value!.format(context);
                });
              });
            },
            child: Icon(
              Icons.access_time_outlined,
              color: Colors.white,
              size: 24.0,
            ))
      ]),
    );
  }

  Widget endTimePicker() {
    return SizedBox(
      height: 55,
      width: 125,
      child: Row(children: [
        Expanded(
            child: TextFormField(
          decoration: InputDecoration(
            labelText: "Selesai",
          ),
          controller: endTimeController,
        )),
        ElevatedButton(
            onPressed: () {
              showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              ).then((value) {
                setState(() {
                  endTimeController.text = value!.format(context);
                });
              });
            },
            child: Icon(
              Icons.access_time_outlined,
              color: Colors.white,
              size: 24.0,
            ))
      ]),
    );
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

  Widget addKebutuhanTambahan() {
    return Column(children: [
      Text(
        "KEBUTUHAN TAMBAHAN",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      SizedBox(
          height: heightAddKebutuhanTambahan,
          child: ListView.builder(
            itemCount: dynamicKebutuhanTambahan.length,
            itemBuilder: (_, index) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  dynamicKebutuhanTambahan[index],
                  Tooltip(
                    message: "Delete kebutuhan tambahan",
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          dynamicKebutuhanTambahan.removeAt(index);
                          heightAddKebutuhanTambahan -= 50;
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
              addDynamicKebutuhanTambahan();
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

  Widget addGimmick() {
    return Column(children: [
      Text(
        "GIMMICK",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      SizedBox(
          height: heightAddGimmick,
          child: ListView.builder(
            itemCount: dynamicGimmick.length,
            itemBuilder: (_, index) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  dynamicGimmick[index],
                  Tooltip(
                    message: "Delete gimmick",
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          dynamicGimmick.removeAt(index);
                          heightAddGimmick -= 50;
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
              addDynamicGimmick();
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
      RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 13.0,
            color: Colors.black,
          ),
          children: <TextSpan>[
            TextSpan(text: '\nKota: '),
            TextSpan(
                text: kota,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: ', Provinsi: '),
            TextSpan(
                text: provinsi,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
              height: 50,
              width: 240,
              child: DropdownSearch<dynamic>(
                dropdownSearchDecoration: InputDecoration(
                  labelText: "Kecamatan",
                ),
                mode: Mode.MENU,
                showSearchBox: true,
                onFind: (text) async {
                  Map json;
                  var response = await http.post(
                      Uri.parse(
                          "https://otccoronet.com/otc/laporan/event/properties/lokasi.php"),
                      body: {
                        'cari': text,
                        'id': widget.id_cabang,
                        'type': '1'
                      });
                  if (response.statusCode == 200) {
                    setState(() {
                      json = jsonDecode(response.body);
                      kecamatan = json['data'];
                    });
                  }
                  return kecamatan as List<dynamic>;
                },
                onChanged: (value) {
                  setState(() {
                    id_kecamatan = value['id'];
                  });
                },
                itemAsString: (item) => item['kecamatan'],
              )),
          SizedBox(
              height: 50,
              width: 240,
              child: DropdownSearch<dynamic>(
                dropdownSearchDecoration: InputDecoration(
                  labelText: "Kelurahan",
                ),
                mode: Mode.MENU,
                showSearchBox: true,
                onFind: (text) async {
                  Map json;
                  var response = await http.post(
                      Uri.parse(
                          "https://otccoronet.com/otc/laporan/event/properties/lokasi.php"),
                      body: {'cari': text, 'id': id_kecamatan, 'type': '2'});

                  if (response.statusCode == 200) {
                    json = jsonDecode(response.body);
                    setState(() {
                      if (json['result'] == "success") {
                        kelurahan = json['data'];
                      }
                    });
                  }
                  return kelurahan as List<dynamic>;
                },
                onChanged: (value) {
                  id_kelurahan = value['id'];
                },
                itemAsString: (item) => item['kelurahan'],
              )),
        ],
      ),
      TextField(
        // controller: controllerLatarBelakang,
        // minLines: 1,
        // maxLines: 50,
        decoration: const InputDecoration(
          labelText: 'Alamat',
        ),
      )
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

  Widget buildNamaId() {
    return Column(children: [
      Text("ID EVENT: $id_event",
          style: TextStyle(fontWeight: FontWeight.bold)),
      TextField(
        controller: controllerTujuan,
        decoration: const InputDecoration(
          labelText: 'Nama Event',
        ),
      )
    ]);
  }

  Widget tampilData(BuildContext context) {
    return Container(
      width: 1050,
      alignment: Alignment.topCenter,
      padding: EdgeInsets.only(top: 20, bottom: 20),
      child: Column(children: [
        Container(
          alignment: Alignment.topLeft,
          padding: EdgeInsets.only(top: 20),
          child: Table(
            children: [
              TableRow(children: [
                Container(
                    width: 500,
                    padding: EdgeInsets.only(right: 5),
                    child: buildNamaId()),
                Container(
                    width: 500,
                    padding: EdgeInsets.only(left: 5),
                    child: Column(
                      children: [
                        Text("TANGGAL DAN WAKTU EVENT",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              datePicker(),
                              startTimePicker(),
                              endTimePicker()
                            ])
                      ],
                    )),
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
                    child: lokasi()),
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
        Container(
          alignment: Alignment.topLeft,
          padding: EdgeInsets.only(top: 20),
          child: Table(
            children: [
              TableRow(children: [
                Container(
                    width: 500,
                    padding: EdgeInsets.only(right: 5),
                    child: addKebutuhanTambahan()),
                Container(
                    width: 500,
                    padding: EdgeInsets.only(left: 5),
                    child: addGimmick()),
              ])
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 50),
          height: 50,
          width: 1050,
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                print("Submit Data");
              });
            },
            child: Text(
              'Submit',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
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
    );
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
        body: SingleChildScrollView(
            child: Container(
                // width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.only(top: 20),
                alignment: Alignment.topCenter,
                // height: MediaQuery.of(context).size.height + 50,
                child: tampilData(context))));

    //ListView(children: [tampilData()])));
  }
}
