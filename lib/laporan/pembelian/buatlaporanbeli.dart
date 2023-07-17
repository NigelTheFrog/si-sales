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
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:pt_coronet_crown/class/produk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dropdown_search/dropdown_search.dart';

class dynamicWidgetBeli extends StatefulWidget {
  TextEditingController quantityController = TextEditingController();
  TextEditingController hargaController = TextEditingController();
  int idProdukController = 0;
  dynamicWidgetBeli({Key? key}) : super(key: key);
  @override
  _dynamicWidgetBeliState createState() {
    return _dynamicWidgetBeliState();
  }
}

class _dynamicWidgetBeliState extends State<dynamicWidgetBeli> {
  List produk = [];

  Widget comboProduct() {
    return SizedBox(
      width: 480,
      child: DropdownSearch<dynamic>(
        dropdownSearchDecoration: InputDecoration(
          labelText: "Daftar Personil",
        ),
        mode: Mode.MENU,
        showSearchBox: false,
        onFind: (text) async {
          Map json;
          var response = await http.post(
            Uri.parse(
                "https://otccoronet.com/otc/admin/product/daftarproduct.php"),
          );

          if (response.statusCode == 200) {
            json = jsonDecode(response.body);
            setState(() {
              produk = json['data'];
            });
          }
          return produk as List<dynamic>;
        },
        onChanged: (value) {
          widget.idProdukController = value['id'] as int;
        },
        itemAsString: (item) => item['jenis'],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width >= 720 ? 420 : 323,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          SizedBox(
            height: 50,
            width: MediaQuery.of(context).size.width >= 720 ? 150 : 136,
            child: comboProduct(),
          ),
          SizedBox(
              height: 50,
              width: MediaQuery.of(context).size.width >= 720 ? 110 : 50,
              child: TextFormField(
                style: TextStyle(
                    fontSize:
                        MediaQuery.of(context).size.width >= 720 ? 14 : 12),
                controller: widget.quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                ),
                keyboardType: TextInputType.number,
              )),
          SizedBox(
              height: 50,
              width: MediaQuery.of(context).size.width >= 720 ? 140 : 115,
              child: TextFormField(
                style: TextStyle(
                    fontSize:
                        MediaQuery.of(context).size.width >= 720 ? 14 : 12),
                controller: widget.hargaController,
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

class BuatPembelian extends StatefulWidget {
  BuatPembelian({Key? key}) : super(key: key);
  @override
  _BuatPembelianState createState() {
    return _BuatPembelianState();
  }
}

class _BuatPembelianState extends State<BuatPembelian> {
  late Timer timer;
  double heightAddItem = 0;
  int id = Random().nextInt(4294967296);
  String _id_supplier = "",
      _username = "",
      _ppn = "",
      _diskon = "",
      id_cabang = "";
  var _foto = null, _foto_proses = null;
  List _supplier = [];

  List<dynamicWidgetBeli> dynamicList = [];
  List<String> harga = [];
  List<String> quantity = [];
  List<int> id_produk = [];

  final picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  final fileName = TextEditingController();

  _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _username = prefs.getString("username") ?? '';
    id_cabang = prefs.getString("idCabang") ?? '';
  }

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
    if (_foto_proses != null) {
      base64Image = base64Encode(_foto_proses);
    } else {
      base64Image = "";
    }
    final response = await http.post(
        Uri.parse(
            "https://otccoronet.com/otc/laporan/pembelian/buatlaporan.php"),
        body: {
          'id': id.toString(),
          'id_supplier': _id_supplier,
          'username': _username,
          'foto': base64Image,
          'diskon': _diskon,
          'ppn': _ppn,
          'id_cabang': id_cabang,
          'harga': jsonEncode(harga),
          'quantity': jsonEncode(quantity),
          'id_produk': jsonEncode(id_produk)
        });
    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      if (json['result'] == 'success') {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Sukses Menambah Data')));
        dispose();
        Navigator.popAndPushNamed(context, "/daftarpembelian");
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadData();
    timer = Timer.periodic(const Duration(milliseconds: 250), (timer) {
      setState(() {
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
    _foto = File(picked_img!.path);
    prosesFoto();
  }

  addDynamic() {
    setState(() {
      if (quantity.isNotEmpty) {
        quantity = [];
        harga = [];
        id_produk = [];
        dynamicList = [];
      }
      dynamicList.add(dynamicWidgetBeli());
      heightAddItem += 50;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: BackButton(
            onPressed: () {
              Navigator.popAndPushNamed(context, "/daftarpembelian");
            },
          ),
          title: Text("Buat Laporan Pembelian"),
        ),
        body: SingleChildScrollView(
            child: Container(
          alignment: Alignment.center,
          child: Form(
            key: _formKey,
            child: Container(
                padding: EdgeInsets.all(20),
                width: 500,
                child: Column(children: <Widget>[
                  Text("ISIKAN DATA PEMBELIAN \n",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Container(
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    alignment: Alignment.center,
                    child: DropdownSearch<dynamic>(
                      dropdownSearchDecoration: InputDecoration(
                        labelText: "Daftar Supplier",
                      ),
                      mode: Mode.MENU,
                      showSearchBox: true,
                      onFind: (text) async {
                        Map json;
                        var response = await http.post(
                            Uri.parse(
                                "https://otccoronet.com/otc/supplier/daftarsupplier.php"),
                            body: {'cari': text});

                        if (response.statusCode == 200) {
                          json = jsonDecode(response.body);
                          setState(() {
                            _supplier = json['data'];
                          });
                        }
                        return _supplier as List<dynamic>;
                      },
                      onChanged: (value) {
                        setState(() {
                          _id_supplier = value['id'];
                        });
                      },
                      itemAsString: (item) => item['nama_supplier'],
                    ),
                  ),
                  Container(
                      height: heightAddItem,
                      child: ListView.builder(
                        itemCount: dynamicList.length,
                        itemBuilder: (_, index) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.start,
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
                  Padding(
                      padding: EdgeInsets.only(top: 10, bottom: 10),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                                padding: EdgeInsets.only(right: 10),
                                width: MediaQuery.of(context).size.width >= 720
                                    ? 230
                                    : 180,
                                child: TextFormField(
                                  style: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width >=
                                                  720
                                              ? 14
                                              : 12),
                                  decoration: const InputDecoration(
                                    labelText: 'Diskon (diskon total)',
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
                            Container(
                                width: MediaQuery.of(context).size.width >= 720
                                    ? 230
                                    : 180,
                                padding: EdgeInsets.only(left: 10),
                                child: TextFormField(
                                  style: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width >=
                                                  720
                                              ? 14
                                              : 12),
                                  decoration: const InputDecoration(
                                    labelText: 'PPN (dalam %)',
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
                          ])),
                  Text("UNGGAH FOTO NOTA \n",
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width >= 720
                            ? 350
                            : 290,
                        height: 60,
                        child: TextFormField(
                          controller: fileName,
                          style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width >= 720
                                  ? 14
                                  : 12,
                              color: Colors.grey),
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
                      SizedBox(
                        height: 50,
                        width: 60,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_foto_proses == null) {
                              if (kIsWeb) {
                                chooseImg();
                              } else {
                                captureImg();
                              }
                            } else {
                              setState(() {
                                _foto_proses = null;
                                fileName.text = "";
                              });
                            }
                          },
                          child: _foto_proses == null
                              ? Icon(Icons.upload)
                              : const Icon(Icons.delete),
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
                          dynamicList.forEach((widget) =>
                              quantity.add(widget.quantityController.text));
                          dynamicList.forEach((widget) =>
                              harga.add(widget.hargaController.text));
                          dynamicList.forEach((widget) =>
                              id_produk.add(widget.idProdukController));
                          if (_formKey.currentState != null &&
                              !_formKey.currentState!.validate()) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text('Harap Isian diperbaiki')));
                          } else {
                            submit(context);
                          }
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
