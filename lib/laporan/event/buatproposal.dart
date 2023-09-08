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

List existedPersonil = [],
    existedGimmick = [],
    existedProduct = [],
    existedTarget = [];

class dynamicWidgetPersonil extends StatelessWidget {
  String id_cabang;
  dynamicWidgetPersonil({super.key, required this.id_cabang});

  String username = "";
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
        emptyBuilder: (context, searchEntry) => Center(
          child: Text("Tidak ada data ditemukan"),
        ),
        onFind: (text) async {
          Map json;
          var response = await http.post(
              Uri.parse(
                  "https://otccoronet.com/otc/laporan/event/properties/eventpersonel.php"),
              body: {
                'cari': text,
                'id': id_cabang,
                'existedPersonil': jsonEncode(existedPersonil)
              });

          if (response.statusCode == 200) {
            json = jsonDecode(response.body);
            pengguna = json['data'];
          }
          return pengguna as List<dynamic>;
        },
        onChanged: (value) {
          if (existedPersonil.isEmpty) {
            existedPersonil.add("'${value['username']}'");
          } else {
            if (username != "") {
              int index = existedPersonil.indexWhere(
                  (parameter) => parameter.startsWith("'$username'"));
              existedPersonil[index] = "'${value['username']}'";
            } else {
              existedPersonil.add("'${value['username']}'");
            }
          }
          username = value['username'];
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
  int quantity = 0, harga = 0, id = 0;
  List gimmick = [];
  Widget comboGimmick() {
    return SizedBox(
        width: 480,
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          SizedBox(
            width: 400,
            child: DropdownSearch<dynamic>(
                dropdownSearchDecoration: InputDecoration(
                  labelText: "Daftar Gimmick",
                ),
                mode: Mode.MENU,
                showSearchBox: true,
                emptyBuilder: (context, searchEntry) => Center(
                      child: Text("Tidak ada data ditemukan"),
                    ),
                onFind: (text) async {
                  Map json;
                  var response = await http.post(
                      Uri.parse(
                          "https://otccoronet.com/otc/admin/gimmick/daftargimmickcabang.php"),
                      body: {
                        'cari': text,
                        'id': id_cabang,
                        'existedGimmick': existedGimmick
                      });

                  if (response.statusCode == 200) {
                    json = jsonDecode(response.body);
                    gimmick = json['data'];
                  }
                  return gimmick as List<dynamic>;
                },
                onChanged: (value) {
                  if (existedGimmick.isEmpty) {
                    existedGimmick.add(id);
                  } else {
                    if (id != 0) {
                      int index = existedGimmick
                          .indexWhere((parameter) => parameter.startsWith(id));
                      existedGimmick[index] = id;
                    } else {
                      existedGimmick.add(id);
                    }
                  }
                  id = value['id'];
                  harga = value['harga'];
                },
                itemAsString: (item) =>
                    "${item['barang']} - Rp. ${NumberFormat('###,000').format(item['harga'])}/pcs"),
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
              ))
        ]));
  }

  @override
  Widget build(BuildContext context) {
    return comboGimmick();
  }
}

class dynamicWidgetProduct extends StatelessWidget {
  String id_cabang;
  dynamicWidgetProduct({super.key, required this.id_cabang});
  int harga = 0, id = 0;
  List produk = [];
  Widget comboGimmick() {
    return SizedBox(
        width: 480,
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          SizedBox(
            width: 330,
            child: DropdownSearch<dynamic>(
                dropdownSearchDecoration: InputDecoration(
                  labelText: "Daftar Produk",
                ),
                mode: Mode.MENU,
                showSearchBox: false,
                onFind: (text) async {
                  Map json;
                  var response = await http.post(
                      Uri.parse(
                          "https://otccoronet.com/otc/admin/product/daftarproductcabang.php"),
                      body: {
                        'idCabang': id_cabang,
                        'existedProduct': existedProduct
                      });

                  if (response.statusCode == 200) {
                    json = jsonDecode(response.body);
                    produk = json['data'];
                  }
                  return produk as List<dynamic>;
                },
                onChanged: (value) {
                  if (existedProduct.isEmpty) {
                    existedProduct.add(id);
                  } else {
                    if (id != 0) {
                      int index = existedProduct
                          .indexWhere((parameter) => parameter.startsWith(id));
                      existedProduct[index] = id;
                    } else {
                      existedProduct.add(id);
                    }
                  }
                  id = value['id'];
                  harga = value['harga'];
                },
                itemAsString: (item) => item['barang']),
          ),
          SizedBox(
              width: 110,
              height: 55,
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Harga satuan (dalam Rp)',
                ),
                onChanged: (value) {
                  harga = int.parse(value);
                },
              ))
        ]));
  }

  @override
  Widget build(BuildContext context) {
    return comboGimmick();
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
  int id = 0;
  String isiTarget = "";
  dynamicWidgetTarget({super.key});
  @override
  _dynamicWidgetTargetState createState() {
    return _dynamicWidgetTargetState();
  }
}

