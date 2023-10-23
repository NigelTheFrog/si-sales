import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pt_coronet_crown/class/admin/absen/kunjungan.dart';
import 'package:pt_coronet_crown/customicon/add_image_icons.dart';
import 'package:pt_coronet_crown/customicon/add_penjualan_icons.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:shared_preferences/shared_preferences.dart';

class DetailVisit extends StatefulWidget {
  int type, status;
  String id_visit, username;
  DetailVisit(
      {super.key,
      required this.type,
      required this.id_visit,
      required this.status,
      required this.username});
  @override
  State<StatefulWidget> createState() {
    return _DetailVisitState();
  }
}

class _DetailVisitState extends State<DetailVisit> {
  Kunjungan? kunjungan;
  TextEditingController deskripsi = TextEditingController();
  TextEditingController outlet = TextEditingController();
  var _foto, _foto_proses, id_nota;
  final picker = ImagePicker(), fileName = TextEditingController();
  String username = "";

  Future<String> fetchData() async {
    final response = await http.post(
        Uri.parse(
            "https://otccoronet.com/otc/account/kunjungan/detailkunjungan.php"),
        body: {'id': widget.id_visit});
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to read API');
    }
  }

  void submit(context) async {
    final response = await http.post(
        Uri.parse(
            "https://otccoronet.com/otc/account/kunjungan/checkoutkunjungan.php"),
        body: {
          'id': widget.id_visit,
          'bukti': base64Encode(_foto_proses),
        });
    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      if (json['result'] == 'success') {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Sukses menyimpan data kunjungan')));
        Navigator.popAndPushNamed(context, "/home");
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sukses menyimpan data kunjungan')));
    }
  }

  bacadata() {
    fetchData().then((value) {
      Map json = jsonDecode(value);
      kunjungan = Kunjungan.fromJson(json['data']);
      setState(() {
        deskripsi.text = kunjungan!.deskripsi;
        outlet.text = kunjungan!.nama_toko;
        _foto_proses = base64Decode(kunjungan!.foto.toString());
        id_nota = kunjungan!.id_nota;
      });
    });
  }

  _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString("username") ?? '';
    });
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
        showBukti(context, _foto_proses);
      });
    });
  }

  captureImg(BuildContext context) async {
    var picked_img =
        await picker.pickImage(source: ImageSource.camera, imageQuality: 20);
    _foto = File(picked_img!.path);
    prosesFoto();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    bacadata();
  }

  showBukti(BuildContext context, foto) {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
            content: SizedBox(
                height: 350,
                width: 500,
                child: Column(
                  children: [
                    Image.memory(foto),
                    if (widget.status == 0 && widget.username == username)
                      Container(
                          height: 50,
                          padding: const EdgeInsets.only(top: 10),
                          child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                captureImg(context);
                              },
                              child: const Center(
                                child: Text('Ambil foto ulang',
                                    style: TextStyle(color: Colors.white)),
                              )))
                  ],
                ))));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title:
              Text("Halaman Kunjungan", style: TextStyle(color: Colors.white)),
          leading: BackButton(
            color: Colors.white,
            onPressed: () {
              if (widget.type == 1) {
                Navigator.popAndPushNamed(context, "/homepage");
              } else if (widget.type == 2) {
                Navigator.pop(context);
              } else {
                Navigator.popAndPushNamed(context, "/dailyvisit");
              }
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
              height: MediaQuery.of(context).size.height,
              alignment: Alignment.topCenter,
              width: 720,
              child: Column(
                children: [
                  Container(
                      alignment: Alignment.topLeft,
                      padding: EdgeInsets.all(10),
                      child: Text(
                        "Lokasi",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      )),
                  Container(
                    height: 250,
                    margin: EdgeInsets.only(left: 10, right: 10),
                    child: Align(
                        alignment: Alignment.center,
                        child: Image.network(
                            "https://otccoronet.com/otc/asset/maps.jpeg")),
                  ),
                  Container(
                      padding: EdgeInsets.only(left: 10, right: 10, top: 10),
                      alignment: Alignment.center,
                      child: TextField(
                        controller: outlet,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Outlet',
                        ),
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width >= 720
                              ? 14
                              : 12,
                        ),
                      )),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: TextField(
                      controller: deskripsi,
                      readOnly: true,
                      minLines: 1,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: 'Deskripsi',
                      ),
                      style: TextStyle(
                        fontSize:
                            MediaQuery.of(context).size.width >= 720 ? 14 : 12,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    alignment: Alignment.topLeft,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Text("Bukti Kunjungan\n"),
                            // bukti == ""
                            //     ? GestureDetector(
                            //         onTap: () {},
                            //         child: SizedBox(
                            //             width: 60,
                            //             height: 60,
                            //             child:
                            //                 Image.memory(base64Decode(_foto_proses))),
                            //       )
                            //     :
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white),
                                onPressed: () =>
                                    _foto_proses == null || _foto_proses == ""
                                        ? captureImg(context)
                                        : showBukti(context, _foto_proses),
                                child: Padding(
                                    padding: EdgeInsets.all(10),
                                    child: SizedBox(
                                        width: 60,
                                        height: 60,
                                        child: Icon(
                                          _foto_proses == null ||
                                                  _foto_proses == ""
                                              ? AddImage.add_image
                                              : Icons.remove_red_eye,
                                          size: 40,
                                          color: Colors.grey,
                                        ))))
                          ],
                        ),
                        Padding(
                            padding: EdgeInsets.only(left: 20),
                            child: Column(
                              children: [
                                Text("Tambah Penjualan\n"),
                                id_nota == null
                                    ? ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white),
                                        onPressed: () {
                                          Navigator.popAndPushNamed(context,
                                              "/tambahlaporanpenjualan");
                                        },
                                        child: Padding(
                                            padding: EdgeInsets.all(10),
                                            child: SizedBox(
                                                width: 60,
                                                height: 60,
                                                child: Icon(
                                                  AddPenjualan.doc_add,
                                                  size: 40,
                                                  color: Colors.grey,
                                                ))))
                                    : TextButton(
                                        onPressed: () {},
                                        child:
                                            Text(kunjungan!.id_nota.toString()))
                              ],
                            )),
                      ],
                    ),
                  ),
                  if (widget.status == 0 && widget.username == username)
                    Container(
                      height: 50,
                      margin: const EdgeInsets.all(10),
                      child: ElevatedButton(
                        onPressed: () => submit(context),
                        child: const Center(
                          child: Text('Check out',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ),
                ],
              )),
        ));
  }
}
