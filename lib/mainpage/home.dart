import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pt_coronet_crown/class/homepage.dart';
import 'package:pt_coronet_crown/class/produk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  String username = "",
      id_jabatan = "",
      date = "",
      id_area = "",
      id_provinsi = "",
      id_grup = "";
  Future<String> fetchDataProduct() async {
    final response = await http.post(
        Uri.parse("https://otccoronet.com/otc/admin/product/daftarproduct.php"),
        body: {'type': '1'});
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to read API');
    }
  }

  Future<String> fetchData(type) async {
    final response = await http.post(
        Uri.parse(
            "https://otccoronet.com/otc/account/kunjungan/jumlahkunjungan.php"),
        body: {
          'username': username,
          'id_jabatan': id_jabatan,
          'id_grup': id_grup,
          'id_provinsi': id_provinsi,
          'id_area': id_area,
          'type': type.toString()
        });
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
      id_provinsi = prefs.getString("username") ?? '';
      id_grup = prefs.getString("idGrup") ?? '';
      id_area = prefs.getString("username") ?? '';
    });
  }

  // getDeviceInfor() async {
  //   DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  //   if (Platform.isAndroid) {
  //     String? identifier = await UniqueIdentifier.serial;
  //     print("Device Id: $identifier");
  //   } else if (Platform.isIOS) {
  //     IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
  //     print(iosInfo.identifierForVendor);
  //   }
  // }

  Widget buildVisitChart(data) {
    List<HomePage> homepage2 = [];
    Map json = jsonDecode(data);
    if (json['result'] == "error") {
      return CircularProgressIndicator();
    } else {
      for (var home in json['data']) {
        HomePage homepage = HomePage.fromJson(home);
        homepage2.add(homepage);
      }

      // return SizedBox(
      //     // width: MediaQuery.of(context).size.width * 0.45,
      //     // height: 500,
      //     child:
      return SfCartesianChart(
          primaryXAxis: CategoryAxis(),
          series: <CartesianSeries>[
            ColumnSeries<HomePage, String>(
                dataSource: homepage2,
                xValueMapper: (HomePage data, _) => data.tanggalKunjungan,
                yValueMapper: (HomePage data, _) => data.jumlahKunjungan,
                dataLabelSettings: DataLabelSettings(isVisible: true),
                pointColorMapper: (HomePage data, _) => Colors.green)
          ]);
    }
  }

  Widget buildProductSlider(data) {
    List<Produk> produk2 = [];
    Map json = jsonDecode(data);
    if (json['result'] == "error") {
      return CircularProgressIndicator();
    } else {
      for (var prod in json['data']) {
        Produk produk = Produk.fromJson(prod);
        produk2.add(produk);
      }
    }
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 400,
        child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: produk2.length,
            itemBuilder: (BuildContext ctxt, int index) {
              return Container(
                  padding: EdgeInsets.only(top: 5),
                  child:
                      Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    GestureDetector(
                        onTap: () {
                          // Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //         builder: (context) => DetailVisit(
                          //               type: 0,
                          //               id_visit: visit2[index].id,
                          //             )));
                        },
                        child: Card(
                            elevation: 5,
                            child: Container(
                                margin: EdgeInsets.all(10),
                                height: 355,
                                width: 325,
                                child: Column(children: [
                                  Container(
                                      color: Colors.grey.shade200,
                                      child: Image.memory(
                                          fit: BoxFit.cover,
                                          base64Decode(produk2[index]
                                              .gambar
                                              .toString()))),
                                  Padding(
                                      padding: EdgeInsets.only(top: 10),
                                      child: Text(produk2[index].jenis,
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)))
                                ]))))
                  ]));
            }));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadData();
    // getDeviceInfor();
  }

  Widget buildCardChart(type, cardType, title) {
    return Container(
        padding: MediaQuery.of(context).size.width >= 720
            ? cardType == 0
                ? EdgeInsets.only(left: 10)
                : EdgeInsets.only(right: 10)
            : EdgeInsets.only(left: 10, right: 10, bottom: 10),
        width: MediaQuery.of(context).size.width >= 1050
            ? MediaQuery.of(context).size.width * 0.405
            : MediaQuery.of(context).size.width >= 720 &&
                    MediaQuery.of(context).size.width < 1050
                ? MediaQuery.of(context).size.width * 0.495
                : MediaQuery.of(context).size.width,
        height: 400,
        child: Card(
          elevation: 5,
          child: Container(
              padding: EdgeInsets.all(15),
              alignment: Alignment.topLeft,
              child:
                  Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                Container(
                    alignment: Alignment.topLeft,
                    padding: EdgeInsets.only(bottom: 10),
                    child: Text(
                      title,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.red[300]),
                    )),
                FutureBuilder(
                    future: fetchData(type),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return buildVisitChart(snapshot.data.toString());
                        // if (cardType == 0) {
                        //   return buildVisitChart(snapshot.data.toString());
                        // } else {
                        //   return buildVisitChart(snapshot.data.toString());
                        // }
                      } else {
                        return Center(child: CircularProgressIndicator());
                      }
                    })
              ])),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
                child: Column(children: [
              Padding(
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  child: MediaQuery.of(context).size.width >= 720
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                              buildCardChart(1, 0, "Jumlah Kunjungan"),
                              buildCardChart(1, 1, "Jumlah Transaksi")
                            ])
                      : Column(children: [
                          buildCardChart(1, 0, "Jumlah Kunjungan"),
                          buildCardChart(1, 1, "Jumlah Transaksi")
                        ])),
              Container(
                  padding: EdgeInsets.only(right: 10, left: 10),
                  width: MediaQuery.of(context).size.width,
                  height: 470,
                  child: Card(
                      elevation: 5,
                      child: Container(
                          padding: EdgeInsets.all(15),
                          alignment: Alignment.topLeft,
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                    alignment: Alignment.topLeft,
                                    padding: EdgeInsets.only(bottom: 10),
                                    child: Text(
                                      "Etalase Product",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red[300]),
                                    )),
                                FutureBuilder(
                                    future: fetchDataProduct(),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        return buildProductSlider(
                                            snapshot.data.toString());
                                      } else {
                                        return Center(
                                            child: CircularProgressIndicator());
                                      }
                                    })
                              ]))))
            ]))));
  }
}
