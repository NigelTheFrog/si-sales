import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dropdown_search/dropdown_search.dart';
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
import 'package:pt_coronet_crown/drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailPersonel extends StatefulWidget {
  String username,
      avatar,
      namaDepan,
      namaBelakang,
      email,
      nomorTelepon,
      namaCabang,
      namaJabatan,
      namaGrup,
      idcabang,
      idjabatan,
      idgrup;
  DetailPersonel({
    super.key,
    required this.username,
    required this.avatar,
    required this.namaDepan,
    required this.namaBelakang,
    required this.email,
    required this.nomorTelepon,
    required this.namaCabang,
    required this.namaJabatan,
    required this.namaGrup,
    required this.idcabang,
    required this.idjabatan,
    required this.idgrup,
  });
  @override
  _DetailPersonelState createState() {
    return _DetailPersonelState();
  }
}

class _DetailPersonelState extends State<DetailPersonel> {
  TextEditingController emailController = TextEditingController();
  TextEditingController nomorTeleponController = TextEditingController();
  TextEditingController namaCabangController = TextEditingController();
  TextEditingController namaJabatanController = TextEditingController();
  TextEditingController namaDepanController = TextEditingController();
  TextEditingController namaBelakangController = TextEditingController();
  TextEditingController namaGrupController = TextEditingController();

  late Timer timer;
  String cabang = "",
      usernameController = "",
      _idjabatan = "",
      _idcabang = "",
      _idgrup = "";
  var _avatar = null;
  var _avatar_proses = null;

  List _jabatan = [], _cabang = [], _grup = [];

  final picker = ImagePicker();

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

