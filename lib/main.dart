import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pt_coronet_crown/account/login.dart';
import 'package:pt_coronet_crown/admin/personel/personeldata.dart';
import 'package:shared_preferences/shared_preferences.dart';

String active_user = "",
    username = "",
    nama_depan = "",
    nama_belakang = "",
    email = "",
    jabatan = "",
    tanggal_gabung = "";
var avatar;

Future<String> checkUser() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString("username") ?? '';
}

Future<String> getNamaDepan() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString("nama_depan") ?? '';
}

Future<String> getNamaBelakang() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString("nama_belakang") ?? '';
}

Future<String> getEmail() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString("email") ?? '';
}

Future<String> getAvatar() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString("avatar") ?? '';
}

Future<String> getTanggalGabung() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString("tanggal_gabung") ?? '';
}

Future<String> getJabatan() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString("jabatan") ?? '';
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
  getNamaDepan().then((String result) {
    nama_depan = result;
  });
  getNamaBelakang().then((String result) {
    nama_belakang = result;
  });
  getEmail().then((String result) {
    email = result;
  });
  getJabatan().then((String result) {
    jabatan = result;
  });
  getTanggalGabung().then((String result) {
    tanggal_gabung = result;
  });
  getAvatar().then((var result) {
    avatar = base64Decode(result);
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
      routes: {
        "personeldata": (context) => PersonelData(),
        // "mycreation": (context) => MyCreation(),
        // "setting": (context) => Setting(),
        // "leaderboard": (context) => LeaderBoard()
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

  Widget myDrawer() {
    return Drawer(
        elevation: 16.0,
        child: Column(children: <Widget>[
          SingleChildScrollView(
            child: Column(
              children: [
                UserAccountsDrawerHeader(
                  accountEmail: Text('Email: $email \nUsername: $username'),
                  accountName: Text('$nama_depan $nama_belakang'),
                  currentAccountPicture:
                      CircleAvatar(backgroundImage: Image.memory(avatar).image, ),
                ),
                ExpansionTile(
                  title: const Text("Personnel"),
                  leading: const Icon(Icons.person),
                  children: <Widget>[
                    ListTile(
                      title: const Text("Personel Data"),
                      leading: const Icon(Icons.account_box),
                      onTap: () {
                        Navigator.popAndPushNamed(context, "personeldata");
                      },
                    ),
                    ListTile(
                      title: const Text("Personel Group"),
                      leading: const Icon(Icons.group),
                      onTap: () {
                        Navigator.popAndPushNamed(context, "home");
                      },
                    ),
                  ],
                ),
                ListTile(
                  title: const Text("Daily Attendence"),
                  leading: const Icon(Icons.watch_later_outlined),
                  onTap: () {
                    Navigator.popAndPushNamed(context, "mycreation");
                  },
                ),
                ListTile(
                  title: const Text("Waiting for Approval"),
                  leading: const Icon(Icons.pending_actions),
                  onTap: () {
                    Navigator.popAndPushNamed(context, "leaderboard");
                  },
                ),
                ListTile(
                  title: const Text("Client Visit"),
                  leading: const Icon(Icons.directions_walk),
                  onTap: () {
                    Navigator.popAndPushNamed(context, "setting");
                  },
                ),
                ExpansionTile(
                  title: const Text("Company"),
                  leading: const Icon(Icons.business_center),
                  children: <Widget>[
                    ListTile(
                      title: const Text("Profile"),
                      leading: const Icon(Icons.business),
                      onTap: () {
                        Navigator.popAndPushNamed(context, "home");
                      },
                    ),
                    ListTile(
                      title: const Text("Admin"),
                      leading: const Icon(Icons.admin_panel_settings),
                      onTap: () {
                        Navigator.popAndPushNamed(context, "home");
                      },
                    ),
                  ],
                ),
                ListTile(
                  tileColor: Colors.blue,
                  title: const Text(
                    "Logout",
                    style: TextStyle(color: Colors.white),
                  ),
                  leading: const Icon(
                    Icons.logout,
                    color: Colors.white,
                  ),
                  onTap: () {
                    doLogout();
                  },
                )
              ],
            ),
          )
        ]));
  }

  Widget myBottomNavBar() {
    var bottomNav = null;
    if (jabatan == "admin" || jabatan == "IT Staff") {
      bottomNav = BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        fixedColor: Colors.teal,
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            label: "Home",
            icon: Icon(Icons.home),
          ),
          const BottomNavigationBarItem(
            label: "My Creation",
            icon: Icon(Icons.create),
          ),
          const BottomNavigationBarItem(
            label: "Leaderboard",
            icon: Icon(Icons.person),
          ),
          const BottomNavigationBarItem(
            label: "Company",
            icon: Icon(Icons.settings),
          ),
        ],
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
      );
    }
    return bottomNav;
  }

  @override
  Widget build(BuildContext context) {
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
      drawer: myDrawer(),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _incrementCounter,
      //   tooltip: 'Increment',
      //   child: const Icon(Icons.add),
      // ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
