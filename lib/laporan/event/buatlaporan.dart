import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:dropdown_search/dropdown_search.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:pt_coronet_crown/class/transaksi/eventherocyn.dart';
import 'package:measure_size/measure_size.dart';

class dynamicWidgetGimmick extends StatelessWidget {
  String barang, quantityProposal;
  int id, hargaProposal;
  dynamicWidgetGimmick(
      {super.key,
      required this.id,
      required this.barang,
      required this.hargaProposal,
      required this.quantityProposal});
  int jumlahRealisasi = 0;

  Widget proposalGimmick() {
    return SizedBox(
      width: 340,
      child: Text(
          "Nama barang: ${barang}, Harga: Rp. ${NumberFormat('###,000').format(hargaProposal)}, Estimasi jumlah: ${quantityProposal} "),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 55,
      width: 490,
      child: Row(
        children: <Widget>[
          proposalGimmick(),
          SizedBox(
              width: 150,
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Realisasi Jumlah',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  jumlahRealisasi = int.parse(value);
                },
              )),
        ],
      ),
    );
  }
}

class dynamicWidgetKebutuhanTambahan extends StatelessWidget {
  String komponen;
  int id, estimasi;
  String isiRealisasi = "";
  dynamicWidgetKebutuhanTambahan(
      {super.key,
      required this.komponen,
      required this.estimasi,
      required this.id});
  Widget proposalKebutuhan() {
    return SizedBox(
      width: 340,
      child: Text(
          "Komponen kebutuhan: ${komponen}, Estimasi: Rp. ${NumberFormat('###,000').format(estimasi)}, "),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 55,
      width: 490,
      child: Row(
        children: <Widget>[
          proposalKebutuhan(),
          SizedBox(
              width: 150,
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Realisasi',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  isiRealisasi = value;
                },
              ))
        ],
      ),
    );
  }
}

class dynamicWidgetTarget extends StatefulWidget {
  int id;
  String parameter;
  String isiProposal;
  String isiRealisasi = "";
  dynamicWidgetTarget(
      {super.key,
      required this.id,
      required this.parameter,
      required this.isiProposal});
  @override
  _dynamicWidgetTargetState createState() {
    return _dynamicWidgetTargetState();
  }
}

class _dynamicWidgetTargetState extends State<dynamicWidgetTarget> {
  Widget realisasiTarget() {
    return SizedBox(
      width: 340,
      child: Text(
          "Parameter: ${widget.parameter}, Target Proposal: ${widget.isiProposal}, "),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 55,
      width: 490,
      child: Row(
        children: <Widget>[
          realisasiTarget(),
          if (widget.parameter.contains("Estimasi"))
            SizedBox(
                width: 150,
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Realisasi',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    widget.isiRealisasi = value;
                  },
                ))
          else
            Text("Realisasi: Terisi otomatis")
        ],
      ),
    );
  }
}

class dyanmicDokumentasi extends StatefulWidget {
  var dokumentasi;
  dyanmicDokumentasi({
    super.key,
  });
  @override
  _dyanmicDokumentasiState createState() {
    return _dyanmicDokumentasiState();
  }
}

