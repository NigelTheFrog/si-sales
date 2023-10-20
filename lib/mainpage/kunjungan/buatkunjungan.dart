import 'dart:convert';
import 'dart:math';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pt_coronet_crown/customicon/add_image_icons.dart';
import 'package:pt_coronet_crown/customicon/add_penjualan_icons.dart';
import 'package:http/http.dart' as http;
import 'package:pt_coronet_crown/mainpage/kunjungan/detailkunjungan.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BuatKunjungan extends StatefulWidget {
  BuatKunjungan({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _BuatKunjunganState();
  }
}

class _BuatKunjunganState extends State<BuatKunjungan> {
  List _outlet = [];
  String _id_outlet = "",
      controllerOutlet = "",
      username = "",
      date = "",
      deskripsi = "";
  double lintang = 0, bujur = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadData();
    date = DateTime.now().toString().substring(0, 10);
    Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best,
            forceAndroidLocationManager: true)
        .then((Position position) {
      setState(() {
        lintang = position.latitude;
        bujur = position.longitude;
      });
    });
  }

  _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString("username") ?? '';
    });
  }

  void submit(BuildContext context) async {
    final response = await http.post(
        Uri.parse(
            "https://otccoronet.com/otc/account/kunjungan/buatkunjungan.php"),
        body: {
          'id': "$_id_outlet/$username/$date",
          'tanggal': date,
          'deskripsi': deskripsi,
          'id_outlet': _id_outlet,
          'username': username
        });
    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      if (json['result'] == 'success') {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Sukses menyimpan data kunjungan')));
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DetailVisit(
                      type: 1,
                      id_visit: "$_id_outlet/$username/$date",
                      username: username,
                      status: 0,
                    )));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sukses menyimpan data kunjungan')));
    }
  }

  void alertCheckInDialog(context) {
    showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Text('Peringatan'),
              content: Text("Mohon untuk melakukan check in terlebih dahulu"),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context, 'OK'),
                  child: const Text('OK'),
                ),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Halaman Kunjungan",
            style: TextStyle(color: Colors.white),
          ),
          leading: BackButton(
            color: Colors.white,
            onPressed: () {
              Navigator.popAndPushNamed(context, "/homepage");
            },
          ),
        ),
        body: Align(
            alignment: Alignment.topCenter,
            child: Container(
              height: MediaQuery.of(context).size.height,
              alignment: Alignment.topCenter,
              width: 480,
              child: SingleChildScrollView(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(10),
                      child: Text(
                        "Lokasi",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      )),
                  Container(
                    height: 250,
                    margin: EdgeInsets.only(left: 10, right: 10),
                    child: Align(
                        alignment: Alignment.center,
                        child: Image.network(
                            "https://otccoronet.com/otc/asset/maps.jpeg")),
                  ),
                  Container(
                      padding: EdgeInsets.only(left: 10, right: 10, top: 10),
                      alignment: Alignment.center,
                      child: DropdownSearch<dynamic>(
                          dropdownSearchDecoration: InputDecoration(
                            hintText: "Daftar Outlet",
                            hintStyle: TextStyle(
                              fontSize: MediaQuery.of(context).size.width >= 720
                                  ? 14
                                  : 12,
                            ),
                            labelText: "Nama Outlet",
                            labelStyle: TextStyle(
                              fontSize: MediaQuery.of(context).size.width >= 720
                                  ? 14
                                  : 12,
                            ),
                          ),
                          mode: Mode.MENU,
                          showSearchBox: false,
                          emptyBuilder: (context, searchEntry) => Center(
                                child: Text("Tidak ada data ditemukan"),
                              ),
                          onFind: (text) async {
                            Map json;
                            var response = await http.post(
                                Uri.parse(
                                    "https://otccoronet.com/otc/outlet/daftaroutlet.php"),
                                body: {
                                  'lintang': lintang.toString(),
                                  'bujur': bujur.toString()
                                });

                            if (response.statusCode == 200) {
                              json = jsonDecode(response.body);
                              _outlet = json['data'];
                            }
                            return _outlet as List<dynamic>;
                          },
                          onChanged: (value) {
                            setState(() {
                              controllerOutlet = value['nama_toko'];
                              _id_outlet = value['id'];
                            });
                          },
                          itemAsString: (item) => item['nama_toko'])
                      //  DropdownSearch<dynamic>(
                      //   dropdownSearchDecoration: InputDecoration(
                      //     hintText: "Daftar Outlet",
                      //     hintStyle: TextStyle(
                      //       fontSize: MediaQuery.of(context).size.width >= 720
                      //           ? 14
                      //           : 12,
                      //     ),
                      //     labelText: "Nama Outlet",
                      //     labelStyle: TextStyle(
                      //       fontSize: MediaQuery.of(context).size.width >= 720
                      //           ? 14
                      //           : 12,
                      //     ),
                      //   ),
                      //   mode: Mode.MENU,
                      //   showSearchBox: false,
                      //   emptyBuilder: (context, searchEntry) => Center(
                      //     child: Text("Tidak ada data ditemukan"),
                      //   ),
                      //   onFind: (text) async {
                      //     Map json;
                      //     var response = await http.post(
                      //         Uri.parse(
                      //             "https://otccoronet.com/otc/outlet/daftaroutlet.php"),
                      //         body: {
                      //           'lintang': lintang.toString(),
                      //           'bujur': bujur.toString()
                      //         });

                      //     if (response.statusCode == 200) {
                      //       json = jsonDecode(response.body);
                      //       _outlet = json['data'];
                      //     }
                      //     return _outlet;
                      //   },
                      //   onChanged: (value) {
                      //     setState(() {
                      //       controllerOutlet = value['nama_toko'];
                      //       _id_outlet = value['id'];
                      //     });
                      //   },
                      //   itemAsString: (item) => item['nama_toko'],
                      // ),
                      ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: TextField(
                      keyboardType: TextInputType.multiline,
                      minLines: 1,
                      maxLines: 5,
                      style: TextStyle(
                        fontSize:
                            MediaQuery.of(context).size.width >= 720 ? 14 : 12,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Deskripsi (Maksimal 5 baris)',
                      ),
                      onChanged: (value) {
                        setState(() {
                          deskripsi = value;
                        });
                        // _diskon = value;
                      },
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    alignment: Alignment.topLeft,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Text("Bukti Kunjungan\n"),
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white),
                                onPressed: () {
                                  alertCheckInDialog(context);
                                },
                                child: Padding(
                                    padding: EdgeInsets.all(10),
                                    child: SizedBox(
                                        width: 60,
                                        height: 60,
                                        child: Icon(
                                          AddImage.add_image,
                                          size: 40,
                                          color: Colors.grey,
                                        ))))
                          ],
                        ),
                        Padding(
                            padding: EdgeInsets.only(left: 20),
                            child: Column(
                              children: [
                                Text("Tambah Penjualan\n"),
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white),
                                    onPressed: () {
                                      alertCheckInDialog(context);
                                    },
                                    child: Padding(
                                        padding: EdgeInsets.all(10),
                                        child: SizedBox(
                                            width: 60,
                                            height: 60,
                                            child: Icon(
                                              AddPenjualan.doc_add,
                                              size: 40,
                                              color: Colors.grey,
                                            ))))
                              ],
                            )),
                      ],
                    ),
                  ),
                  Container(
                      height: 50,
                      margin: const EdgeInsets.all(10),
                      child: ElevatedButton(
                          onPressed: () {
                            submit(context);
                          },
                          child: const Center(
                              child: Text('Check In',
                                  style: TextStyle(color: Colors.white)))))
                ],
              )),
            )));
  }
  // _loadData() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   setState(() {
  //     username = prefs.getString("username") ?? '';
  //     id_jabatan = prefs.getString("idJabatan") ?? '';
  //     nama_depan = prefs.getString("nama_depan") ?? '';
  //     nama_belakang = prefs.getString("nama_belakang") ?? '';
  //   });
  // }
}
