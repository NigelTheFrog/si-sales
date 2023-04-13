import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;
import 'package:pt_coronet_crown/account/createacount.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';

class MyLogin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
          primaryColor: Colors.blue,
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

  void doLogin() async {
    final response = await http.post(
        Uri.parse("http://192.168.137.1/magang/account/login.php"),
        body: {'username': _username, 'password': _password});
    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      if (json['result'] == 'success') {
        if (json["avatar"] == null || json["avatar"] == "") {}
        final prefs = await SharedPreferences.getInstance();
        prefs.setString("username", json['username']);
        prefs.setString("nama_depan", json["nama_depan"]);
        prefs.setString("nama_belakang", json["nama_belakang"]);
        prefs.setString("email", json["email"]);
        prefs.setString("tanggal_gabung", json["tanggal_gabung"]);
        prefs.setString("avatar", json["avatar"]);
        prefs.setString("idJabatan", json["id_jabatan"].toString());
        prefs.setString("jabatan", json["jabatan"]);
        prefs.setString("idCabang", json["id_cabang"]);
        prefs.setString("cabang", json["cabang"]);
        prefs.setString("idGrup", json["id_grup"]);
        main();
      } else {
        if (json['message'] == "1") {
          setState(() {
            error_login = "Akun anda telah diblok, silahkan kontak admin";
          });
        } else {
          setState(() {
            error_login = "Password anda salah";
          });
        }
      }
    } else {
      throw Exception('Failed to read API');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Login'),
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
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(20)),
                                child: ElevatedButton(
                                  onPressed: () {
                                    doLogin();
                                  },
                                  child: const Text(
                                    'Sign In',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ),
                                ),
                              )),
                        ]))))));
  }
}