class _dyanmicDokumentasiState extends State<dyanmicDokumentasi> {
  Future chooseImg() async {
    FilePickerResult fileResult =
        await FilePicker.platform.pickFiles() as FilePickerResult;
    if (fileResult != null) {
      setState(() {
        var pict = fileResult.files.first.bytes;
        img.Image? temp = img.decodeImage(pict!);
        img.Image temp2 = img.copyResize(temp!, width: 300, height: 300);
        widget.dokumentasi = Uint8List.fromList(img.encodeJpg(temp2));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 300,
        width: 300,
        child: GestureDetector(
            onTap: () {
              chooseImg();
            },
            child: Container(
              alignment: Alignment.center,
              color: Colors.grey[400],
              child: widget.dokumentasi == null
                  ? Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.white,
                      size: 60,
                    )
                  : Image.memory(widget.dokumentasi),
            )));
  }
}

class dynamicWidgetPenjualanProduct extends StatelessWidget {
  String id_event;
  dynamicWidgetPenjualanProduct({super.key, required this.id_event});
  int quantity = 0, id_produk = 0;
  List product = [];
  Widget comboProduct() {
    return Container(
        width: 400,
        alignment: Alignment.topLeft,
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          SizedBox(
              width: 300,
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
                            "https://otccoronet.com/otc/laporan/event/properties/eventproduct.php"),
                        body: {'id_event': id_event});

                    if (response.statusCode == 200) {
                      json = jsonDecode(response.body);
                      product = json['data'];
                    }
                    return product as List<dynamic>;
                  },
                  onChanged: (value) {
                    id_produk = value['id'];
                    quantity = value['harga'];
                  },
                  itemAsString: (item) =>
                      "${item['jenis']} - Rp. ${NumberFormat('###,000').format(item['harga'])}/pcs")),
          SizedBox(
              width: 75,
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  quantity = int.parse(value);
                },
              ))
        ]));
  }

  @override
  Widget build(BuildContext context) {
    return comboProduct();
  }
}

class dynamicWidgetPengunjungBaru extends StatefulWidget {
  String nama = "", telepon = "", alamat = "", username = "", id_event;
  int gender = 0, usia = 0;
  List productBought = [];
  dynamicWidgetPengunjungBaru({super.key, required this.id_event});
  @override
  _dynamicWidgetPengunjungBaruState createState() {
    return _dynamicWidgetPengunjungBaruState();
  }
}

class _dynamicWidgetPengunjungBaruState
    extends State<dynamicWidgetPengunjungBaru> {
  List<String> genderList = <String>[
    'Laki-laki',
    'Perempuan',
  ];
  double heigtAddProduct = 0;
  List<dynamicWidgetPenjualanProduct> dynamicPenjualan = [];
  addProductBaru() {
    setState(() {
      if (widget.productBought.isNotEmpty) {
        widget.productBought = [];
      }
      dynamicPenjualan
          .add(dynamicWidgetPenjualanProduct(id_event: widget.id_event));
      heigtAddProduct += 50;
    });
  }

  Widget dataPenjualan() {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(
        'Data Penjualan\n',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      SizedBox(
          height: heigtAddProduct,
          child: ListView.builder(
            itemCount: dynamicPenjualan.length,
            itemBuilder: (_, index) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  dynamicPenjualan[index],
                  Tooltip(
                    message: "Delete penjualan",
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          dynamicPenjualan.removeAt(index);
                          heigtAddProduct -= 50;
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
              addProductBaru();
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

  Widget dataPengunjung() {
    return Container(
        alignment: Alignment.topLeft,
        width: 480,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(
            'Data Pengunjung\n',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                  width: 90,
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Username',
                    ),
                    onChanged: (value) {
                      widget.username = value;
                    },
                  )),
              SizedBox(
                  width: 175,
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Nama Lengkap Pembeli',
                    ),
                    onChanged: (value) {
                      widget.nama = value;
                    },
                  )),
              SizedBox(
                  width: 120,
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'No Telepon',
                    ),
                    onChanged: (value) {
                      widget.telepon = value;
                    },
                  )),
              SizedBox(
                  width: 50,
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Usia',
                    ),
                    onChanged: (value) {
                      widget.usia = int.parse(value);
                    },
                  )),
            ],
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            SizedBox(
                width: 300,
                child: TextField(
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Alamat Pembeli',
                  ),
                  onChanged: (value) {
                    widget.alamat = value;
                  },
                )),
            Container(
                alignment: Alignment.bottomCenter,
                width: 50,
                height: 40,
                child: Text("Gender: ")),
            Container(
              alignment: Alignment.bottomCenter,
              height: 68,
              width: 100,
              child: DropdownButton(
                  hint: Text("Gender"),
                  value: widget.gender,
                  items: [
                    DropdownMenuItem(child: Text("Laki-laki"), value: 0),
                    DropdownMenuItem(child: Text("Wanita"), value: 1),
                  ],
                  onChanged: (value) {
                    setState(() {
                      widget.gender = value!;
                    });
                  }),
            ),
          ])
        ]));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1000,
      alignment: Alignment.topLeft,
      padding: EdgeInsets.only(top: 20),
      // child: Row(
      //   children: [dataPengunjung()],
      // )
      child: Table(
        children: [
          TableRow(children: [
            Container(
              decoration: BoxDecoration(border: Border.all(width: 1)),
              width: 500,
              margin: EdgeInsets.only(right: 5),
              padding: EdgeInsets.all(10),
              child: dataPengunjung(),
            ),
            Container(
                decoration: BoxDecoration(border: Border.all(width: 1)),
                width: 500,
                margin: EdgeInsets.only(left: 5),
                padding: EdgeInsets.all(10),
                child: dataPenjualan()),

            // child: ),
          ])
        ],
      ),
    );
  }
}

