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
import 'package:provider/provider.dart';
import 'package:pt_coronet_crown/class/transaksi/eventherocyn.dart';
import 'package:measure_size/measure_size.dart';
import 'package:pt_coronet_crown/customicon/event_chart_icons.dart';
import 'package:pt_coronet_crown/customicon/transaction_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

List existedPengunjung = <String?>[];

class dynamicWidgetGimmick extends StatelessWidget {
  String barang, quantityProposal;
  int id, hargaProposal;
  dynamicWidgetGimmick(
      {super.key,
      required this.id,
      required this.barang,
      required this.hargaProposal,
      required this.quantityProposal});
  TextEditingController jumlahRealisasi = TextEditingController();

  Widget proposalGimmick() {
    return SizedBox(
      width: 440,
      child: Text(
          "Nama barang: ${barang}, Harga: Rp. ${NumberFormat('###,000').format(hargaProposal)}, Estimasi jumlah: ${quantityProposal} "),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 600,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          proposalGimmick(),
          SizedBox(
              width: 150,
              height: 50,
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Realisasi Jumlah',
                ),
                controller: jumlahRealisasi,
                keyboardType: TextInputType.number,
              )),
        ],
      ),
    );
  }
}

class dynamicWidgetKebutuhanTambahan extends StatelessWidget {
  String komponen;
  int id, estimasi;
  TextEditingController isiRealisasi = TextEditingController();
  dynamicWidgetKebutuhanTambahan(
      {super.key,
      required this.komponen,
      required this.estimasi,
      required this.id});
  Widget proposalKebutuhan() {
    return SizedBox(
      width: 490,
      child: Text(
          "Komponen kebutuhan: ${komponen}, Estimasi: Rp. ${NumberFormat('###,000').format(estimasi)}, "),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 55,
      width: 600,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          proposalKebutuhan(),
          SizedBox(
              width: 100,
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Realisasi',
                ),
                controller: isiRealisasi,
                keyboardType: TextInputType.number,
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
  TextEditingController isiRealisasi = TextEditingController();
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
    return Container(
      padding: EdgeInsets.only(bottom: 5),
      height: 55,
      width: 490,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          realisasiTarget(),
          if (widget.parameter.contains("Estimasi"))
            SizedBox(
                width: 225,
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Realisasi',
                  ),
                  keyboardType: TextInputType.number,
                  controller: widget.isiRealisasi,
                ))
          else
            SizedBox(
                width: 225,
                child: Text("Realisasi: Terisi otomatis oleh sistem"))
        ],
      ),
    );
  }
}

class dyanmicDokumentasi extends StatefulWidget {
  var dokumentasi;
  String tanggal;
  TextEditingController alamatController = TextEditingController(),
      tanggalController = TextEditingController(),
      waktuController = TextEditingController();

  dyanmicDokumentasi({super.key, required this.tanggal});
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

  Widget pickPicture() {
    return SizedBox(
        height: 300,
        width: 300,
        child: GestureDetector(
            onTap: () {
              chooseImg();
            },
            child: Container(
              alignment: Alignment.center,
              color: widget.dokumentasi == null
                  ? Colors.grey[400]
                  : Colors.transparent,
              child: widget.dokumentasi == null
                  ? Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.white,
                      size: 60,
                    )
                  : Image.memory(widget.dokumentasi),
            )));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.tanggalController.text = widget.tanggal;
    if (widget.waktuController.text == "") {
      widget.waktuController.text = DateFormat.Hm()
          .format(DateTime.now().copyWith(hour: 8, minute: 0, second: 0));
    }
  }

  Widget buildKeterangan() {
    return SizedBox(
        width: 480,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text("KETERANGAN"),
            Row(
              children: [
                SizedBox(
                    width: 180,
                    child: TextField(
                        enabled: false,
                        decoration: const InputDecoration(
                          labelText: 'Tanggal',
                        ),
                        controller: widget.tanggalController)),
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: ElevatedButton(
                      onPressed: () {
                        showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        ).then((value) {
                          setState(() {
                            if (value != null) {
                              widget.waktuController.text =
                                  '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
                            }
                          });
                        });
                      },
                      child: Icon(
                        Icons.access_time_outlined,
                        color: Colors.white,
                        size: 24.0,
                      )),
                ),
                Container(
                    width: 200,
                    padding: EdgeInsets.only(left: 5),
                    child: TextFormField(
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: "Waktu",
                      ),
                      controller: widget.waktuController,
                    ))
              ],
            ),
            SizedBox(
                width: 480,
                child: TextField(
                    minLines: 1,
                    maxLines: 3,
                    keyboardType: TextInputType.multiline,
                    decoration: const InputDecoration(
                      labelText: 'Alamat (Max 3 baris)',
                    ),
                    controller: widget.alamatController))
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(bottom: 5),
        decoration: BoxDecoration(
            border: Border(bottom: BorderSide(width: 1, color: Colors.grey))),
        child: Table(
          children: [
            TableRow(children: [
              Container(
                width: 500,
                margin: EdgeInsets.only(right: 5),
                padding: EdgeInsets.all(10),
                child: pickPicture(),
              ),
              Container(
                  width: 400,
                  margin: EdgeInsets.only(left: 5),
                  padding: EdgeInsets.all(10),
                  child: buildKeterangan()),

              // child: ),
            ])
          ],
        ));
  }
}