  void update(BuildContext context, change) async {
    var response;
    if (change == 1) {
      response = await http.post(
          Uri.parse(
              "http://192.168.137.1/magang/admin/personel/personeldata/ubahpersonel.php"),
          body: {
            'username': widget.username,
            'nama_depan': namaDepanController.text,
            'nama_belakang': namaBelakangController.text
          });
    } else if (change == 2) {
      response = await http.post(
          Uri.parse(
              "http://192.168.137.1/magang/admin/personel/personeldata/ubahpersonel.php"),
          body: {
            'username': widget.username,
            'email': emailController.text,
          });
    } else if (change == 3) {
      response = await http.post(
          Uri.parse(
              "http://192.168.137.1/magang/admin/personel/personeldata/ubahpersonel.php"),
          body: {
            'username': widget.username,
            'email': nomorTeleponController.text,
          });
    } else if (change == 4) {
      response = await http.post(
          Uri.parse(
              "http://192.168.137.1/magang/admin/personel/personeldata/ubahpersonel.php"),
          body: {
            'username': widget.username,
            'id_cabang': _idcabang,
          });
    } else if (change == 2) {
      response = await http.post(
          Uri.parse(
              "http://192.168.137.1/magang/admin/personel/personeldata/ubahpersonel.php"),
          body: {
            'username': widget.username,
            'id_jabatan': _idjabatan,
          });
    }

    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      if (json['result'] == 'success') {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Sukses Mengubah Data')));
      }
    } else {
      throw Exception('Failed to read API');
    }
  }

  _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      id_jabatan = prefs.getString("idJabatan") ?? '';
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadData();
    usernameController = widget.username;
    namaDepanController.text = widget.namaDepan;
    namaBelakangController.text = widget.namaBelakang;
    emailController.text = widget.email;
    nomorTeleponController.text = widget.nomorTelepon;
    namaCabangController.text = widget.namaCabang;
    namaJabatanController.text = widget.namaJabatan;
    namaGrupController.text = widget.namaGrup;
    _idcabang = widget.idcabang;
    _idjabatan = widget.idjabatan;
    _idgrup = widget.idgrup;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    timer.cancel();
    super.dispose();
  }

  Widget generateCombo(change) {
    return DropdownSearch<dynamic>(
      dropdownSearchDecoration: InputDecoration(
        hintText: change == 4
            ? namaCabangController.text
            : namaJabatanController.text,
        hintStyle: TextStyle(color: Colors.black),
        labelText: change == 4 ? "Daftar Cabang" : "Daftar Jabatan",
      ),
      mode: Mode.MENU,
      showSearchBox: false,
      onFind: (text) async {
        Map json;
        if (change == 4) {
          var response = await http.post(Uri.parse(
              "http://192.168.137.1/magang/admin/cabang/daftarcabang.php"));

          if (response.statusCode == 200) {
            json = jsonDecode(response.body);
            setState(() {
              _cabang = json['data'];
            });
          }
          return _cabang as List<dynamic>;
        } else if (change == 5) {
          var response = await http.post(Uri.parse(
              "http://192.168.137.1/magang/admin/jabatan/daftarjabatan.php"));

          if (response.statusCode == 200) {
            json = jsonDecode(response.body);
            setState(() {
              _jabatan = json['data'];
            });
          }
          return _jabatan as List<dynamic>;
        } else {
          var response = await http.post(Uri.parse(
              "http://192.168.137.1/magang/admin/jabatan/daftarjabatan.php"));

          if (response.statusCode == 200) {
            json = jsonDecode(response.body);
            setState(() {
              _grup = json['data'];
            });
          }
          return _grup as List<dynamic>;
        }
      },
      onChanged: (value) {
        if (change == 4) {
          _idcabang = value['id'];
          namaCabangController.text = value['nama_cabang'];
        } else if (change == 5) {
          _idjabatan = value['id'];
          namaJabatanController.text = value['jabatan'];
        } else {
          _idgrup = value['id'];
          namaGrupController.text = value['jabatan'];
        }
      },
      itemAsString: change == 4
          ? (item) => item['nama_cabang']
          : (item) => item['jabatan'],
    );
  }

  void prosesFoto() {
    Future<Directory?> extDir = getTemporaryDirectory();
    extDir.then((value) {
      String _timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String filePath = '${value?.path}/$_timestamp.jpg';
      _avatar_proses = File(filePath);
      img.Image? temp = img.readJpg(_avatar!.readAsBytesSync());
      img.Image temp2 = img.copyResize(temp!, width: 480, height: 640);
      setState(() {
        _avatar_proses = Uint8List.fromList(img.encodeJpg(temp2));
      });
    });
  }

  Future chooseImg() async {
    FilePickerResult fileResult =
        await FilePicker.platform.pickFiles() as FilePickerResult;
    if (fileResult != null) {
      setState(() {
        _avatar = fileResult.files.first.bytes;
        img.Image? temp = img.decodeImage(_avatar!);
        img.Image temp2 = img.copyResize(temp!, width: 480, height: 640);
        _avatar_proses = Uint8List.fromList(img.encodeJpg(temp2));
      });
    }
  }

  Future captureImg() async {
    var picked_img =
        await picker.pickImage(source: ImageSource.camera, imageQuality: 20);
    // setState(() {
    _avatar = File(picked_img!.path);
    prosesFoto();

    //});
  }

  void editDialog(int change) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: change == 1
              ? Text("Edit Nama")
              : change == 2
                  ? Text("Edit Email")
                  : change == 3
                      ? Text("Edit Nomor Telepon")
                      : change == 4
                          ? Text("Edit Cabang")
                          : Text("Edit Jabatan"),
          content: Container(
              height: 110,
              width: 300,
              child: change == 1
                  ? Column(
                      children: [
                        TextFormField(
                          controller: namaDepanController,
                          decoration: InputDecoration(
                              label: Text("Nama Depan"),
                              hintText: "Isikan nama depan personil"),
                        ),
                        TextField(
                          controller: namaBelakangController,
                          onChanged: (value) {},
                          decoration: InputDecoration(
                              label: Text("Nama Belakang"),
                              hintText: "Isikan nama belakang personil"),
                        ),
                      ],
                    )
                  : change == 4 || change == 5
                      ? generateCombo(change)
                      : TextField(
                          controller: change == 2
                              ? emailController
                              : nomorTeleponController,
                          onChanged: (value) {},
                          decoration: InputDecoration(
                              hintText: change == 2
                                  ? "Isikan email personil"
                                  : "Isikan nomor telepon personil"),
                        )),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text("Iya"),
              onPressed: () {
                setState(() {});
                update(context, change);
                print(namaDepanController.text);
                print(emailController.text);
                print(nomorTeleponController.text);
                print(_idcabang);
                print(_idjabatan);

                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  Widget showPicture() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
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
                  height: 200,
                  width: 150,
                  child: Image.memory(base64Decode(widget.avatar)),
                  // : Image.file(_avatar_proses!),
                ))),
        Text(
          usernameController,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            Text("${namaDepanController.text} ${namaBelakangController.text}"),
            Tooltip(
              child: IconButton(
                  onPressed: () {
                    editDialog(1);
                  },
                  icon: Icon(Icons.edit)),
              message: "Ubah Nama",
            )
          ],
        )
      ],
    );
  }

  Widget buildData() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                SizedBox(
                    width: 440,
                    child: TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'E-mail',
                      ),
                      enabled: false,
                    )),
                Tooltip(
                  child: IconButton(
                      onPressed: () {
                        editDialog(2);
                      },
                      icon: Icon(Icons.edit)),
                  message: "Ubah Email",
                )
              ],
            )),
        Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                SizedBox(
                    width: 440,
                    child: TextField(
                      controller: nomorTeleponController,
                      decoration: const InputDecoration(
                        labelText: 'Nomor Telepon',
                      ),
                      enabled: false,
                    )),
                Tooltip(
                  child: IconButton(
                      onPressed: () {
                        editDialog(3);
                      },
                      icon: Icon(Icons.edit)),
                  message: "Ubah Nomor Telepon",
                )
              ],
            )),
        Padding(
            padding: EdgeInsets.all(10),
            child: id_jabatan == "1" || id_jabatan == "2"
                ? Row(
                    children: [
                      SizedBox(
                          width: 440,
                          child: TextField(
                            controller: namaCabangController,
                            decoration: const InputDecoration(
                              labelText: 'Cabang',
                            ),
                            onChanged: (value) {
                              nama_belakang = value;
                            },
                            enabled: false,
                          )),
                      Tooltip(
                        child: IconButton(
                            onPressed: () {
                              editDialog(4);
                            },
                            icon: Icon(Icons.edit)),
                        message: "Ubah Cabang",
                      )
                    ],
                  )
                : Text("Cabang: ${namaCabangController.text}")),
        Padding(
            padding: EdgeInsets.all(10),
            child: id_jabatan == "1" || id_jabatan == "2"
                ? Row(
                    children: [
                      SizedBox(
                          width: 440,
                          child: TextField(
                            controller: namaJabatanController,
                            decoration: const InputDecoration(
                              labelText: 'Jabatan',
                            ),
                            onChanged: (value) {
                              nama_belakang = value;
                            },
                            enabled: false,
                          )),
                      Tooltip(
                        child: IconButton(
                            onPressed: () {
                              editDialog(5);
                            },
                            icon: Icon(Icons.edit)),
                        message: "Ubah Jabatan",
                      )
                    ],
                  )
                : Text("Jabatan: ${namaJabatanController.text}")),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Detail Personil"),
        ),
        body: SingleChildScrollView(
          child: Container(
              padding: EdgeInsets.only(top: 30),
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                      "DATA PERSONEL ${namaDepanController.text} ${namaBelakangController.text}"
                          .toUpperCase(),
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Container(
                      padding: EdgeInsets.only(top: 20),
                      child: MediaQuery.of(context).size.width >= 720
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[showPicture(), buildData()],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[showPicture(), buildData()]))
                ],
              )),
        ));
  }
}