class BuatLaporanEvent extends StatefulWidget {
  String event_id, penanggung_jawab;
  BuatLaporanEvent(
      {super.key, required this.event_id, required this.penanggung_jawab});
  @override
  _BuatLaporanEventState createState() {
    return _BuatLaporanEventState();
  }
}

class _BuatLaporanEventState extends State<BuatLaporanEvent> {
  TextEditingController startTimeController = TextEditingController(),
      endTimeController = TextEditingController(),
      dateController = TextEditingController();
  List dokumentasi = [],
      target = [],
      gimmick = [],
      kebutuhanTambahan = [],
      pengunjungBaru = [],
      pengunjungLama = [];
  List<dyanmicDokumentasi> dynamicDokumentasi = [];
  List<dynamicWidgetTarget> dynamicTarget = [];
  List<dynamicWidgetGimmick> dynamicGimmick = [];
  List<dynamicWidgetKebutuhanTambahan> dynamicKebutuhanTambahan = [];
  List<dynamicWidgetPengunjungBaru> dynamicPengunjungBaru = [];
  double heightAddDokumentasi = 0,
      heightAddTarget = 0,
      heightAddGimmick = 0,
      heightAddKebutuhanTambahan = 0,
      heightAddPengunjungBaru = 0;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String username = "", keterangan = "";
  EventHerocyn? _event;

  addDynamicGimmick(id, barang, hargaProposal, quantityProposal) {
    setState(() {
      if (gimmick.isNotEmpty) {
        gimmick = [];
      }
      dynamicGimmick.add(dynamicWidgetGimmick(
        id: id,
        barang: barang,
        hargaProposal: hargaProposal,
        quantityProposal: quantityProposal,
      ));
      heightAddGimmick += 55;
    });
  }

  addDynamicKebutuhanTambahan(id, komponen, estimasi) {
    setState(() {
      if (kebutuhanTambahan.isNotEmpty) {
        kebutuhanTambahan = [];
      }
      dynamicKebutuhanTambahan.add(dynamicWidgetKebutuhanTambahan(
        id: id,
        komponen: komponen,
        estimasi: estimasi,
      ));
      heightAddKebutuhanTambahan += 55;
    });
  }

  addDynamicTarget(id, parameter, target_proposal) {
    setState(() {
      if (target.isNotEmpty) {
        target = [];
      }
      dynamicTarget.add(dynamicWidgetTarget(
        id: id,
        parameter: parameter,
        isiProposal: target_proposal,
      ));
      heightAddTarget += 55;
    });
  }

  addDynamickDokumentasi() {
    setState(() {
      if (dokumentasi.isNotEmpty) {
        dokumentasi = [];
      }
      dynamicDokumentasi.add(dyanmicDokumentasi());
      heightAddDokumentasi += 300;
    });
  }

