import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
// import 'dart:developer';

import 'package:flutter/material.dart';
// import 'dart:io' show Platform;
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:pt_coronet_crown/account/createacount.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image/image.dart' as img;

import '../main.dart';

class MyLogin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PT Coronet Crown',
      theme: ThemeData(
        primaryColor: Colors.orange,
      ),
      home: Login(),
    );
  }
}

class Login extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginState();
  }
}

class _LoginState extends State<Login> {
  String _username = "";
  String _password = "";
  String error_login = "";
  String picture = "null";
  bool isLoading = false;
  var _avatar, _avatar_proses;
  final picker = ImagePicker();

//   DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
//if (Platform.isAndroid) {
//   AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
// } else if (Platform.isIOS) {
//   // iOS-specific code
// }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _username = "";
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
        updateAccount();
      });
    });
  }

  Future captureImg() async {
    var picked_img =
        await picker.pickImage(source: ImageSource.camera, imageQuality: 20);
    _avatar = File(picked_img!.path);
    prosesFoto();
  }

  void updateAccount() async {
    final response = await http
        .post(Uri.parse("https://otccoronet.com/otc/account/login.php"), body: {
      'username': _username,
      'avatar': base64Encode(_avatar_proses),
      'type': "1"
    });
    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      if (json['result'] == 'success') {
        prefs.setString("avatar", base64Encode(_avatar_proses));
        main();
      } else {
        prefs.clear();
        emptyAvatarDialog(
            "Terjadi kegagalan dalam pengunggahan gambar wajah. Harap ambil gambar ulang");
      }
    }
  }

  void emptyAvatarDialog(content) {
    showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Text('Peringatan'),
              content: Text(content),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    captureImg();
                  },
                  child: const Text('OK'),
                ),
              ],
            ));
  }

  void doLogin() async {
    final response = await http.post(
        Uri.parse("https://otccoronet.com/otc/account/login.php"),
        body: {'username': _username, 'password': _password, 'type': "0"});
    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      if (json['result'] == 'success') {
        print(json);
        if (json["avatar"] == null || json["avatar"] == "") {
          prefs.setString("username", json['username']);
          prefs.setString("nama_depan", json["nama_depan"]);
          prefs.setString("nama_belakang", json["nama_belakang"]);
          prefs.setString("emrail", json["email"]);
          prefs.setString("tanggal_gabung", json["tanggal_gabung"]);
          prefs.setString("idJabatan", json["id_jabatan"].toString());
          prefs.setString("jabatan", json["jabatan"]);
          prefs.setString("idCabang", json["id_cabang"]);
          prefs.setString("cabang", json["cabang"]);
          prefs.setString("idGrup", json["id_grup"]);
          prefs.setString("grup", json["grup"]);
          prefs.setString("tanggalAbsen", json["tanggal_absen"]);
          prefs.setString("telepon", json["no_telp"]);
          emptyAvatarDialog(
              "Dikarenakan anda pertama kali melakukan login, maka harap lakukan pengambilan gambar wajah terlebih dahulu");
        } else {
          prefs.setString("username", json['username']);
          prefs.setString("nama_depan", json["nama_depan"]);
          prefs.setString("nama_belakang", json["nama_belakang"]);
          prefs.setString("email", json["email"]);
          prefs.setString("tanggal_gabung", json["tanggal_gabung"]);
          prefs.setString("idJabatan", json["id_jabatan"].toString());
          prefs.setString("jabatan", json["jabatan"]);
          prefs.setString("idCabang", json["id_cabang"]);
          prefs.setString("cabang", json["cabang"]);
          prefs.setString("idGrup", json["id_grup"]);
          prefs.setString("grup", json["grup"]);
          prefs.setString("tanggalAbsen", json["tanggal_absen"]);
          prefs.setString("avatar", json["avatar"]);
          prefs.setString("telepon", json["no_telp"]);
          main();
        }
      } else {
        if (json['message'] == "1") {
          setState(() {
            isLoading = false;
            error_login = "Akun anda telah diblok, silahkan kontak admin";
          });
        } else {
          setState(() {
            isLoading = false;
            error_login = "Password anda salah";
          });
        }
      }
    } else {
      isLoading = false;
      throw Exception('Failed to read API');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.orange,
          title: const Text(
            'Login',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            child: Align(
                alignment: Alignment.center,
                child: SingleChildScrollView(
                    child: Container(
                        width: 300,
                        child: Column(children: [
                          Padding(
                              padding: EdgeInsets.all(10),
                              child: Container(
                                  height: 100,
                                  width: 300,
                                  child:
                                      Image.asset("assets/coronet_crown.png"))),
                          Padding(
                            padding: EdgeInsets.all(10),
                            child: TextField(
                              onChanged: (value) {
                                _username = value;
                              },
                              decoration: const InputDecoration(
                                  labelText: 'Username',
                                  hintText:
                                      'Masukkan username yang telah didaftarkan'),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(10),
                            //padding: EdgeInsets.symmetric(horizontal: 15),
                            child: TextField(
                              onChanged: (value) {
                                _password = value;
                              },
                              obscureText: true,
                              decoration: InputDecoration(
                                  labelText: 'Password',
                                  hintText: 'Masukkan password'),
                            ),
                          ),
                          if (error_login != "")
                            Text(error_login,
                                style: TextStyle(color: Colors.red)),
                          Padding(
                              padding: const EdgeInsets.all(10),
                              child: Container(
                                height: 50,
                                width: 300,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20)),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange),
                                  onPressed: () {
                                    setState(() {
                                      isLoading = true;
                                      doLogin();
                                    });
                                  },
                                  child: isLoading == true
                                      ? CircularProgressIndicator(
                                          color: Colors.white,
                                        )
                                      : const Text(
                                          'Sign In',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16),
                                        ),
                                ),
                              )),
                        ]))))));
  }
}
