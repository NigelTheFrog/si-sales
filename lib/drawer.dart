import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pt_coronet_crown/admin/personel/personeldata.dart';
import 'package:pt_coronet_crown/admin/personel/personelgroup.dart';
import 'package:pt_coronet_crown/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

String nama_depan = "", nama_belakang = "", email = "", jabatan = "";
var avatar;

class MyDrawer extends StatefulWidget {
  @override
  _MyDrawerState createState() {
    return _MyDrawerState();
  }
}

class _MyDrawerState extends State<MyDrawer> {
  _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (nama_depan != prefs.getString("nama_depan") ||
        nama_belakang != prefs.getString("nama_belakang") ||
        email != prefs.getString("email") ||
        avatar != prefs.getString("avatar") ||
        jabatan != prefs.getString("jabatan")) {
      setState(() {
        nama_depan = prefs.getString("nama_depan") ?? '';
        nama_belakang = prefs.getString("nama_belakang") ?? '';
        email = prefs.getString("email") ?? '';
        avatar = prefs.getString("avatar") ?? '';
        jabatan = prefs.getString("jabatan") ?? '';
      });
    } else {
      return null;
    }
  }

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    _loadData();
  }

  void doLogout() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove("username");
    main();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
        elevation: 16.0,
        child: Column(children: <Widget>[
          SingleChildScrollView(
            child: Column(
              children: [
                UserAccountsDrawerHeader(
                  accountEmail: Text('Email: $email \nRole: $jabatan'),
                  accountName: Text('$nama_depan $nama_belakang'),
                  currentAccountPicture: CircleAvatar(
                    backgroundImage: Image.memory(base64Decode(avatar)).image,
                  ),
                ),
                ExpansionTile(
                  title: const Text("Personnel"),
                  leading: const Icon(Icons.person),
                  children: <Widget>[
                    ListTile(
                      title: const Text("Personel Data"),
                      leading: const Icon(Icons.account_box),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PersonelData()));
                      },
                    ),
                    ListTile(
                      title: const Text("Personel Group"),
                      leading: const Icon(Icons.group),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PersonelGroup()));
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
}