class dynamicWidgetPenjualanProduct extends StatelessWidget {
  String id_event;
  dynamicWidgetPengunjung productParameter;
  dynamicWidgetPenjualanProduct(
      {super.key, required this.id_event, required this.productParameter});

  TextEditingController quantityController = TextEditingController(),
      controllerKeterangan = TextEditingController();

  int id_produk = 0, harga = 0;
  List product = [];

  Widget comboProduct() {
    return Container(
        width: 400,
        alignment: Alignment.topLeft,
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Stack(children: [
            SizedBox(
                width: 300,
                child: DropdownSearch<dynamic>(
                    dropdownSearchDecoration: InputDecoration(
                      border: InputBorder.none,
                      labelText: "",
                    ),
                    mode: Mode.MENU,
                    showSearchBox: false,
                    emptyBuilder: (context, searchEntry) => Center(
                          child: Text("Tidak ada data ditemukan"),
                        ),
                    onFind: (text) async {
                      Map json;
                      var response = await http.post(
                          Uri.parse(
                              "https://otccoronet.com/otc/laporan/event/properties/eventproduct.php"),
                          body: {
                            'id_event': id_event,
                            'parameter':
                                jsonEncode(productParameter.existedProduct)
                          });

                      if (response.statusCode == 200) {
                        json = jsonDecode(response.body);
                        product = json['data'];
                      }
                      return product as List<dynamic>;
                    },
                    onChanged: (value) {
                      if (productParameter.existedProduct.isEmpty) {
                        productParameter.existedProduct.add(value['id']);
                      } else {
                        if (id_produk != 0) {
                          int index = productParameter.existedProduct
                              .indexWhere((parameter) =>
                                  parameter.startsWith(value['id']));
                          productParameter.existedProduct[index] = value['id'];
                        } else {
                          productParameter.existedProduct.add(value['id']);
                        }
                      }
                      id_produk = value['id'];
                      harga = value['harga'];
                      controllerKeterangan.text =
                          "${value['jenis']} - Rp. ${NumberFormat('###,000').format(value['harga'])}/pcs";
                      print(productParameter.existedProduct);
                    },
                    itemAsString: (item) =>
                        "${item['jenis']} - Rp. ${NumberFormat('###,000').format(item['harga'])}/pcs")),
            Container(
              width: 250,
              color: Colors.white,
              child: TextField(
                  maxLines: 1,
                  decoration: const InputDecoration(labelText: 'Daftar Produk'),
                  controller: controllerKeterangan,
                  enabled: false),
            )
          ]),
          SizedBox(
              width: 75,
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                ),
                keyboardType: TextInputType.number,
                controller: quantityController,
              ))
        ]));
  }

  @override
  Widget build(BuildContext context) {
    return comboProduct();
  }
}

class dynamicWidgetPengunjung extends StatefulWidget {
  String username = "";
  List productBought = [], pengunjung = [];
  TextEditingController controllerNama = TextEditingController(),
      controllerTelepon = TextEditingController(),
      controllerAlamat = TextEditingController(),
      controllerUsername = TextEditingController(),
      controllerUsia = TextEditingController(),
      controllerGender = TextEditingController(),
      controllerKeterangan = TextEditingController();
  List existedProduct = [];
  int gender = 0;
  String? id_event;
  bool? isLama;
  int? idxPengunjung;
  List<dynamicWidgetPenjualanProduct> dynamicPenjualan = [];
  double heigtAddProduct = 0;

  dynamicWidgetPengunjung(
      {super.key, this.id_event, this.idxPengunjung, this.isLama});
  @override
  _dynamicWidgetPengunjungState createState() {
    return _dynamicWidgetPengunjungState();
  }
}

class _dynamicWidgetPengunjungState extends State<dynamicWidgetPengunjung> {
  String selectedItem = "";

  addProductBaru() {
    setState(() {
      if (widget.productBought.isNotEmpty) {
        widget.productBought = [];
      }
      widget.dynamicPenjualan.add(dynamicWidgetPenjualanProduct(
          id_event: widget.id_event.toString(), productParameter: widget));
      widget.heigtAddProduct += 55;
    });
  }

