import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pt_coronet_crown/customicon/clip_board_check_icons.dart';
import 'package:pt_coronet_crown/customicon/clippy_icons.dart';
import 'package:pt_coronet_crown/customicon/event_chart_icons.dart';
import 'package:pt_coronet_crown/laporan/pembelian/daftarpembelian.dart';
import 'package:pt_coronet_crown/laporan/penjualan/daftarpenjualan.dart';
import 'package:shared_preferences/shared_preferences.dart';

String nama_depan = "", nama_belakang = "", username = "", id_jabatan = "";

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString("username") ?? '';
      id_jabatan = prefs.getString("idJabatan") ?? '';
      nama_depan = prefs.getString("nama_depan") ?? '';
      nama_belakang = prefs.getString("nama_belakang") ?? '';
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: SingleChildScrollView(
              child: Column(children: <Widget>[
        Text(
          "\nSelamat datang $nama_depan $nama_belakang \n",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Container(
            height: MediaQuery.of(context).size.height,
            width: 700,
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 4.0,
              childAspectRatio: 2 / 1.5,
              children: [
                GestureDetector(
                    onTap: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => DetailSensor(
                      //       sensor_id: sensor2[index].sensor_id,
                      //     ),
                      //   ),
                      // );
                    },
                    child: Card(
                        child: Container(
                            width: double.infinity,
                            height: double.infinity,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check_rounded,
                                  size: 60,
                                ),
                                Text(
                                  "Absen hadir",
                                  style: TextStyle(fontSize: 16),
                                )
                              ],
                            )))),
                GestureDetector(
                    onTap: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => DetailSensor(
                      //       sensor_id: sensor2[index].sensor_id,
                      //     ),
                      //   ),
                      // );
                    },
                    child: Card(
                        child: Container(
                            width: double.infinity,
                            height: double.infinity,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.exit_to_app,
                                  size: 60,
                                ),
                                Text(
                                  "Absen pulang",
                                  style: TextStyle(fontSize: 16),
                                )
                              ],
                            )))),
                GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DaftarPembelian(),
                        ),
                      );
                    },
                    child: Card(
                        child: Container(
                            width: double.infinity,
                            height: double.infinity,
                            child: id_jabatan == "3"
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        size: 60,
                                      ),
                                      Text(
                                        "Kunjungan Masuk",
                                        style: TextStyle(fontSize: 16),
                                      )
                                    ],
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Clippy.clippy,
                                        size: 60,
                                      ),
                                      Text(
                                        "\nLaporan pembelian",
                                        style: TextStyle(fontSize: 16),
                                      )
                                    ],
                                  )))),
                GestureDetector(
                    onTap: () {
                      if (id_jabatan == "3") {
                      } else {}
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DaftarPenjualan()
                        ),
                      );
                    },
                    child: Card(
                        child: Container(
                            width: double.infinity,
                            height: double.infinity,
                            child: id_jabatan == "3"
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.location_off,
                                        size: 60,
                                      ),
                                      Text(
                                        "Kunjungan keluar",
                                        style: TextStyle(fontSize: 16),
                                      )
                                    ],
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        ClipBoardCheck.clipboard_check,
                                        size: 60,
                                      ),
                                      Text(
                                        "\nLaporan Penjualan",
                                        style: TextStyle(fontSize: 16),
                                      )
                                    ],
                                  )))),
                GestureDetector(
                    onTap: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => DetailSensor(
                      //       sensor_id: sensor2[index].sensor_id,
                      //     ),
                      //   ),
                      // );
                    },
                    child: Card(
                        child: Container(
                            width: double.infinity,
                            height: double.infinity,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  EventChart.chart_line,
                                  size: 60,
                                ),
                                Text(
                                  "\nLaporan Event",
                                  style: TextStyle(fontSize: 16),
                                )
                              ],
                            )))),
              ],
            ))
      ]))),
    );
  }
}