  addPengungjungBaru() {
    setState(() {
      if (pengunjungBaru.isNotEmpty) {
        pengunjungBaru = [];
      }
      dynamicPengunjungBaru.add(dynamicWidgetPengunjungBaru(
        id_event: widget.event_id,
      ));
      heightAddPengunjungBaru += 200;
    });
  }

  // void submit(BuildContext context) async {
  //   final response = await http.post(
  //       Uri.parse("https://otccoronet.com/otc/laporan/event/buatproposal.php"),
  //       body: {
  //         'id': widget.event_id,
  //         'target': jsonEncode(target),
  //         'kebutuhan_tambahan': jsonEncode(kebutuhanTambahan),
  //         'gimmick': jsonEncode(gimmick),
  //       });
  //   if (response.statusCode == 200) {
  //     Map json = jsonDecode(response.body);
  //     if (json['result'] == 'success') {
  //       if (!mounted) return;
  //       ScaffoldMessenger.of(context)
  //           .showSnackBar(SnackBar(content: Text('Laporan telah diajukan')));
  //       Navigator.popAndPushNamed(context, "/daftarproposal");
  //     }
  //   } else {
  //     throw Exception('Failed to read API');
  //   }
  // }

  Future<String> fetchData() async {
    final response = await http.post(
        Uri.parse(
            "https://otccoronet.com/otc/laporan/event/detailproposal.php"),
        body: {'id': widget.event_id});
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to read API');
    }
  }

  bacaData() {
    fetchData().then((value) {
      Map json = jsonDecode(value);
      _event = EventHerocyn.fromJson(json['data']);
      setState(() {});
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    bacaData();
    initializeDateFormatting();
  }

  Widget tabelPersonil() {
    return Column(children: [
      Text(
        "DAFTAR PERSONIL",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      Container(
        alignment: Alignment.topCenter,
        width: 500,
        child: ListView.builder(
            shrinkWrap: true,
            itemCount: 1,
            itemBuilder: (BuildContext ctxt, int index) {
              return DataTable(
                  columns: [
                    DataColumn(
                        label: Expanded(
                            child: Text(
                      "Username",
                      textAlign: TextAlign.center,
                    ))),
                    DataColumn(
                        label: Expanded(
                            child: Text("Nama", textAlign: TextAlign.center))),
                    DataColumn(
                        label: Expanded(
                            child:
                                Text("Jabatan", textAlign: TextAlign.center))),
                  ],
                  rows: _event!.personil!
                      .map<DataRow>((element) => DataRow(cells: [
                            DataCell(Align(
                                alignment: Alignment.center,
                                child: Text(element['username'],
                                    textAlign: TextAlign.center))),
                            DataCell(Align(
                                alignment: Alignment.center,
                                child: Text(
                                    "${element['nama_depan'].toString()} ${element['nama_belakang'].toString()}",
                                    textAlign: TextAlign.center))),
                            DataCell(Align(
                                alignment: Alignment.center,
                                child: Text(element['jabatan'],
                                    textAlign: TextAlign.center))),
                          ]))
                      .toList());
            }),
      )
    ]);
  }

  Widget updateKebutuhan() {
    if (_event!.kebutuhan != null) {
      if (dynamicKebutuhanTambahan.isEmpty) {
        for (int i = 0; i < _event!.kebutuhan!.length; i++) {
          addDynamicKebutuhanTambahan(_event!.target![i]['id'],
              _event!.target![i]['komponen'], _event!.target![i]['estimasi']);
        }
      }
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
                return dynamicKebutuhanTambahan[index];
              },
            )),
      ]);
    } else {
      return Column(children: [
        Text(
          "KEBUTUHAN TAMBAHAN\n",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text("Tidak terdapat kebutuhan tambahan pada Event ini"),
      ]);
    }
  }

  Widget updateGimmick() {
    if (_event!.gimmick != null) {
      if (dynamicGimmick.isEmpty) {
        for (int i = 0; i < _event!.gimmick!.length; i++) {
          addDynamicGimmick(
              _event!.gimmick![i]['id'],
              _event!.gimmick![i]['barang'],
              _event!.gimmick![i]['harga'],
              _event!.gimmick![i]['quantity_proposal'].toString());
        }
      }
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
                return dynamicGimmick[index];
              },
            )),
      ]);
    } else {
      return Column(children: [
        Text(
          "GIMMICK\n",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text("Tidak terdapat gimmick pada Event ini"),
      ]);
    }
  }

  Widget updateTarget() {
    if (dynamicTarget.isEmpty) {
      for (int i = 0; i < _event!.target!.length; i++) {
        addDynamicTarget(
            _event!.target![i]['id'],
            _event!.target![i]['parameter'],
            _event!.target![i]['target_proposal'].toString());
      }
    }
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
              return dynamicTarget[index];
            },
          )),
    ]);
  }

  Widget addPengunjungBaru() {
    return Column(children: [
      Text(
        "PENGUNJUNG BARU\n",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      SizedBox(
          height: heightAddPengunjungBaru,
          child: ListView.builder(
            itemCount: dynamicPengunjungBaru.length,
            itemBuilder: (_, index) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  dynamicPengunjungBaru[index],
                  Tooltip(
                    message: "Delete Pengunjung",
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          dynamicPengunjungBaru.removeAt(index);
                          heightAddPengunjungBaru -= 200;
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
              addPengungjungBaru();
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

  Widget addDokumentasi() {
    return Column(children: [
      Text(
        "DOKUMENTASI\n",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      SizedBox(
          height: heightAddDokumentasi,
          child: ListView.builder(
            itemCount: dynamicDokumentasi.length,
            itemBuilder: (_, index) {
              return Container(
                  padding: EdgeInsets.only(top: 10),
                  alignment: Alignment.center,
                  width: 300,
                  height: 300,
                  child: Stack(
                    children: [
                      Align(
                          alignment: Alignment.center,
                          child: dynamicDokumentasi[index]),
                      Container(
                          padding: EdgeInsets.only(right: 60),
                          alignment: Alignment.centerRight,
                          child: Tooltip(
                            message: "Hapus Dokumentasi",
                            child: IconButton(
                              onPressed: () {
                                setState(() {
                                  dynamicDokumentasi.removeAt(index);
                                  heightAddDokumentasi -= 300;
                                });
                              },
                              icon: Icon(Icons.delete),
                            ),
                          ))
                    ],
                  ));
            },
          )),
      Container(
        margin: EdgeInsets.only(top: 10),
        height: 50,
        width: 50,
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              addDynamickDokumentasi();
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

  Widget lokasi() {
    return Column(children: [
      Text(
        "LOKASI",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      ListView.builder(
          shrinkWrap: true,
          itemCount: _event?.lokasi?.length,
          itemBuilder: (BuildContext ctxt, int index) {
            return RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 13.0,
                  color: Colors.black,
                ),
                children: <TextSpan>[
                  TextSpan(text: '\nKelurahan: '),
                  TextSpan(
                      text: _event!.lokasi![index]['kelurahan'],
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: ', Kecamatan: '),
                  TextSpan(
                      text: _event!.lokasi![index]['kecamatan'],
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: '\nKota: '),
                  TextSpan(
                      text: _event!.lokasi![index]['kota'],
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: ', Provinsi: '),
                  TextSpan(
                      text: _event!.lokasi![index]['provinsi'],
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: '\nAlamat: '),
                  TextSpan(
                      text: _event!.lokasi![index]['alamat'],
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }),
    ]);
  }

  Widget latarBelakang() {
    return Column(children: [
      Text(
        "LATAR BELAKANG\n",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      Text(_event!.latar_belakang!.toString(),
          style: TextStyle(
            height: 1.5,
          )),
    ]);
  }

  Widget strategi() {
    return Column(children: [
      Text("STRATEGI\n", style: TextStyle(fontWeight: FontWeight.bold)),
      Text(_event!.strategi!.toString(),
          style: TextStyle(
            height: 1.5,
          )),
    ]);
  }

  Widget tujuan() {
    return Column(children: [
      Text("TUJUAN\n", style: TextStyle(fontWeight: FontWeight.bold)),
      Text(_event!.tujuan.toString(),
          style: TextStyle(
            height: 1.5,
          )),
    ]);
  }

  Widget tampilData(BuildContext context) {
    return SingleChildScrollView(
        child: Container(
      width: 1050,
      alignment: Alignment.topCenter,
      padding: EdgeInsets.only(top: 20, bottom: 20),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Align(
            alignment: Alignment.topLeft,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("ID Event: ${widget.event_id}",
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text("Penanggung Jawab: ${widget.penanggung_jawab}",
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
                ])),
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
                Container(
                    width: 500,
                    padding: EdgeInsets.only(left: 5),
                    child: tabelPersonil()),
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
                    child: updateTarget()),
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
                    child: updateKebutuhan()),
                Container(
                    width: 500,
                    padding: EdgeInsets.only(left: 5),
                    child: updateGimmick()),
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
                    child: addDokumentasi()),
                Container(
                  width: 500,
                  padding: EdgeInsets.only(left: 5),
                ),
              ])
            ],
          ),
        ),
        Container(
          alignment: Alignment.topLeft,
          width: 1050,
          padding: EdgeInsets.only(top: 20),
          child: addPengunjungBaru(),
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
                dynamicKebutuhanTambahan.forEach((widget) =>
                    kebutuhanTambahan.add([widget.id, widget.isiRealisasi]));
                dynamicGimmick.forEach((widget) =>
                    gimmick.add([widget.id, widget.jumlahRealisasi]));
                dynamicTarget.forEach(
                    (widget) => target.add([widget.id, widget.isiRealisasi]));
                dynamicDokumentasi
                    .forEach((widget) => target.add([widget.dokumentasi]));
                //   showDialog<String>(
                //       context: context,
                //       builder: (BuildContext context) => AlertDialog(
                //             title: const Text('Peringatan'),
                //             content: Text(
                //                 "Apakah anda yakin hendak mem-finalisasi proposal? \nData pada proposal tidak dapat diubah, kecuali proposal tidak disetujui"),
                //             actions: <Widget>[
                //               TextButton(
                //                 onPressed: () {
                //                   //submit(context);
                //                 },
                //                 child: const Text('Iya'),
                //               ),
                //               TextButton(
                //                 onPressed: () => Navigator.pop(context, 'Tidak'),
                //                 child: const Text('Tidak'),
                //               ),
                //             ],
                //           ));
                for (int i = 0; i < target.length; i++) {
                  print(target[i]);
                }
                print("\n");
                for (int i = 0; i < kebutuhanTambahan.length; i++) {
                  print(kebutuhanTambahan[i]);
                }
                print("\n");
                for (int i = 0; i < gimmick.length; i++) {
                  print(gimmick[i]);
                }
              }
            },
            child: Text(
              'Submit',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ]),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Buat Laporan Event"),
          leading: BackButton(
            onPressed: () {
              Navigator.popAndPushNamed(context, "/daftarevent");
            },
          ),
        ),
        body: _event == null
            ? Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                alignment: Alignment.center,
                child: const CircularProgressIndicator(),
              )
            : Container(
                // width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.only(top: 20),
                alignment: Alignment.topCenter,
                // height: MediaQuery.of(context).size.height,
                child: tampilData(context)));

    //ListView(children: [tampilData()])));
  }
}
