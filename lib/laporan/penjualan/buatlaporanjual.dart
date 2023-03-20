import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:pt_coronet_crown/admin/personel/personeldata.dart';
import 'package:pt_coronet_crown/class/cabang.dart';
import 'package:pt_coronet_crown/class/jabatan.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:pt_coronet_crown/class/produk.dart';
import 'package:shared_preferences/shared_preferences.dart';

class dynamicWidget extends StatefulWidget {
  dynamicWidget({Key? key}) : super(key: key);
  @override
  _dynamicWidgetState createState() {
    return _dynamicWidgetState();
  }
}

class _dynamicWidgetState extends State<dynamicWidget> {
  TextEditingController quantityController = new TextEditingController();
  TextEditingController hargaController = new TextEditingController();
  late Timer timer;

  int id_produk = 0;
  String controllerProduct = "";

  Future<List> daftarproduct() async {
    Map json;
    final response = await http.post(
      Uri.parse("http://localhost/magang/admin/product/daftarproduct.php"),
    );
    if (response.statusCode == 200) {
      json = jsonDecode(response.body);
      return json['data'];
    } else {
      throw Exception('Failed to read API');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    timer = Timer.periodic(const Duration(milliseconds: 250), (timer) {
      setState(() {
        generateDaftarProduct();
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    quantityController.dispose();
    timer.cancel();
    hargaController.dispose();
  }

  Widget comboProduct = Text("");

  void generateDaftarProduct() {
    List<Produk> produks;
    var data = daftarproduct();
    data.then((value) {
      produks = List<Produk>.from(value.map((i) {
        return Produk.fromJson(i);
      }));
      setState(() {
        comboProduct = DropdownButtonHideUnderline(
            child: DropdownButton(
                hint: controllerProduct == ""
                    ? Text("Daftar Product")
                    : Text(
                        controllerProduct,
                        style: TextStyle(color: Colors.black),
                      ),
                isDense: false,
                items: produks.map((produk) {
                  return DropdownMenuItem(
                    child: Text(produk.jenis),
                    value: [produk.id, produk.jenis],
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    id_produk = value![0] as int;
                    controllerProduct = value[1].toString();
                  });
                }));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 440,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          SizedBox(
            height: 50,
            width: 150,
            child: comboProduct,
          ),
          SizedBox(
              height: 50,
              width: 100,
              child: TextFormField(
                controller: quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                ),
                keyboardType: TextInputType.number,
              )),
          SizedBox(
              height: 50,
              width: 150,
              child: TextFormField(
                controller: hargaController,
                decoration: const InputDecoration(
                  labelText: 'Harga (per barang)',
                ),
                keyboardType: TextInputType.number,
              )),
        ],
      ),
    );
  }
}

class BuatPenjualan extends StatefulWidget {
  BuatPenjualan({Key? key}) : super(key: key);
  @override
  _BuatPenjualanState createState() {
    return _BuatPenjualanState();
  }
}

class _BuatPenjualanState extends State<BuatPenjualan> {
  late Timer timer;
  double heightAddItem = 0;
  int id = Random().nextInt(4294967296);
  String _id_outlet = "", _username = "", _ppn = "", _diskon = "";
  String controllerOutlet = "";
  var _foto = null, _foto_proses = null;

  List<dynamicWidget> dynamicList = [];
  List<String> harga = [];
  List<String> quantity = [];

  final picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  final fileName = TextEditingController();

  _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _username = prefs.getString("username") ?? '';
  }

  // Future<List> daftaroutlet() async {
  //   Map json;
  //   final response = await http.post(
  //     Uri.parse("http://localhost/magang/admin/cabang/daftarcabang.php"),
  //   );

  //   if (response.statusCode == 200) {
  //     json = jsonDecode(response.body);
  //     return json['data'];
  //   } else {
  //     throw Exception('Failed to read API');
  //   }
  // }

  void warningDialog(context, warning_message) {
    showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Text('Peringatan'),
              content: Text(warning_message),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context, 'OK'),
                  child: const Text('OK'),
                ),
              ],
            ));
  }

  void submit(BuildContext context) async {
    var base64Image;
    if (_foto_proses == null) {
      base64Image = null;
    } else {
      base64Image = base64Encode(_foto_proses);
    }
    final response = await http.post(
        Uri.parse("http://localhost/magang/laporan/penjualan/buatlaporan.php"),
        body: {
          'id': id,
          'id_outlet': _id_outlet,
          'username': _username,
          'foto': base64Image,
          'diskon': _diskon,
          'ppn': _ppn
        });
    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      if (json['result'] == 'success') {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Sukses Menambah Data')));
        dispose();
      } else if (json['Error'] ==
          "Got a packet bigger than 'max_allowed_packet' bytes") {
        setState(() {
          warningDialog(context, "Ukuran gambar terlalu besar");
        });
      }
    } else {
      throw Exception('Failed to read API');
    }
  }

  Widget comboProduct = Text("");
  Widget comboJabatan = Text("");

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    timer = Timer.periodic(const Duration(milliseconds: 250), (timer) {
      setState(() {
        _loadData();
        // generatDaftarJabatan();
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    timer.cancel();
    super.dispose();
  }

  // void generatDaftarJabatan() {
  //   List<Jabatan> jabatans;
  //   var data = daftarJabatan();
  //   data.then((value) {
  //     jabatans = List<Jabatan>.from(value.map((i) {
  //       return Jabatan.fromJson(i);
  //     }));
  //     setState(() {
  //       comboJabatan = DropdownButtonHideUnderline(
  //           child: DropdownButton(
  //               hint: controllerJabatan == ""
  //                   ? Text("Daftar Jabatan")
  //                   : Text(
  //                       controllerJabatan,
  //                       style: TextStyle(color: Colors.black),
  //                     ),
  //               isDense: false,
  //               items: jabatans.map((jabatan) {
  //                 return DropdownMenuItem(
  //                   child: Text(jabatan.jabatan),
  //                   value: [jabatan.id, jabatan.jabatan],
  //                 );
  //               }).toList(),
  //               onChanged: (value) {
  //                 setState(() {
  //                   _jabatan = value![0].toString();
  //                   controllerJabatan = value[1].toString();
  //                 });
  //               }));
  //     });
  //   });
  // }

  void prosesFoto() {
    Future<Directory?> extDir = getTemporaryDirectory();
    extDir.then((value) {
      String _timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String filePath = '${value?.path}/$_timestamp.jpg';
      _foto_proses = File(filePath);
      img.Image? temp = img.readJpg(_foto!.readAsBytesSync());
      img.Image temp2 = img.copyResize(temp!, width: 500, height: 480);
      setState(() {
        _foto_proses = Uint8List.fromList(img.encodeJpg(temp2));
      });
    });
  }

  Future chooseImg() async {
    FilePickerResult fileResult =
        await FilePicker.platform.pickFiles() as FilePickerResult;
    fileName.text = fileResult.names.first!;
    if (fileResult != null) {
      setState(() {
        _foto = fileResult.files.first.bytes;
        img.Image? temp = img.decodeImage(_foto!);
        img.Image temp2 = img.copyResize(temp!, width: 500, height: 523);
        _foto_proses = Uint8List.fromList(img.encodeJpg(temp2));
      });
    }
  }

  Future captureImg() async {
    var picked_img =
        await picker.pickImage(source: ImageSource.camera, imageQuality: 20);
    // setState(() {
    _foto = File(picked_img!.path);
    prosesFoto();

    //});
  }

  addDynamic() {
    setState(() {
      if (quantity.isNotEmpty) {
        quantity = [];
        harga = [];
        dynamicList = [];
      }
      dynamicList.add(dynamicWidget());
      heightAddItem += 50;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Buat Laporan Penjualan"),
        ),
        body: SingleChildScrollView(
            child: Container(
          alignment: Alignment.center,
          child: Form(
            key: _formKey,
            child: Container(
                padding: EdgeInsets.all(10),
                width: 500,
                child: Column(children: <Widget>[
                  Padding(
                      padding: EdgeInsets.all(10),
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Diskon',
                        ),
                        onChanged: (value) {
                          _diskon = value;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            _diskon = "0";
                          }
                          return null;
                        },
                      )),
                  Padding(
                      padding: EdgeInsets.all(10),
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'PPN',
                        ),
                        onChanged: (value) {
                          _ppn = value;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            _ppn = "0";
                          }
                          return null;
                        },
                      )),
                  Container(
                      alignment: Alignment.center,
                      height: heightAddItem,
                      child: ListView.builder(
                        itemCount: dynamicList.length,
                        itemBuilder: (_, index) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              dynamicList[index],
                              Tooltip(
                                message: "Delete product",
                                child: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      dynamicList.removeAt(index);
                                      heightAddItem -= 50;
                                    });

                                    // harga.removeAt(index);
                                    // quantity.removeAt(index);
                                  },
                                  icon: Icon(Icons.delete),
                                ),
                              )
                            ],
                          );
                        },
                      )),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      height: 50,
                      width: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            addDynamic();
                          });
                        },
                        child: Text(
                          '+',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  Text("UNGGAH FOTO NOTA (JIKA ADA) \n",
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: 320,
                        height: 50,
                        child: TextFormField(
                          controller: fileName,
                          style: TextStyle(color: Colors.grey),
                          enabled: false,
                          decoration: InputDecoration(
                            labelText: "Foto nota",
                            labelStyle: TextStyle(color: Colors.grey),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  width: 2, color: Colors.blue), //<-- SEE HERE
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 50,
                        width: 120,
                        child: ElevatedButton(
                          onPressed: () {
                            if (kIsWeb) {
                              chooseImg();
                            } else {
                              captureImg();
                            }
                          },
                          child: Text('Upload file'),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 10),
                    child: _foto_proses == null
                        ? const Text("")
                        : SizedBox(
                            height: 480,
                            width: 500,
                            child: Image.memory(_foto_proses!),
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Container(
                      height: 50,
                      width: 300,
                      child: ElevatedButton(
                        onPressed: () {
                          print("harga = $harga \n quantity = $quantity");
                          // if (_formKey.currentState != null &&
                          //     !_formKey.currentState!.validate()) {
                          //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          //       content: Text('Harap Isian diperbaiki')));
                          // } else {
                          //
                          // }
                        },
                        child: Text('Submit'),
                      ),
                    ),
                  )
                ])),
          ),
        )));
  }
}
