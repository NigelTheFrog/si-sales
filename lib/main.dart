import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pt_coronet_crown/account/createacount.dart';
import 'package:pt_coronet_crown/account/login.dart';
import 'package:pt_coronet_crown/admin/personel/addpersonelgroup.dart';
import 'package:pt_coronet_crown/admin/personel/personeldata.dart';
import 'package:pt_coronet_crown/admin/personel/personelgroup.dart';
import 'package:pt_coronet_crown/drawer.dart';
import 'package:pt_coronet_crown/laporan/pembelian/daftarpembelian.dart';
import 'package:pt_coronet_crown/laporan/penjualan/buatlaporanjual.dart';
import 'package:pt_coronet_crown/laporan/penjualan/daftarpenjualan.dart';
import 'package:pt_coronet_crown/mainpage/home.dart';
import 'package:pt_coronet_crown/test.dart';
import 'package:shared_preferences/shared_preferences.dart';

String username = "", idjabatan = "", avatar = "";

Future<String> checkUser() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString("username") ?? '';
}

Future<String> getIdJabatan() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString("idJabatan") ?? '';
}

Future<String> getAvatar() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString("avatar") ?? '';
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  checkUser().then((String result) {
    if (result == '')
      runApp(MyLogin());
    else {
      username = result;
      runApp(const MyApp());
    }
  });

  getIdJabatan().then((String result) {
    idjabatan = result;
  });

  getAvatar().then((String result) {
    avatar = result;
  });
}

void doLogout() async {
  final prefs = await SharedPreferences.getInstance();
  prefs.remove("username");
  main();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Home'),
      debugShowCheckedModeBanner: false,
      routes: {
        "daftarpembelian": (context) => DaftarPembelian(),
        "daftarpenjualan": (context) => DaftarPenjualan(),
        "daftarpersonel": (context) => PersonelData(),
        "daftargrup": (context) => PersonelGroup(),
        "tambahstaff": (context) => CreateAccount(),
        "tambahgrup": (context) => CreateGroup(),
        "detailpembelian": (context) => PersonelGroup(),
        "detailpenjualan": (context) => PersonelGroup(),
        "tambahlaporanpenjualan": (context) => BuatPenjualan(),
        "test" :  (context) => genBill()
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  final List<Widget> _screens = [Home()];
  // final List<String> _title = ['Home', 'My Creation', 'List Sensor', 'Setting'];

  Widget myBottomNavBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _currentIndex,
      fixedColor: Colors.teal,
      items: <BottomNavigationBarItem>[
        const BottomNavigationBarItem(
          label: "Home",
          icon: Icon(Icons.home),
        ),
        const BottomNavigationBarItem(
          label: "History",
          icon: Icon(Icons.history),
        ),
        const BottomNavigationBarItem(
          label: "Account",
          icon: Icon(Icons.person),
        ),
      ],
      onTap: (int index) {
        setState(() {
          _currentIndex = index;
        });
      },
    );
  }

  void doLogout() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove("username");
    main();
  }

  @override
  Widget build(BuildContext context) {
    if (idjabatan == "1" || idjabatan == "2") {
      return Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[],
            ),
          ),
          drawer: MyDrawer());
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Image.asset('assets/crn.png', height: 50, fit: BoxFit.cover),
          actions: <Widget>[
            CircleAvatar(
              backgroundImage: Image.memory(base64Decode(avatar)).image,
              radius: 23,
            ),
          ],
        ),
        body: _screens[_currentIndex],
        bottomNavigationBar: myBottomNavBar(),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            doLogout();
          },
          backgroundColor: Colors.blue,
          label: Text("Logout", style: TextStyle(color: Colors.white)),
          icon: const Icon(Icons.logout),
        ),
      );
    }
  }
}
