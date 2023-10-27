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
import 'package:pt_coronet_crown/customicon/event_chart_icons.dart';
import 'package:pt_coronet_crown/customicon/produk_icons.dart';

List existedPersonil = [],
    existedGimmick = [],
    existedProduct = [],
    existedTarget = [];

class dynamicWidgetPersonil extends StatelessWidget {
  String id_cabang;
  dynamicWidgetPersonil({super.key, required this.id_cabang});

  String username = "";
  List pengguna = [];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 380,
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
            "${item['username']} - ${item['nama_depan']} ${item['nama_belakang']}",
      ),
    );
  }
}

class dynamicWidgetGimmick extends StatelessWidget {
  String id_cabang;
  dynamicWidgetGimmick({super.key, required this.id_cabang});
  int quantity = 0, harga = 0, id = 0;
  List gimmick = [];
  Widget comboGimmick() {
    return SizedBox(
        width: 380,
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          SizedBox(
              height: 55,
              width: 300,
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
                          //'existedGimmick': existedGimmick
                        });
                    if (response.statusCode == 200) {
                      json = jsonDecode(response.body);
                      gimmick = json['data'];
                    }
                    return gimmick as List<dynamic>;
                  },
                  onChanged: (value) {
                    // if (existedGimmick.isEmpty) {
                    //   existedGimmick.add(id);
                    // } else {
                    //   if (id != 0) {
                    //     int index = existedGimmick.indexWhere(
                    //         (parameter) => parameter.startsWith(id));
                    //     existedGimmick[index] = id;
                    //   } else {
                    //     existedGimmick.add(id);
                    //   }
                    // }
                    id = value['id'];
                    harga = value['harga'];
                  },
                  itemAsString: (item) => item['barang'])
              // "${item['barang']} - Rp. ${NumberFormat('###,000').format(item['harga'])}/pcs"),
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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 380,
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          SizedBox(
              width: 250,
              height: 55,
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
                          // 'existedProduct': existedProduct
                        });

                    if (response.statusCode == 200) {
                      json = jsonDecode(response.body);
                      produk = json['data'];
                    }
                    return produk as List<dynamic>;
                  },
                  onChanged: (value) {
                    // if (existedProduct.isEmpty) {
                    //   existedProduct.add(id);
                    // } else {
                    //   if (id != 0) {
                    //     int index = existedProduct
                    //         .indexWhere((parameter) => parameter.startsWith(id));
                    //     existedProduct[index] = id;
                    //   } else {
                    //     existedProduct.add(id);
                    //   }
                    // }
                    id = value['id'];
                    harga = value['harga'];
                  },
                  itemAsString: (item) => item['jenis'])),
          SizedBox(
              width: 120,
              height: 55,
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Harga satuan',
                ),
                onChanged: (value) {
                  harga = int.parse(value);
                },
              ))
        ]));
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
  double targetWidth = 380, textfieldWidth = 0;
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
            //body: {'existedTarget': existedTarget}
          );
          if (response.statusCode == 200) {
            json = jsonDecode(response.body);
            setState(() {
              parameter = json['data'];
            });
          }
          return parameter;
        },
        onChanged: (value) {
          setState(() {
            // if (existedTarget.isEmpty) {
            //   existedTarget.add(widget.id);
            // } else {
            //   if (widget.id != 0) {
            //     int index = existedTarget
            //         .indexWhere((parameter) => parameter.startsWith(widget.id));
            //     existedTarget[index] = widget.id;
            //   } else {
            //     existedTarget.add(widget.id);
            //   }
            // }
            widget.id = value['id'];

            if (value['parameter'].contains("Estimasi") ||
                value['parameter'].contains("Penjualan")) {
              targetWidth = 280;
              textfieldWidth = 90;
              isNeedTextField = true;
            } else {
              targetWidth = 380;
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
      width: 380,
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
  int index = 0;
  TextEditingController startTimeController = TextEditingController(),
      endTimeController = TextEditingController(),
      dateController = TextEditingController(),
      controllerTujuan = TextEditingController(),
      controllerStrategi = TextEditingController(),
      controllerLatarBelakang = TextEditingController(),
      controllerAlamat = TextEditingController();
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
      kelurahan = [],
      product = [];
  List<dynamicWidgetPersonil> dynamicPersonel = [];
  List<dynamicWidgetTarget> dynamicTarget = [];
  List<dynamicWidgetGimmick> dynamicGimmick = [];
  List<dynamicWidgetKebutuhanTambahan> dynamicKebutuhanTambahan = [];
  List<dynamicWidgetProduct> dynamicproduct = [];
  double heightAddPersonel = 0,
      heightAddTarget = 0,
      heightAddGimmick = 0,
      heightAddKebutuhanTambahan = 0,
      heightAddproduct = 0;
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

  addDynamicProduct() {
    setState(() {
      if (product.isNotEmpty) {
        product = [];
      }
      dynamicproduct.add(dynamicWidgetProduct(id_cabang: widget.id_cabang));
      heightAddproduct += 55;
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
    setState(() {
      id_event = "${widget.username}/${widget.id_cabang}";
    });
  }

  Widget startDatePicker() {
    return SizedBox(
      height: 55,
      width: 260,
      child: Row(children: [
        Expanded(
            child: TextFormField(
          decoration: InputDecoration(
            labelText: "Tanggal Event Mulai",
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

  Widget endDatePicker() {
    return SizedBox(
      height: 55,
      width: 260,
      child: Row(children: [
        Expanded(
            child: TextFormField(
          decoration: InputDecoration(
            labelText: "Tanggal Event Selesai",
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
    return Container(
      padding: EdgeInsets.only(left: 10),
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
    return Container(
      padding: EdgeInsets.only(left: 10),
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
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              addDynamicPersonel();
            });
          },
          child: Icon(Icons.add, color: Colors.white),
        ),
      ),
    ]);
  }

  Widget addKebutuhanTambahan() {
    return Column(children: [
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
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              addDynamicKebutuhanTambahan();
            });
          },
          child: Icon(Icons.add, color: Colors.white),
        ),
      ),
    ]);
  }

  Widget addGimmick() {
    return Column(children: [
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
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              addDynamicGimmick();
            });
          },
          child: Icon(Icons.add, color: Colors.white),
        ),
      ),
    ]);
  }

  Widget addTarget() {
    return Column(children: [
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
          child: ElevatedButton(
              onPressed: () {
                setState(() {
                  addDynamicTarget();
                });
              },
              child: Icon(Icons.add, color: Colors.white)))
    ]);
  }

  Widget addProduct() {
    return Column(children: [
      SizedBox(
          height: heightAddproduct,
          child: ListView.builder(
            itemCount: dynamicproduct.length,
            itemBuilder: (_, index) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  dynamicproduct[index],
                  Tooltip(
                    message: "Delete parameter",
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          dynamicproduct.removeAt(index);
                          heightAddproduct -= 55;
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
                  addDynamicProduct();
                });
              },
              child: Icon(Icons.add, color: Colors.white)))
    ]);
  }

  Widget multiTabNavigator(indexNow, icon, text) {
    return GestureDetector(
        onTap: () {
          setState(() {
            index = indexNow;
          });
        },
        child: Container(
          width: 180,
          height: 55,
          decoration: BoxDecoration(
            color: index == indexNow ? Colors.orange : Colors.grey,
            borderRadius: BorderRadius.all(Radius.circular(30)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                  padding: EdgeInsets.only(left: 5),
                  child: Icon(
                    icon,
                    color: Colors.white,
                  )),
              Padding(
                  padding: EdgeInsets.only(left: 5),
                  child: Text(
                    text,
                    style: TextStyle(color: Colors.white),
                  ))
            ],
          ),
        ));
  }

  Widget multiTabIndicator() {
    return Container(
        alignment: Alignment.topCenter,
        width: 400,
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          multiTabNavigator(0, Icons.info_outline, "General Information"),
          multiTabNavigator(1, EventChart.chart_line, "Target"),
        ]));
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
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
              width: 300,
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
              width: 300,
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
          SizedBox(
              width: 300,
              child: TextField(
                  controller: controllerAlamat,
                  decoration: const InputDecoration(
                    labelText: 'Alamat',
                  ),
                  onChanged: (value) {
                    alamat = value;
                  }))
        ],
      ),
    ]);
  }

  Widget buildGeneralInformation() {
    Widget personilWidget = Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 5,
        child: ExpansionTile(
            title: Text(
              "PERSONIL",
              textAlign: TextAlign.center,
              style: (TextStyle(fontWeight: FontWeight.bold)),
            ),
            children: [
              Container(
                  margin:
                      EdgeInsets.only(left: 40, right: 40, top: 10, bottom: 10),
                  child: addPersonel())
            ]));
    Widget lokasiWidget = Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 5,
        child: ExpansionTile(
            title: Text(
              "LOKASI",
              textAlign: TextAlign.center,
              style: (TextStyle(fontWeight: FontWeight.bold)),
            ),
            children: [
              Container(
                  margin:
                      EdgeInsets.only(left: 40, right: 40, top: 10, bottom: 10),
                  child: buildLokasi())
            ]));
    Widget latarBelakangWidget = Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 5,
        child: ExpansionTile(
            title: Text(
              "LATAR BELAKANG",
              textAlign: TextAlign.center,
              style: (TextStyle(fontWeight: FontWeight.bold)),
            ),
            children: [
              Container(
                  margin:
                      EdgeInsets.only(left: 40, right: 40, top: 10, bottom: 10),
                  child: TextField(
                      controller: controllerLatarBelakang,
                      minLines: 1,
                      maxLines: 50,
                      decoration: const InputDecoration(
                        labelText: 'Latar Belakang',
                      ),
                      onChanged: (value) {
                        latarBelakang = value;
                      }))
            ]));
    Widget tujuanWidget = Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 5,
        child: ExpansionTile(
            title: Text(
              "TUJUAN",
              textAlign: TextAlign.center,
              style: (TextStyle(fontWeight: FontWeight.bold)),
            ),
            children: [
              Container(
                  margin:
                      EdgeInsets.only(left: 40, right: 40, top: 10, bottom: 10),
                  child: TextField(
                      controller: controllerTujuan,
                      minLines: 1,
                      maxLines: 50,
                      decoration: const InputDecoration(
                        labelText: 'Tujuan',
                      ),
                      onChanged: (value) {
                        tujuan = value;
                      }))
            ]));
    Widget strategiWidget = Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 5,
        child: ExpansionTile(
            title: Text(
              "STRATEGI ",
              textAlign: TextAlign.center,
              style: (TextStyle(fontWeight: FontWeight.bold)),
            ),
            children: [
              Container(
                  margin:
                      EdgeInsets.only(left: 40, right: 40, top: 10, bottom: 10),
                  child: TextField(
                      controller: controllerStrategi,
                      minLines: 1,
                      maxLines: 50,
                      decoration: const InputDecoration(
                        labelText: 'Strategi',
                      ),
                      onChanged: (value) {
                        strategi = value;
                      }))
            ]));
    Widget tanggalWidget = Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 5,
        child: ExpansionTile(
            title: Text(
              "TANGGAL EVENT",
              textAlign: TextAlign.center,
              style: (TextStyle(fontWeight: FontWeight.bold)),
            ),
            children: [
              Container(
                  margin:
                      EdgeInsets.only(left: 40, right: 40, top: 10, bottom: 10),
                  child: Column(
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [startDatePicker(), startTimePicker()]),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [endDatePicker(), endTimePicker()])
                    ],
                  ))
            ]));
    if (MediaQuery.of(context).size.width >= 720) {
      return Table(children: [
        TableRow(children: [
          Container(
              width: 500,
              padding: EdgeInsets.only(right: 5, bottom: 20),
              child: lokasiWidget),
          Container(
              width: 500,
              padding: EdgeInsets.only(left: 5, bottom: 20),
              child: tanggalWidget)
        ]),
        TableRow(children: [
          Container(
              width: 500,
              padding: EdgeInsets.only(right: 5, bottom: 20),
              child: latarBelakangWidget),
          Container(
              width: 500,
              padding: EdgeInsets.only(left: 5, bottom: 20),
              child: personilWidget)
        ]),
        TableRow(children: [
          Container(
              width: 500,
              padding: EdgeInsets.only(right: 5, bottom: 20),
              child: lokasiWidget),
          Container(
              width: 500,
              padding: EdgeInsets.only(left: 5, bottom: 20),
              child: tanggalWidget)
        ])
      ]);
    } else {
      return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Padding(padding: EdgeInsets.only(bottom: 20), child: lokasiWidget),
        Padding(
            padding: EdgeInsets.only(bottom: 20), child: latarBelakangWidget),
        Padding(padding: EdgeInsets.only(bottom: 20), child: tujuanWidget),
        strategiWidget
      ]);
    }
  }

  Widget buildTargetComponen(text, componen) {
    return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 5,
        child: ExpansionTile(
            title: Text(
              text,
              textAlign: TextAlign.center,
              style: (TextStyle(fontWeight: FontWeight.bold)),
            ),
            children: [
              Container(
                  margin:
                      EdgeInsets.only(left: 40, right: 40, top: 10, bottom: 10),
                  child: componen)
            ]));
  }

  Widget buildTarget() {
    if (MediaQuery.of(context).size.width >= 720) {
      return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Table(
          children: [
            TableRow(children: [
              Container(
                  width: 500,
                  padding: EdgeInsets.only(right: 5, bottom: 20),
                  child: buildTargetComponen(
                      "KEBUTUHAN TAMBAHAN", addKebutuhanTambahan())),
              Container(
                  width: 500,
                  padding: EdgeInsets.only(left: 5, bottom: 20),
                  child: buildTargetComponen("GIMMICK", addGimmick()))
            ]),
            TableRow(children: [
              Container(
                  width: 500,
                  padding: EdgeInsets.only(right: 5, bottom: 20),
                  child: buildTargetComponen("TARGET", addTarget())),
              Container(
                  width: 500,
                  padding: EdgeInsets.only(right: 5, bottom: 20),
                  child: buildTargetComponen("PRODUK", addProduct()))
            ]),
          ],
        ),
      ]);
    } else {
      return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: buildTargetComponen(
                "KEBUTUHAN TAMBAHAN", addKebutuhanTambahan())),
        Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: buildTargetComponen("GIMMICK", addGimmick())),
        Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: buildTargetComponen("TARGET", addTarget())),
        Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: buildTargetComponen("PRODUK", addProduct())),
        // targetWidget
      ]);
    }
  }

  countIndex(type) {
    setState(() {
      if (type == 1)
        index++;
      else
        index--;
    });
  }

  Widget arrowNavigator(type) {
    return Container(
      margin: EdgeInsets.only(top: 50),
      height: 50,
      width: 100,
      child: ElevatedButton(
          onPressed: () {
            countIndex(type);
          },
          child: Icon(
              type == 1
                  ? Icons.keyboard_double_arrow_right
                  : Icons.keyboard_double_arrow_left,
              color: Colors.white)),
    );
  }

  Widget tampilData(BuildContext context) {
    return Container(
      width: 1050,
      alignment: Alignment.topCenter,
      padding: EdgeInsets.only(top: 20, bottom: 20, left: 10, right: 10),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text("ID EVENT: ${id_event}/${date}\n",
            style: TextStyle(fontWeight: FontWeight.bold)),
        Container(
            alignment: Alignment.topCenter,
            padding: EdgeInsets.only(top: 20),
            child: SingleChildScrollView(
                scrollDirection: Axis.horizontal, child: multiTabIndicator())),
        Container(
            alignment: Alignment.topLeft,
            padding: EdgeInsets.only(top: 20),
            child: index == 0 ? buildGeneralInformation() : buildTarget()),
        Align(
            alignment:
                index == 0 ? Alignment.bottomRight : Alignment.bottomLeft,
            child: index == 0 ? arrowNavigator(1) : arrowNavigator(0)),
        if (index == 1)
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
                  dynamicKebutuhanTambahan.forEach((widget) => kebutuhanTambahan
                      .add([widget.komponen, widget.estimasi]));
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
                                onPressed: () =>
                                    Navigator.pop(context, 'Tidak'),
                                child: const Text('Tidak'),
                              ),
                            ],
                          ));
                }
              },
              child: Text(
                'Submit',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
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
          title: Text("Buat Proposal Event",
              style: TextStyle(color: Colors.white)),
          leading: BackButton(
            color: Colors.white,
            onPressed: () {
              Navigator.popAndPushNamed(context, "/homepage");
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
