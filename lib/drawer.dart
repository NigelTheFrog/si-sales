import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pt_coronet_crown/customicon/calendar_icons.dart';
import 'package:pt_coronet_crown/customicon/clip_board_check_icons.dart';
import 'package:pt_coronet_crown/customicon/clippy_icons.dart';
import 'package:pt_coronet_crown/customicon/event_chart_icons.dart';
import 'package:pt_coronet_crown/customicon/jabatan_icons.dart';
import 'package:pt_coronet_crown/customicon/outlet_icons.dart';
import 'package:pt_coronet_crown/customicon/produk_icons.dart';
import 'package:pt_coronet_crown/customicon/proposal_icons.dart';
import 'package:pt_coronet_crown/customicon/transaction_icons.dart';
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
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: <Widget>[
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
                      Navigator.popAndPushNamed(context, "/test");
                    },
                  ),
                  ListTile(
                    title: const Text("Personel Group"),
                    leading: const Icon(Icons.group),
                    onTap: () {
                      Navigator.popAndPushNamed(context, "/daftargrup");
                    },
                  ),
                  ListTile(
                    title: const Text("Daftar Kehadiran"),
                    leading: const Icon(
                      Icons.check_rounded,
                    ),
                    onTap: () {
                      Navigator.popAndPushNamed(context, "/daftargrup");
                    },
                  ),
                  ListTile(
                    title: const Text("Kunjungan"),
                    leading: const Icon(
                      Icons.location_on,
                    ),
                    onTap: () {
                      Navigator.popAndPushNamed(context, "/daftarkunjungan");
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
                title: const Text("Menunggu Persetujuan"),
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
                title: const Text("Transaksi"),
                leading: const Icon(Transaction.attach_money),
                children: <Widget>[
                  ListTile(
                    title: const Text("Pembelian"),
                    leading: const Icon(Clippy.clippy),
                    onTap: () {
                      Navigator.popAndPushNamed(context, "/daftarpembelian");
                    },
                  ),
                  ListTile(
                    title: const Text("Penjualan"),
                    leading: const Icon(ClipBoardCheck.clipboard_check),
                    onTap: () {
                      Navigator.popAndPushNamed(context, "/daftarpenjualan");
                    },
                  ),
                ],
              ),
              ExpansionTile(
                title: Text("Event"),
                leading: Icon(EventChart.chart_line),
                children: [
                  ListTile(
                    title: const Text("Proposal Event"),
                    leading: const Icon(Proposal.doc_text_inv),
                    onTap: () {
                      Navigator.popAndPushNamed(context, "/daftarproposal");
                    },
                  ),
                  ListTile(
                    title: const Text("Riwayat Event"),
                    leading: const Icon(Calendar.event),
                    onTap: () {
                      Navigator.popAndPushNamed(context, "/daftarevent");
                    },
                  ),
                ],
              ),
              ListTile(
                title: const Text("Outlet"),
                leading: const Icon(Outlet.industrial_building),
                onTap: () {
                  Navigator.popAndPushNamed(context, "/daftaroutlet");
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
                  ListTile(
                    title: const Text("Daftar Produk"),
                    leading: const Icon(Produk.box_open),
                    onTap: () {
                      Navigator.popAndPushNamed(context, "/daftarproduk");
                    },
                  ),
                  ListTile(
                    title: const Text("Daftar Jabatan"),
                    leading: const Icon(Jabatan.group),
                    onTap: () {
                      Navigator.popAndPushNamed(context, "/daftarjabatan");
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
        ));
  }
}
