import 'dart:convert';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pt_coronet_crown/class/produk.dart';
import 'package:pt_coronet_crown/customicon/clip_board_check_icons.dart';
import 'package:pt_coronet_crown/customicon/clippy_icons.dart';
import 'package:pt_coronet_crown/customicon/event_chart_icons.dart';
import 'package:pt_coronet_crown/laporan/pembelian/daftarpembelian.dart';
import 'package:pt_coronet_crown/laporan/penjualan/daftarpenjualan.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:unique_identifier/unique_identifier.dart';

String nama_depan = "", nama_belakang = "", username = "", id_jabatan = "";

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
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

  _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString("username") ?? '';
      id_jabatan = prefs.getString("idJabatan") ?? '';
      nama_depan = prefs.getString("nama_depan") ?? '';
      nama_belakang = prefs.getString("nama_belakang") ?? '';
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
      child: Card(
          elevation: 5,
          child: Container(
            padding: EdgeInsets.all(15),
            alignment: Alignment.topLeft,
            child:
                Column(mainAxisAlignment: MainAxisAlignment.start, children: [
              Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text(
                    "Etalase Product",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.red[300]),
                  )),
              ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: produk2.length,
                  itemBuilder: (BuildContext ctxt, int index) {
                    return Container(
                        padding: EdgeInsets.only(top: 5),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
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
                                  elevation: 2,
                                  child: Container(
                                    width: 400,
                                    child: Image.memory(base64Decode(
                                        produk2[index].gambar.toString())),
                                  ),
                                ))
                          ],
                        ));
                  })
            ]),
          )),
    );
    // return CarouselSlider(

    //   options: CarouselOptions(height: 400.0),
    //   items: [1, 2, 3, 4, 5].map((i) {
    //     return Builder(
    //       builder: (BuildContext context) {
    //         return Container(
    //             width: 300,
    //             margin: EdgeInsets.symmetric(horizontal: 5.0),
    //             decoration: BoxDecoration(color: Colors.amber),
    //             child: Text(
    //               'text $i',
    //               style: TextStyle(fontSize: 16.0),
    //             ));
    //       },
    //     );
    //   }).toList(),
    // );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadData();
    // getDeviceInfor();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: FutureBuilder(
          future: fetchDataProduct(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return buildProductSlider(snapshot.data.toString());
            } else {
              return Center(child: CircularProgressIndicator());
            }
          }),
    ));
  }
  //   if (id_jabatan != "1" || id_jabatan != "2") {
  //     if (kIsWeb) {
  //       return Scaffold(
  //           body: Center(
  //         child: Text(
  //           "Silahkan akses melalui aplikasi pada ponsel anda",
  //           style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  //           textAlign: TextAlign.center,
  //         ),
  //       ));
  //     } else {
  //       return Scaffold(
  //         body: Center(
  //             child: SingleChildScrollView(
  //                 child: Column(children: <Widget>[
  //           Text(
  //             "\nSelamat datang \n$nama_depan $nama_belakang \n",
  //             textAlign: TextAlign.center,
  //             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  //           ),
  //           SizedBox(
  //               height: MediaQuery.of(context).size.height,
  //               width: 700,
  //               child: GridView.count(
  //                 crossAxisCount: 2,
  //                 crossAxisSpacing: 4.0,
  //                 childAspectRatio: 2 / 1.5,
  //                 children: [
  //                   GestureDetector(
  //                       onTap: () {
  //                         // Navigator.push(
  //                         //   context,
  //                         //   MaterialPageRoute(
  //                         //     builder: (context) => DetailSensor(
  //                         //       sensor_id: sensor2[index].sensor_id,
  //                         //     ),
  //                         //   ),
  //                         // );
  //                       },
  //                       child: Card(
  //                           child: SizedBox(
  //                               width: double.infinity,
  //                               height: double.infinity,
  //                               child: Column(
  //                                 mainAxisAlignment: MainAxisAlignment.center,
  //                                 children: [
  //                                   Icon(
  //                                     Icons.check_rounded,
  //                                     size: 60,
  //                                   ),
  //                                   Text(
  //                                     "Absen hadir",
  //                                     style: TextStyle(fontSize: 16),
  //                                   )
  //                                 ],
  //                               )))),
  //                   GestureDetector(
  //                       onTap: () {
  //                         // Navigator.push(
  //                         //   context,
  //                         //   MaterialPageRoute(
  //                         //     builder: (context) => DetailSensor(
  //                         //       sensor_id: sensor2[index].sensor_id,
  //                         //     ),
  //                         //   ),
  //                         // );
  //                       },
  //                       child: Card(
  //                           child: Container(
  //                               width: double.infinity,
  //                               height: double.infinity,
  //                               child: Column(
  //                                 mainAxisAlignment: MainAxisAlignment.center,
  //                                 children: [
  //                                   Icon(
  //                                     Icons.exit_to_app,
  //                                     size: 60,
  //                                   ),
  //                                   Text(
  //                                     "Absen pulang",
  //                                     style: TextStyle(fontSize: 16),
  //                                   )
  //                                 ],
  //                               )))),
  //                   GestureDetector(
  //                       onTap: () {
  //                         Navigator.popAndPushNamed(context, "/kunjunganmasuk");
  //                       },
  //                       child: Card(
  //                           child: SizedBox(
  //                               width: double.infinity,
  //                               height: double.infinity,
  //                               child: Column(
  //                                 mainAxisAlignment: MainAxisAlignment.center,
  //                                 children: [
  //                                   Icon(
  //                                     Icons.location_on,
  //                                     size: 60,
  //                                   ),
  //                                   Text(
  //                                     "Kunjungan Masuk",
  //                                     style: TextStyle(fontSize: 16),
  //                                   )
  //                                 ],
  //                               )))),
  //                   GestureDetector(
  //                       onTap: () {
  //                         Navigator.push(
  //                           context,
  //                           MaterialPageRoute(
  //                               builder: (context) => DaftarPenjualan()),
  //                         );
  //                       },
  //                       child: Card(
  //                           child: Container(
  //                               width: double.infinity,
  //                               height: double.infinity,
  //                               child: Column(
  //                                 mainAxisAlignment: MainAxisAlignment.center,
  //                                 children: [
  //                                   Icon(
  //                                     Icons.location_off,
  //                                     size: 60,
  //                                   ),
  //                                   Text(
  //                                     "Kunjungan keluar",
  //                                     style: TextStyle(fontSize: 16),
  //                                   )
  //                                 ],
  //                               )))),
  //                   if (id_jabatan != "3" &&
  //                       id_jabatan != "4" &&
  //                       id_jabatan != "5")
  //                     GestureDetector(
  //                         onTap: () {
  //                           Navigator.popAndPushNamed(
  //                               context, "daftarpembelian");
  //                         },
  //                         child: Card(
  //                             child: Container(
  //                                 width: double.infinity,
  //                                 height: double.infinity,
  //                                 child: Column(
  //                                   mainAxisAlignment: MainAxisAlignment.center,
  //                                   children: [
  //                                     Icon(
  //                                       Clippy.clippy,
  //                                       size: 60,
  //                                     ),
  //                                     Text(
  //                                       "\nLaporan pembelian",
  //                                       style: TextStyle(fontSize: 16),
  //                                     )
  //                                   ],
  //                                 )))),
  //                   if (id_jabatan != "3")
  //                     GestureDetector(
  //                         onTap: () {
  //                           Navigator.popAndPushNamed(
  //                               context, "/daftarpenjualan");
  //                         },
  //                         child: Card(
  //                             child: Container(
  //                                 width: double.infinity,
  //                                 height: double.infinity,
  //                                 child: Column(
  //                                   mainAxisAlignment: MainAxisAlignment.center,
  //                                   children: [
  //                                     Icon(
  //                                       ClipBoardCheck.clipboard_check,
  //                                       size: 60,
  //                                     ),
  //                                     Text(
  //                                       "\nLaporan Penjualan",
  //                                       style: TextStyle(fontSize: 16),
  //                                     )
  //                                   ],
  //                                 )))),
  //                   GestureDetector(
  //                       onTap: () {
  //                         // Navigator.push(
  //                         //   context,
  //                         //   MaterialPageRoute(
  //                         //     builder: (context) => DetailSensor(
  //                         //       sensor_id: sensor2[index].sensor_id,
  //                         //     ),
  //                         //   ),
  //                         // );
  //                       },
  //                       child: Card(
  //                           child: Container(
  //                               width: double.infinity,
  //                               height: double.infinity,
  //                               child: Column(
  //                                 mainAxisAlignment: MainAxisAlignment.center,
  //                                 children: [
  //                                   Icon(
  //                                     EventChart.chart_line,
  //                                     size: 60,
  //                                   ),
  //                                   Text(
  //                                     "\nLaporan Event",
  //                                     style: TextStyle(fontSize: 16),
  //                                   )
  //                                 ],
  //                               )))),
  //                 ],
  //               ))
  //         ]))),
  //       );
  //     }
  //   } else {
  //     return Scaffold(
  //         body: Center(
  //       child: Text("Selamat datang"),
  //     ));
  //   }
  // }
}