  Widget dataPengunjungBaru() {
    return Container(
        alignment: Alignment.topLeft,
        width: 1050,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(
            'Data Pengunjung Baru\n',
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
                    controller: widget.controllerUsername,
                  )),
              SizedBox(
                  width: 175,
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Nama Lengkap Pembeli',
                    ),
                    controller: widget.controllerNama,
                  )),
              SizedBox(
                  width: 120,
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'No Telepon',
                    ),
                    controller: widget.controllerTelepon,
                  )),
              SizedBox(
                  width: 50,
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Usia',
                    ),
                    controller: widget.controllerUsia,
                  )),
              SizedBox(
                  width: 300,
                  height: 50,
                  child: TextField(
                    keyboardType: TextInputType.multiline,
                    maxLines: 3,
                    minLines: 1,
                    decoration: const InputDecoration(
                      labelText: 'Alamat Pembeli',
                    ),
                    controller: widget.controllerAlamat,
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
            ],
          ),
          // Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

          // ])
        ]));
  }

  Widget dataPenjualan() {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(
        'Data Penjualan\n',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      SizedBox(
          height: widget.heigtAddProduct,
          child: ListView.builder(
            itemCount: widget.dynamicPenjualan.length,
            itemBuilder: (_, index) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  widget.dynamicPenjualan[index],
                  Tooltip(
                    message: "Delete penjualan",
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          widget.dynamicPenjualan.removeAt(index);
                          widget.existedProduct.removeAt(index);
                          widget.heigtAddProduct -= 55;
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

  Widget dataPengunjungLama() {
    return Align(
        alignment: Alignment.topLeft,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(
            'Data Pengunjung Lama\n',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Stack(
                children: [
                  SizedBox(
                      width: 340,
                      height: 55,
                      child: DropdownSearch<dynamic>(
                          dropdownSearchDecoration: InputDecoration(
                            labelText: "",
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
                                    "https://otccoronet.com/otc/admin/event/pengunjungevent.php"),
                                body: {
                                  'cari': text,
                                  'existedPengunjung':
                                      jsonEncode(existedPengunjung)
                                });

                            if (response.statusCode == 200) {
                              json = jsonDecode(response.body);
                              widget.pengunjung = json['data'];
                            }
                            return widget.pengunjung;
                          },
                          onChanged: (value) {
                            if (existedPengunjung.isEmpty) {
                              existedPengunjung.add("'${value['username']}'");
                            } else {
                              if (widget.username != "") {
                                int index = existedPengunjung.indexWhere(
                                    (parameter) => parameter
                                        .startsWith("'${widget.username}'"));
                                existedPengunjung[index] =
                                    "'${value['username']}'";
                              } else {
                                existedPengunjung.add("'${value['username']}'");
                              }
                            }
                            widget.username = value['username'];
                            widget.controllerTelepon.text =
                                value['nomor_telepon'];
                            widget.controllerUsia.text =
                                value['usia'].toString();
                            widget.controllerAlamat.text = value['alamat'];
                            widget.controllerKeterangan.text =
                                "${value['username']} - ${value['nama']}";
                            if (value['gender'] == 0) {
                              widget.controllerGender.text = "Laki-laki";
                            } else {
                              widget.controllerGender.text = "Perempuan";
                            }
                          },
                          itemAsString: (item) =>
                              "${item['username']} - ${item['nama']}")),
                  SizedBox(
                      width: 300,
                      height: 55,
                      // color: Colors.white,
                      child: Stack(
                        children: [
                          Container(color: Colors.white, height: 52),
                          TextField(
                              maxLines: 1,
                              decoration: const InputDecoration(
                                  labelText: 'Daftar Pengunjung',
                                  border: InputBorder.none),
                              controller: widget.controllerKeterangan,
                              enabled: false)
                        ],
                      ))
                ],
              ),
              SizedBox(
                  width: 120,
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'No Telepon',
                    ),
                    controller: widget.controllerTelepon,
                    enabled: false,
                  )),
              SizedBox(
                  width: 300,
                  height: 55,
                  child: TextField(
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Alamat Pembeli',
                    ),
                    controller: widget.controllerAlamat,
                    readOnly: true,
                  )),
              SizedBox(
                  width: 35,
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Usia',
                    ),
                    controller: widget.controllerUsia,
                    enabled: false,
                  )),
              Container(
                alignment: Alignment.bottomCenter,
                width: 100,
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Gender',
                  ),
                  controller: widget.controllerGender,
                  enabled: false,
                ),
              ),
            ],
          ),
          // Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [])
        ]));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 1000,
        alignment: Alignment.topLeft,
        padding: EdgeInsets.only(top: 20),
        child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 5,
            child: ExpansionTile(
              title: Text(
                "PENGUNJUNG ${widget.idxPengunjung.toString()}",
                textAlign: TextAlign.center,
                style: (TextStyle(fontWeight: FontWeight.bold)),
              ),
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 1000,
                      // margin: EdgeInsets.only(
                      //     right: 5, left: 5, top: 10, bottom: 10),
                      padding: EdgeInsets.all(10),
                      child: widget.isLama == true
                          ? dataPengunjungLama()
                          : dataPengunjungBaru(),
                    ),
                    Container(
                        width: 500,
                        margin: EdgeInsets.only(
                            right: 5, left: 5, top: 10, bottom: 10),
                        // padding: EdgeInsets.all(10),
                        child: dataPenjualan())
                  ],

                  // child: ),
                ),
              ],
            )));
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
  int index = 0, pengunjung = 0, total_biaya = 0, total_penjualan = 0;
  TextEditingController evaluasiController = TextEditingController();
  List dokumentasi = [],
      target = [],
      gimmick = [],
      kebutuhanTambahan = [],
      pengunjungBaru = [],
      pengunjungLama = [],
      stok = [],
      widgetStock = [];
  List<dyanmicDokumentasi> dynamicDokumentasi = [];
  List<dynamicWidgetTarget> dynamicTarget = [];
  List<dynamicWidgetGimmick> dynamicGimmick = [];
  List<dynamicWidgetKebutuhanTambahan> dynamicKebutuhanTambahan = [];
  List<dynamicWidgetPengunjung> dynamicPengunjung = [];
  double heightAddDokumentasi = 0,
      heightAddTarget = 0,
      heightAddGimmick = 0,
      heightAddKebutuhanTambahan = 0,
      heightAddPengunjungBaru = 0,
      heightAddPengunjung = 0;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String username = "", keterangan = "", id_cabang = "";
  EventHerocyn? _event;
  bool isDialogShow = false;

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
      dynamicDokumentasi.add(dyanmicDokumentasi(
        tanggal: _event!.tanggal,
      ));
      heightAddDokumentasi += 320;
    });
  }

  addPengungjung(isLama) {
    setState(() {
      pengunjung++;
      if (pengunjungLama.isNotEmpty) {
        pengunjungLama = [];
      }
      dynamicPengunjung.add(dynamicWidgetPengunjung(
        id_event: widget.event_id,
        idxPengunjung: pengunjung,
        isLama: isLama,
      ));
      heightAddPengunjung += 300;
    });
  }

  void clearData() {
    kebutuhanTambahan.clear();
    gimmick.clear();
    target.clear();
    dokumentasi.clear();
    pengunjungBaru.clear();
    pengunjungLama.clear();
    stok.clear();
  }

  void submit(BuildContext context) async {
    final response = await http.post(
        Uri.parse("https://otccoronet.com/otc/laporan/event/buatlaporan.php"),
        body: {
          'id': widget.event_id,
          'pengunjungBaru': jsonEncode(pengunjungBaru),
          'pengunjungLama': jsonEncode(pengunjungLama),
          'target': jsonEncode(target),
          'kebutuhan_tambahan': jsonEncode(kebutuhanTambahan),
          'gimmick': jsonEncode(gimmick),
          'dokumentasi': jsonEncode(dokumentasi),
          'stok': jsonEncode(stok),
          'evaluasi': evaluasiController.text,
          'id_cabang': id_cabang
        });
    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      print(response.body.toString());
      if (json['result'] == 'success') {
        if (!mounted) return;
        clearData();
        // ScaffoldMessenger.of(context)
        //     .showSnackBar(SnackBar(content: Text('Laporan telah diajukan')));
        // Navigator.popAndPushNamed(context, "/daftarevent");
      } else {
        warningDialog(json['message']);
      }
    } else {
      throw Exception('Failed to read API');
    }
  }

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

  _loadDataCabang() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      id_cabang = prefs.getString("idCabang") ?? '';
    });
  }

  bacaData() {
    fetchData().then((value) {
      Map json = jsonDecode(value);
      _event = EventHerocyn.fromJson(json['data']);
      setState(() {
        if (dynamicTarget.isEmpty) {
          for (int t = 0; t < _event!.target!.length; t++) {
            addDynamicTarget(
                _event!.target![t]['id'],
                _event!.target![t]['parameter'],
                _event!.target![t]['target_proposal'].toString());
          }
        }
        if (dynamicGimmick.isEmpty) {
          for (int g = 0; g < _event!.gimmick!.length; g++) {
            addDynamicGimmick(
                _event!.gimmick![g]['id'],
                _event!.gimmick![g]['barang'],
                _event!.gimmick![g]['harga'],
                _event!.gimmick![g]['quantity_proposal'].toString());
          }
        }
        if (dynamicKebutuhanTambahan.isEmpty) {
          for (int k = 0; k < _event!.kebutuhan!.length; k++) {
            addDynamicKebutuhanTambahan(
                _event!.kebutuhan![k]['id'],
                _event!.kebutuhan![k]['komponen'],
                _event!.kebutuhan![k]['estimasi']);
          }
        }
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    bacaData();
    _loadDataCabang();
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
        child: ListView.builder(
            shrinkWrap: true,
            itemCount: 1,
            itemBuilder: (BuildContext ctxt, int index) {
              return DataTable(
                  columns: [
                    DataColumn(
                        label: Expanded(
                            child:
                                Text("Username", textAlign: TextAlign.center))),
                    DataColumn(
                        label: Expanded(
                            child: Text("Nama", textAlign: TextAlign.center))),
                    DataColumn(
                        label: Expanded(
                            child:
                                Text("Telepon", textAlign: TextAlign.center))),
                    DataColumn(
                        label: Expanded(
                            child:
                                Text("E-mail", textAlign: TextAlign.center))),
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
                                child: Text(element['no_telp'],
                                    textAlign: TextAlign.center))),
                            DataCell(Align(
                                alignment: Alignment.center,
                                child: Text(element['email'],
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
      return Container(
          padding: EdgeInsets.only(bottom: 10),
          height: heightAddKebutuhanTambahan + 10,
          child: ListView.builder(
            itemCount: dynamicKebutuhanTambahan.length,
            itemBuilder: (_, index) {
              return dynamicKebutuhanTambahan[index];
            },
          ));
    } else {
      return Container(
          padding: EdgeInsets.only(bottom: 10, top: 10),
          child: Text("Tidak terdapat kebutuhan tambahan pada Event ini"));
    }
  }

  Widget updateGimmick() {
    if (_event!.gimmick != null) {
      return Container(
          padding: EdgeInsets.only(bottom: 10),
          height: heightAddGimmick + 10,
          child: ListView.builder(
            itemCount: dynamicGimmick.length,
            itemBuilder: (_, index) {
              return dynamicGimmick[index];
            },
          ));
    } else {
      return Container(
          padding: EdgeInsets.only(bottom: 10, top: 10),
          child: Text("Tidak terdapat gimmick pada Event ini"));
    }
  }

  Widget updateTarget() {
    return Container(
        padding: EdgeInsets.only(bottom: 10),
        height: heightAddTarget + 10,
        child: ListView.builder(
          itemCount: dynamicTarget.length,
          itemBuilder: (_, index) {
            return dynamicTarget[index];
          },
        ));
  }

  Widget buildPengunjung() {
    return SizedBox(
        width: 1050,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          SizedBox(
              // width: 1050,
              height: heightAddPengunjung,
              child: ListView.builder(
                itemCount: dynamicPengunjung.length,
                itemBuilder: (_, index) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      dynamicPengunjung[index],
                      Padding(
                          padding: EdgeInsets.only(left: 5),
                          child: Tooltip(
                            message: "Delete Pengunjung",
                            child: IconButton(
                              onPressed: () {
                                setState(() {
                                  dynamicPengunjung.removeAt(index);
                                  if (existedPengunjung.isNotEmpty) {
                                    try {
                                      existedPengunjung.removeAt(index);
                                    } catch (e) {
                                      print(e);
                                    }
                                    // if (existedPengunjung[index] != null) {

                                    // }
                                  }
                                  heightAddPengunjung -= 300;
                                });
                              },
                              icon: Icon(Icons.delete),
                            ),
                          ))
                    ],
                  );
                },
              )),
          Container(
              margin: EdgeInsets.only(top: 10),
              height: 50,
              width: 550,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.only(right: 10),
                    height: 50,
                    width: 200,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          addPengungjung(true);
                        });
                      },
                      child: Text('Tambah Pengujunjung Lama',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 10),
                    height: 50,
                    width: 200,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          addPengungjung(false);
                        });
                      },
                      child: Text('Tambah Pengujunjung Baru',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              )),
        ]));
  }

  Widget addDokumentasi() {
    return Column(children: [
      SizedBox(
          height: heightAddDokumentasi + 20,
          child: ListView.builder(
            itemCount: dynamicDokumentasi.length,
            itemBuilder: (_, index) {
              return Container(
                  padding: EdgeInsets.only(top: 10),
                  alignment: Alignment.center,
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
        margin: EdgeInsets.only(top: 10, bottom: 10),
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
        width: 1050,
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          multiTabNavigator(0, Icons.info_outline, "General Information"),
          multiTabNavigator(1, Icons.person, "Personil"),
          multiTabNavigator(2, EventChart.chart_line, "Realisasi"),
          multiTabNavigator(3, Transaction.attach_money, "Penjualan"),
          multiTabNavigator(4, Icons.note_alt_outlined, "Evaluasi")
        ]));
  }

  Widget buildFinalisasi() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 5,
                child: ExpansionTile(
                  title: Text(
                    "DOKUMENTASI KEGIATAN",
                    textAlign: TextAlign.center,
                    style: (TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  children: [addDokumentasi()],
                ))),
        Padding(
            padding: EdgeInsets.only(bottom: 10, top: 10),
            child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 5,
                child: ExpansionTile(
                  title: Text(
                    "EVALUASI",
                    textAlign: TextAlign.center,
                    style: (TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  children: [
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: TextField(
                        controller: evaluasiController,
                        decoration: const InputDecoration(
                          labelText: 'Isikan evaluasi kegiatan (max 5 baris)',
                        ),
                        maxLines: 5,
                      ),
                    )
                  ],
                ))),
      ],
    );
  }

  Widget buildTarget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 5,
                child: ExpansionTile(
                  title: Text(
                    "TARGET",
                    textAlign: TextAlign.center,
                    style: (TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  children: [updateTarget()],
                ))),
        Padding(
            padding: EdgeInsets.only(bottom: 10, top: 10),
            child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 5,
                child: ExpansionTile(
                  title: Text(
                    "KEBUTUHAN TAMBAHAN",
                    textAlign: TextAlign.center,
                    style: (TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  children: [updateKebutuhan()],
                ))),
        Padding(
            padding: EdgeInsets.only(top: 10),
            child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 5,
                child: ExpansionTile(
                  title: Text(
                    "GIMMICK",
                    textAlign: TextAlign.center,
                    style: (TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  children: [updateGimmick()],
                )))
      ],
    );
  }

  Widget generalInformationComponent(type, title, text) {
    return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 5,
        child: ExpansionTile(
            title: Text(
              title,
              textAlign: TextAlign.center,
              style: (TextStyle(fontWeight: FontWeight.bold)),
            ),
            children: [
              Container(
                  margin:
                      EdgeInsets.only(left: 40, right: 40, top: 10, bottom: 10),
                  child: type == 0
                      ? Text(text,
                          style: TextStyle(
                            height: 1.5,
                          ))
                      : RichText(
                          text: TextSpan(
                            style: const TextStyle(
                                fontSize: 13.0, color: Colors.black, height: 2),
                            children: [
                              TextSpan(text: 'ID Event: '),
                              TextSpan(
                                  text: widget.event_id,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              TextSpan(text: '\nNama Event: '),
                              TextSpan(
                                  text: _event!.nama,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              TextSpan(text: '\nPenanggung Jawab: '),
                              TextSpan(
                                  text: widget.penanggung_jawab,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: Divider()),
                              TextSpan(
                                  text: "LOKASI:",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              TextSpan(text: '\nKelurahan: '),
                              TextSpan(
                                  text: _event!.lokasi![0]['kelurahan'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              TextSpan(text: ', Kecamatan: '),
                              TextSpan(
                                  text: _event!.lokasi![0]['kecamatan'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              TextSpan(text: ', Kota: '),
                              TextSpan(
                                  text: _event!.lokasi![0]['kota'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              TextSpan(text: ', Provinsi: '),
                              TextSpan(
                                  text: _event!.lokasi![0]['provinsi'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              TextSpan(text: '\nAlamat: '),
                              TextSpan(
                                  text: _event!.lokasi![0]['alamat'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ))
            ]));
  }

  Widget buildGeneralInformation() {
    if (MediaQuery.of(context).size.width >= 720) {
      return Table(children: [
        TableRow(children: [
          Container(
              width: 500,
              padding: EdgeInsets.only(left: 5, bottom: 20),
              child: generalInformationComponent(1, "TENTANG EVENT", "")),
          Container(
              width: 500,
              padding: EdgeInsets.only(right: 5, bottom: 20),
              child: generalInformationComponent(
                  0, "LATAR BELAKANG", _event!.latar_belakang!.toString())),
        ]),
        TableRow(children: [
          Container(
              width: 500,
              padding: EdgeInsets.only(left: 5, bottom: 20),
              child: generalInformationComponent(
                  0, "TUJUAN", _event!.tujuan!.toString())),
          Container(
              width: 500,
              padding: EdgeInsets.only(right: 5, bottom: 20),
              child: generalInformationComponent(
                  0, "STRATEGI", _event!.strategi!.toString())),
        ]),
      ]);
    } else {
      return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: generalInformationComponent(
                1, "TENTANG EVENT", _event!.latar_belakang!.toString())),
        Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: generalInformationComponent(
                0, "LATAR BELAKANG", _event!.latar_belakang!.toString())),
        Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: generalInformationComponent(
                0, "TUJUAN", _event!.tujuan!.toString())),
        Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: generalInformationComponent(
                0, "STRATEGI", _event!.strategi!.toString())),
      ]);
    }
  }

  warningDialog(message) {
    if (isDialogShow == false) {
      isDialogShow = true;
      return showDialog<String>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
                title: Row(
                  children: [Icon(Icons.warning), Text("  PERINGATAN")],
                ),
                content: SizedBox(width: 500, child: Text(message)),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, 'Tidak');
                      isDialogShow = false;
                    },
                    child: const Text('Ok'),
                  ),
                ],
              ));
    } else {
      return;
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
    return SingleChildScrollView(
        child: Container(
      width: 1050,
      alignment: Alignment.topCenter,
      padding: EdgeInsets.only(top: 20, bottom: 20),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
            alignment: Alignment.topLeft,
            padding: EdgeInsets.only(top: 20),
            child: SingleChildScrollView(
                scrollDirection: Axis.horizontal, child: multiTabIndicator())),
        Container(
            alignment: Alignment.topLeft,
            padding: EdgeInsets.only(top: 20, left: 10, right: 10),
            child: index == 0
                ? buildGeneralInformation()
                : index == 1
                    ? tabelPersonil()
                    : index == 2
                        ? buildTarget()
                        : index == 3
                            ? buildPengunjung()
                            : buildFinalisasi()),
        Container(
            padding: EdgeInsets.only(left: 10, right: 10),
            alignment: index == 0
                ? Alignment.bottomRight
                : index == 4
                    ? Alignment.bottomLeft
                    : Alignment.bottomCenter,
            child: index == 0
                ? arrowNavigator(1)
                : index == 4
                    ? arrowNavigator(0)
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [arrowNavigator(0), arrowNavigator(1)])),
        if (index == 4)
          Container(
            margin: EdgeInsets.only(top: 50),
            height: 50,
            width: 1050,
            child: ElevatedButton(
              onPressed: () {
                bool isKebutuhanOK = false,
                    isGimmickOk = false,
                    isTargetOk = false,
                    isDokumentasiOk = false,
                    isPengunjungOk = false,
                    isStokOK = false;
                if (dynamicKebutuhanTambahan.isNotEmpty) {
                  for (var element in dynamicKebutuhanTambahan) {
                    if (element.isiRealisasi.text != "") {
                      isKebutuhanOK = true;
                      kebutuhanTambahan
                          .add([element.id, element.isiRealisasi.text]);
                      total_biaya += int.parse(element.isiRealisasi.text);
                    } else {
                      isKebutuhanOK = false;
                      warningDialog(
                          "Terdapat kekosongan data pada kebutuhan tambahan bagian realisasi biaya kebutuhan.\nHarap melengkapi data tersebut sebelum melakukan finalisasi");
                      break;
                    }
                  }
                } else {
                  isKebutuhanOK = true;
                }
                if (dynamicGimmick.isNotEmpty) {
                  for (var widget in dynamicGimmick) {
                    if (widget.jumlahRealisasi.text != "") {
                      isGimmickOk = true;
                      gimmick.add([
                        widget.id,
                        widget.jumlahRealisasi.text,
                        widget.hargaProposal
                      ]);
                      total_biaya += (int.parse(widget.jumlahRealisasi.text) *
                          widget.hargaProposal);
                    } else {
                      isGimmickOk = false;
                      warningDialog(
                          "Terdapat kekosongan data pada gimmick bagian jumlah realisasi.\nHarap melengkapi data tersebut sebelum melakukan finalisasi");
                      break;
                    }
                  }
                } else {
                  isGimmickOk = true;
                }
                if (dynamicDokumentasi.isNotEmpty) {
                  for (var widget in dynamicDokumentasi) {
                    if (widget.alamatController.text != "" &&
                        widget.dokumentasi != null) {
                      isDokumentasiOk = true;
                      dokumentasi.add([
                        base64Encode(widget.dokumentasi),
                        widget.waktuController.text,
                        widget.alamatController.text
                      ]);
                    } else if (widget.alamatController.text == "") {
                      isDokumentasiOk = false;
                      warningDialog(
                          "Terdapat kekosongan data pada dokumentasi bagian alamat.\nHarap melengkapi data tersebut sebelum melakukan finalisasi");
                      break;
                    } else {
                      isDokumentasiOk = false;
                      warningDialog(
                          "Foto dokumentasi masih kosong.\nHarap melakukan pengunggahan foto sebelum melakukan finalisasi");
                      break;
                    }
                  }
                } else {
                  isDokumentasiOk = false;
                  warningDialog(
                      "Tidak ada dokumentasi tercatat. Harap unggah dokumentasi beserta datanya agar laporan dapat divaliadasi");
                }

                if (dynamicPengunjung.isNotEmpty) {
                  for (var widget in dynamicPengunjung) {
                    if (widget.dynamicPenjualan.isNotEmpty) {
                      for (var element in widget.dynamicPenjualan) {
                        if (element.quantityController.text != "") {
                          isStokOK = true;
                          stok.add([
                            element.id_produk,
                            int.parse(element.quantityController.text)
                          ]);
                          widget.productBought.add([
                            element.id_produk,
                            int.parse(element.quantityController.text),
                            element.harga
                          ]);
                          total_penjualan +=
                              (int.parse(element.quantityController.text) *
                                  element.harga);
                        } else {
                          isStokOK = false;
                          warningDialog(
                              "Terdapat kekosongan data pada penjualan product bagian jumlah produk yang terjual.\nHarap melengkapi data tersebut sebelum melakukan finalisasi");
                          break;
                        }
                      }
                      if (isStokOK == false) {
                        break;
                      } else {
                        if (widget.isLama == true) {
                          if (widget.username == "") {
                            isPengunjungOk = false;
                            warningDialog(
                                "Terdapat data pengunjung lama yang masih kosong.\nHarap melengkapi data tersebut sebelum melakukan finalisasi");
                            break;
                          } else {
                            isPengunjungOk = true;
                            pengunjungLama
                                .add([widget.username, widget.productBought]);
                          }
                        } else {
                          if (widget.controllerUsername.text == "" ||
                              widget.controllerNama.text == "" ||
                              widget.controllerTelepon.text == "" ||
                              widget.controllerUsia.text == "" ||
                              widget.controllerAlamat.text == "") {
                            isPengunjungOk = false;
                            warningDialog(
                                "Terdapat kekosongan data pada pengisian pengunjung baru.\nHarap melengkapi data tersebut sebelum melakukan finalisasi");
                            break;
                          } else {
                            isPengunjungOk = true;
                            pengunjungBaru.add([
                              widget.controllerUsername.text,
                              widget.controllerNama.text,
                              widget.controllerTelepon.text,
                              widget.controllerUsia.text,
                              widget.controllerAlamat.text,
                              widget.gender,
                              widget.productBought
                            ]);
                          }
                        }
                      }
                    } else {
                      isStokOK = false;
                      warningDialog(
                          "Ada data pengunjung yang tidak melakukan pembelian product.\nHarap melengkapi data tersebut sebelum melakukan finalisasi");
                      break;
                    }
                  }
                } else {
                  warningDialog(
                      "Tidak ada pengunjung tercatat. Harap melengkapi data pengunjung beserta data penjualannya");
                }

                for (var widget in dynamicTarget) {
                  isTargetOk = true;
                  if (widget.id == 1) {
                    if (widget.isiRealisasi.text == "") {
                      isTargetOk = false;
                      warningDialog(
                          "Terdapat kekosongan data pada target bagian realisasi jumlah pengunjung.\nHarap melengkapi data tersebut sebelum melakukan finalisasi");
                      break;
                    } else {
                      isTargetOk = true;
                      target.add([widget.id, widget.isiRealisasi.text]);
                    }
                  } else if (widget.id == 2) {
                    isTargetOk = true;
                    target.add([widget.id, pengunjungBaru.length]);
                  } else if (widget.id == 3) {
                    isTargetOk = true;
                    target.add([widget.id, pengunjungLama.length]);
                  } else if (widget.id == 4) {
                    isTargetOk = true;
                    target.add([widget.id, total_penjualan]);
                  } else if (widget.id == 7) {
                    isTargetOk = true;
                    target.add([widget.id, total_biaya]);
                  } else if (widget.id == 8) {
                    isTargetOk = true;
                    double value = (total_biaya / total_penjualan) * 100;
                    target.add([widget.id, value]);
                  }
                }

                // if (isKebutuhanOK == true &&
                //     isTargetOk == true &&
                //     isGimmickOk == true &&
                //     isDokumentasiOk == true &&
                //     isStokOK == true &&
                //     isPengunjungOk == true &&
                //     evaluasiController.text != "") {
                //   print(id_cabang);

                showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                          title: const Text('Peringatan'),
                          content: Text(
                              "Apakah anda yakin hendak mem-finalisasi laporan? \nData pada laporan tidak dapat diubah, kecuali laporan tidak disetujui"),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                submit(context);
                                // print(target);
                                setState(() {
                                  clearData();
                                });
                              },
                              child: const Text('Iya'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context, 'Tidak');
                              },
                              child: const Text('Tidak'),
                            ),
                          ],
                        ));
                // } else {
                //   kebutuhanTambahan = [];
                //   gimmick = [];
                //   target = [];
                //   dokumentasi = [];
                //   pengunjungBaru = [];
                //   pengunjungLama = [];
                //   stok = [];
                //   for (var widget in dynamicPengunjung) {
                //     widget.productBought = [];
                //   }
                //   if (evaluasiController.text == "") {
                //     warningDialog("Harap lengkapi data evaluasi");
                //   }
                // }
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
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title:
              Text("Buat Laporan Event", style: TextStyle(color: Colors.white)),
          leading: BackButton(
            color: Colors.white,
            onPressed: () {
              Navigator.popAndPushNamed(context, "/homepage");
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