class _dynamicWidgetTargetState extends State<dynamicWidgetTarget> {
  List parameter = [];
  double targetWidth = 480, textfieldWidth = 0;
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
              body: {'existedTarget': existedTarget});
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
            if (existedTarget.isEmpty) {
              existedTarget.add(widget.id);
            } else {
              if (widget.id != 0) {
                int index = existedTarget
                    .indexWhere((parameter) => parameter.startsWith(widget.id));
                existedTarget[index] = widget.id;
              } else {
                existedTarget.add(widget.id);
              }
            }
            widget.id = value['id'];

            if (value['parameter'].contains("Estimasi") ||
                value['parameter'].contains("Penjualan")) {
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
                  onChanged: (value) {
                    widget.isiTarget = value;
                  },
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
  TextEditingController startTimeController = TextEditingController(),
      endTimeController = TextEditingController(),
      dateController = TextEditingController();
  String id_kota = "",
      id_event = "",
      alamat = "",
      kota = "",
      provinsi = "",
      nama = "",
      date = "",
      strategi = "",
      tujuan = "",
      latarBelakang = "",
      id_kecamatan = "",
      id_kelurahan = "";
  List personel = [],
      target = [],
      gimmick = [],
      kebutuhanTambahan = [],
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
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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

  void submit(BuildContext context) async {
    final response = await http.post(
        Uri.parse("https://otccoronet.com/otc/laporan/event/buatproposal.php"),
        body: {
          'id': "$id_event/$date",
          'nama': nama,
          'id_kelurahan': id_kelurahan,
          'lokasi': alamat,
          'tanggal': date,
          'waktu_mulai': "${startTimeController.text}:00",
          'waktu_selesai': "${endTimeController.text}:00",
          'strategi': strategi,
          'tujuan': tujuan,
          'latar_belakang': latarBelakang,
          'personil': jsonEncode(personel),
          'target': jsonEncode(target),
          'kebutuhan_tambahan': jsonEncode(kebutuhanTambahan),
          'gimmick': jsonEncode(gimmick),
          'id_tipe': "1",
          'id_cabang': widget.id_cabang,
          "username": widget.username
        });
    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      if (json['result'] == 'success') {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Laporan telah diajukan')));
        Navigator.popAndPushNamed(context, "/daftarproposal");
      }
      // else if (json['Error'] ==
      //     "Got a packet bigger than 'max_allowed_packet' bytes") {
      //   setState(() {
      //     warningDialog(context, "Ukuran gambar terlalu besar");
      //   });
      // } else {
      //   setState(() {
      //     warningDialog(context,
      //         "${json['Error']}\nSilahkan contact leader anda untuk menambahkan jumlah stock pada sistem");
      //   });

      // }
    } else {
      throw Exception('Failed to read API');
    }
  }

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
                  if (value != null) {
                    startTimeController.text =
                        '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
                  }
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
                if (value != null) {
                  setState(() {
                    endTimeController.text =
                        '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
                  });
                }
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
                          existedPersonil.removeAt(index);
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
                          existedGimmick.removeAt(index);
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
                          existedTarget.removeAt(index);
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

  Widget buildLokasi() {
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
        onChanged: (value) {
          alamat = value;
        },
      )
    ]);
  }

  Widget buildLatarBelakang() {
    return Column(children: [
      Text(
        "LATAR BELAKANG",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      TextField(
        minLines: 1,
        maxLines: 50,
        decoration: const InputDecoration(
          labelText: 'Latar Belakang',
        ),
        onChanged: (value) {
          latarBelakang = value;
        },
      )
    ]);
  }

  Widget buildStrategi() {
    return Column(children: [
      Text("STRATEGI", style: TextStyle(fontWeight: FontWeight.bold)),
      TextField(
        minLines: 1,
        maxLines: 50,
        decoration: const InputDecoration(
          labelText: 'Strategi',
        ),
        onChanged: (value) {
          strategi = value;
        },
      )
    ]);
  }

  Widget buildTujuan() {
    return Column(children: [
      Text("TUJUAN", style: TextStyle(fontWeight: FontWeight.bold)),
      TextField(
        minLines: 1,
        maxLines: 50,
        decoration: const InputDecoration(
          labelText: 'Tujuan',
        ),
        onChanged: (value) {
          tujuan = value;
        },
      )
    ]);
  }

  Widget buildNamaId() {
    return Column(children: [
      Text("ID EVENT: ${id_event}/${date}",
          style: TextStyle(fontWeight: FontWeight.bold)),
      TextField(
        decoration: const InputDecoration(
          labelText: 'Nama Event',
        ),
        onChanged: (value) {
          nama = value;
        },
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
                    child: buildLokasi()),
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
                    child: buildLatarBelakang()),
                Container(
                    width: 500,
                    padding: EdgeInsets.only(left: 5),
                    child: buildTujuan()),
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
                    child: buildStrategi()),
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
              if (_formKey.currentState != null &&
                  !_formKey.currentState!.validate()) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Harap data yang kosong diisi kembali')));
              } else {
                dynamicPersonel
                    .forEach((widget) => personel.add(widget.username));
                dynamicKebutuhanTambahan.forEach((widget) =>
                    kebutuhanTambahan.add([widget.komponen, widget.estimasi]));
                dynamicGimmick.forEach((widget) =>
                    gimmick.add([widget.id, widget.harga, widget.quantity]));
                dynamicTarget.forEach(
                    (widget) => target.add([widget.id, widget.isiTarget]));
                showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                          title: const Text('Peringatan'),
                          content: Text(
                              "Apakah anda yakin hendak mem-finalisasi proposal? \nData pada proposal tidak dapat diubah, kecuali proposal tidak disetujui"),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                submit(context);
                              },
                              child: const Text('Iya'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, 'Tidak'),
                              child: const Text('Tidak'),
                            ),
                          ],
                        ));
              }
            },
            child: Text(
              'Submit',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
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
