import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pt_coronet_crown/class/transaksi/pembelian.dart';
import 'package:pt_coronet_crown/class/transaksi/penjualan.dart';
import 'package:pt_coronet_crown/customicon/clip_board_check_icons.dart';
import 'package:pt_coronet_crown/customicon/clippy_icons.dart';
import 'package:pt_coronet_crown/customicon/event_chart_icons.dart';
import 'package:pt_coronet_crown/laporan/pembelian/detailpembelian.dart';
import 'package:pt_coronet_crown/laporan/penjualan/detailpenjualan.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

String username = "", id_jabatan = "";

class History extends StatefulWidget {
  History({super.key});
  @override
  State<StatefulWidget> createState() {
    return _HistoryState();
  }
}

class _HistoryState extends State<History> {
  Future<String> fetchDataHistoryPenjualan() async {
    final response = await http.post(
        Uri.parse(
            "http://192.168.137.1/magang/laporan/penjualan/daftarpenjualan.php"),
        body: {'username': username, 'idjabatan': '3', 'limit': '100'});
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to read API');
    }
  }

  Future<String> fetchDataHistoryPembelian() async {
    final response = await http.post(
        Uri.parse(
            "http://192.168.137.1/magang/laporan/pembelian/daftarpembelian.php"),
        body: {'username': username, 'type': '2', 'limit': '100'});
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to read API');
    }
  }

  _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString("username") ?? '';
      id_jabatan = prefs.getString("idJabatan") ?? '';
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadData();
  }

  Widget daftarHistoryPenjualan(data) {
    List<Penjualan> penjualan2 = [];
    Map json = jsonDecode(data);
    if (json['result'] == "error") {
      return Align(
        alignment: Alignment.center,
        child: Text("Tidak ada data tersedia"),
      );
    } else {
      for (var mov in json['data']) {
        Penjualan penjualan = Penjualan.fromJson(mov);
        penjualan2.add(penjualan);
      }
      return ListView.builder(
          itemCount: penjualan2.length,
          itemBuilder: (BuildContext ctxt, int index) {
            return SingleChildScrollView(
                child: Container(
                    padding: EdgeInsets.only(top: 5),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => DetailPenjualan(
                                            laporan_id: penjualan2[index].id,
                                          )));
                            },
                            child: Card(
                                elevation: 2,
                                child: SizedBox(
                                    width: 800,
                                    child: ListTile(
                                        title: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "Nama toko: ${penjualan2[index].nama_toko}",
                                                style: TextStyle(fontSize: 11),
                                              ),
                                              Text(
                                                  "Tanggal: ${penjualan2[index].tanggal}",
                                                  style:
                                                      TextStyle(fontSize: 11)),
                                            ]),
                                        subtitle: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                                "Jumlah penjualan: ${penjualan2[index].jumlah_barang}",
                                                style: TextStyle(fontSize: 11)),
                                            Text(
                                                "Total Penjualan: Rp. ${NumberFormat('###,000').format((penjualan2[index].total_penjualan - penjualan2[index].diskon) + (((penjualan2[index].total_penjualan - penjualan2[index].diskon) * (penjualan2[index].ppn / 100.00))))}",
                                                style: TextStyle(
                                                  fontSize: 11,
                                                ))
                                          ],
                                        )))))
                      ],
                    )));
          });
    }
  }

  Widget daftarHistoryPembelian(data) {
    List<Pembelian> pembelian2 = [];
    Map json = jsonDecode(data);
    if (json['result'] == "error") {
      return Align(
        alignment: Alignment.center,
        child: Text("Tidak ada data tersedia"),
      );
    } else {
      for (var mov in json['data']) {
        Pembelian pembelian = Pembelian.fromJson(mov);
        pembelian2.add(pembelian);
      }
      return ListView.builder(
          itemCount: pembelian2.length,
          itemBuilder: (BuildContext ctxt, int index) {
            return SingleChildScrollView(
                child: Container(
                    padding: EdgeInsets.only(top: 5),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => DetailPembelian(
                                            laporan_id: pembelian2[index].id,
                                          )));
                            },
                            child: Card(
                                elevation: 2,
                                child: SizedBox(
                                    width: 800,
                                    child: ListTile(
                                        title: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "Nama Supplier: ${pembelian2[index].nama_supplier}",
                                                style: TextStyle(fontSize: 11),
                                              ),
                                              Text(
                                                  "Tanggal: ${pembelian2[index].tanggal}",
                                                  style:
                                                      TextStyle(fontSize: 11)),
                                            ]),
                                        subtitle: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                                "Jumlah penjualan: ${pembelian2[index].jumlah_barang}",
                                                style: TextStyle(fontSize: 11)),
                                            Text(
                                                "Total Penjualan: Rp. ${NumberFormat('###,000').format((pembelian2[index].total_pembelian - pembelian2[index].diskon) + (((pembelian2[index].total_pembelian - pembelian2[index].diskon) * (pembelian2[index].ppn / 100.00))))}",
                                                style: TextStyle(
                                                  fontSize: 11,
                                                ))
                                          ],
                                        )))))
                      ],
                    )));
          });
    }
  }

  Widget buildHistoryPembelian() {
    return Container(
        padding: EdgeInsets.all(10),
        height: MediaQuery.of(context).size.height - 150,
        width: MediaQuery.of(context).size.width,
        child: FutureBuilder(
            future: fetchDataHistoryPembelian(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return daftarHistoryPembelian(snapshot.data.toString());
              } else {
                return Center(child: CircularProgressIndicator());
              }
            }));
  }

  Widget buildHistoryPenjualan() {
    return Container(
        padding: EdgeInsets.all(10),
        height: MediaQuery.of(context).size.height - 150,
        width: MediaQuery.of(context).size.width,
        child: FutureBuilder(
            future: fetchDataHistoryPenjualan(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return daftarHistoryPenjualan(snapshot.data.toString());
              } else {
                return Center(child: CircularProgressIndicator());
              }
            }));
  }

  Widget buildHistoryEvent() {
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: DefaultTabController(
            length: id_jabatan == "3" ? 2 : 3,
            child: Scaffold(
                appBar: AppBar(
                    title: TabBar(tabs: [
                  Tab(
                    icon: Icon(
                      ClipBoardCheck.clipboard_check,
                      size: 20,
                    ),
                    child: Text(
                      "Riwayat Penjualan",
                      style: TextStyle(fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  if (id_jabatan != "3")
                    Tab(
                      icon: Icon(
                        Clippy.clippy,
                        size: 20,
                      ),
                      child: Text(
                        "Riwayat Pembelian",
                        style: TextStyle(fontSize: 10),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  Tab(
                    icon: Icon(
                      EventChart.chart_line,
                      size: 20,
                    ),
                    child: Text(
                      "Riwayat Event",
                      style: TextStyle(fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ])),
                body: TabBarView(
                    children: id_jabatan == "3"
                        ? <Widget>[buildHistoryPenjualan(), buildHistoryEvent()]
                        : <Widget>[
                            buildHistoryPenjualan(),
                            buildHistoryPembelian(),
                            buildHistoryEvent()
                          ]))));
  }
}
