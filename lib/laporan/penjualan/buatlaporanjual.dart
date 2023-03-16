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

class BuatPenjualan extends StatefulWidget {
  BuatPenjualan({Key? key}) : super(key: key);
  @override
  _BuatPenjualanState createState() {
    return _BuatPenjualanState();
  }
}

class _BuatPenjualanState extends State<BuatPenjualan> {
  late Timer timer;
  int count = 1;
  int id = Random().nextInt(4294967296), id_produk = 0;
  String _id_outlet = "", _username = "", _ppn = "", _diskon = "";
  String controllerProduct = "", controllerOutlet = "";
  var _foto = null, _foto_proses = null, listOfProduct = [];
  List<Widget> _productList = [];

  final picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

  _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _username = prefs.getString("username") ?? '';
  }

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
        generateDaftarProduct();
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
      img.Image temp2 = img.copyResize(temp!, width: 500, height: 500);
      setState(() {
        _foto_proses = Uint8List.fromList(img.encodeJpg(temp2));
      });
    });
  }

  Future chooseImg() async {
    FilePickerResult fileResult =
        await FilePicker.platform.pickFiles() as FilePickerResult;
    if (fileResult != null) {
      setState(() {
        _foto = fileResult.files.first.bytes;
        img.Image? temp = img.decodeImage(_foto!);
        img.Image temp2 = img.copyResize(temp!, width: 500, height: 500);
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

  Widget addItem() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      SizedBox(
        height: 50,
        width: 150,
        child: comboProduct,
      ),
      SizedBox(
          height: 50,
          width: 100,
          child: TextFormField(
            decoration: const InputDecoration(
              labelText: 'Quantity',
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
      SizedBox(
          height: 50,
          width: 150,
          child: TextFormField(
            decoration: const InputDecoration(
              labelText: 'Harga (per barang)',
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
      Tooltip(
        message: "Delete product",
        child: IconButton(
          onPressed: () {},
          icon: Icon(Icons.delete),
        ),
      )
    ]);
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
                    height: 100,
                    width: 600,
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    child: ListView.builder(
                        itemCount: _productList.length,
                        itemBuilder: (context, index) {
                          return _productList[index];
                        }),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      height: 50,
                      width: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _productList.add(addItem());
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
                  Text("UNGGAH FOTO NOTA (JIKA ADA)",
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  Padding(
                      padding: EdgeInsets.all(10),
                      child: GestureDetector(
                          onTap: () {
                            if (kIsWeb) {
                              chooseImg();
                            } else {
                              captureImg();
                            }
                          }, // Image tapped
                          child: Container(
                            height: 480,
                            width: 500,
                            color: Colors.blue,
                            child: _foto_proses == null
                                ? Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Belum ada gambar diambil',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  )
                                : Image.memory(_foto_proses!),
                            // : Image.file(_avatar_proses!),
                          ))),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Container(
                      height: 50,
                      width: 300,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState != null &&
                              !_formKey.currentState!.validate()) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text('Harap Isian diperbaiki')));
                          } else
                            submit(context);
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
