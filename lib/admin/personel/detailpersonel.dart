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
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:pt_coronet_crown/class/personel/personel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailPersonel extends StatefulWidget {
  String username;

  DetailPersonel({
    super.key,
    required this.username,
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

  Person? personalia;
  String cabang = "",
      usernameController = "",
      id_jabatan = "",
      _idcabang = "",
      _idgrup = "",
      jabatanPersonalia = "";
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
            'id_jabatan': id_jabatan,
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

  Future<String> fetchData() async {
    final response = await http.post(
        Uri.parse(
            "https://otccoronet.com/otc/account/kunjungan/detailkunjungan.php"),
        body: {'id': widget.username});
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to read API');
    }
  }

  bacadata() {
    fetchData().then((value) {
      Map json = jsonDecode(value);
      personalia = Person.fromJson(json['data']);
      setState(() {
        usernameController = widget.username;
        namaDepanController.text = personalia!.nama_depan;
        namaBelakangController.text = personalia!.nama_belakang;
        emailController.text = personalia!.email;
        nomorTeleponController.text = personalia!.no_telp;
        namaCabangController.text = personalia!.nama_cabang;
        namaJabatanController.text = personalia!.jabatan;
        namaGrupController.text = personalia!.nama_grup;
        _idcabang = personalia!.id_cabang;
        jabatanPersonalia = personalia!.id_jabatan.toString();
        _idgrup = personalia!.id_grup;
        _avatar = personalia!.avatar;
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadData();
    bacadata();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Widget generateCombo(change) {
    return DropdownSearch<dynamic>(
      dropdownSearchDecoration: InputDecoration(
        hintText: change == 4
            ? namaCabangController.text
            : change == 5
                ? namaJabatanController.text
                : namaGrupController.text,
        hintStyle: TextStyle(color: Colors.black),
        labelText: change == 4
            ? "Daftar Cabang"
            : change == 5
                ? "Daftar Jabatan"
                : "Daftar Grup",
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
          var response = await http.post(
              Uri.parse(
                  "http://192.168.137.1/magang/admin/personel/personeldata/personelgrup.php"),
              body: {'id_cabang': _idcabang});

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
          id_jabatan = value['id'];
          namaJabatanController.text = value['jabatan'];
        } else {
          _idgrup = value['id'];
          namaGrupController.text = value['nama_grup'];
        }
      },
      itemAsString: change == 4
          ? (item) => item['nama_cabang']
          : change == 5
              ? (item) => item['jabatan']
              : (item) => item['nama_grup'],
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
                          : change == 5
                              ? Text("Edit Jabatan")
                              : Text("Edit Grup "),
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
                  : change == 4 || change == 5 || change == 6
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
                print(id_jabatan);

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
                  child: Image.memory(base64Decode(_avatar)),
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
        Padding(
            padding: EdgeInsets.all(10),
            child: id_jabatan == "1" || id_jabatan == "2"
                ? Row(
                    children: [
                      SizedBox(
                          width: 440,
                          child: TextField(
                            controller: namaGrupController,
                            decoration: const InputDecoration(
                              labelText: 'Grup',
                            ),
                            enabled: false,
                          )),
                      Tooltip(
                        child: IconButton(
                            onPressed: () {
                              editDialog(6);
                            },
                            icon: Icon(Icons.edit)),
                        message: "Ubah Grup",
                      )
                    ],
                  )
                : Text("Grup: ${namaGrupController.text}")),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (id_jabatan == "1" || id_jabatan == "2") {
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
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
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
    } else {
      return Scaffold(
        body: SingleChildScrollView(
            child: Container(
                padding: EdgeInsets.only(top: 50),
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width,
                child: MediaQuery.of(context).size.width >= 720
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[showPicture(), buildData()],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[showPicture(), buildData()]))),
      );
    }
  }
}
