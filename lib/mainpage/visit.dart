import 'dart:convert';
import 'dart:math';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart';
import 'package:pt_coronet_crown/customicon/add_image_icons.dart';
import 'package:pt_coronet_crown/customicon/add_penjualan_icons.dart';
import 'package:http/http.dart' as http;
import 'package:pt_coronet_crown/mainpage/detailvisit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Visit extends StatefulWidget {
  Visit({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _VisitState();
  }
}

class _VisitState extends State<Visit> {
  List _outlet = [];
  String _id_outlet = "",
      controllerOutlet = "",
      username = "",
      date = "",
      deskripsi = "";
  int id = Random().nextInt(4294967296);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadData();
    date = DateTime.now().toString().substring(0, 10);
  }

  _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString("username") ?? '';
    });
  }

  void submit(BuildContext context) async {
    final response = await http.post(
        Uri.parse("http://192.168.137.1/magang/absensi/visit/visit_in.php"),
        body: {
          'id': "$id-$_id_outlet-$username-$date",
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
                      id_visit: "$id-$_id_outlet-$username-$date",
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
          title: Text("Halaman Kunjungan"),
          leading: BackButton(
            onPressed: () {
              Navigator.popAndPushNamed(context, "/homepage");
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
              height: MediaQuery.of(context).size.height,
              alignment: Alignment.topCenter,
              width: 720,
              child: Column(
                children: [
                  Container(
                      alignment: Alignment.topLeft,
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
                        child: Text("Ini adalah kotak location")),
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
                      showSearchBox: true,
                      onFind: (text) async {
                        Map json;
                        var response = await http.post(
                            Uri.parse(
                                "http://192.168.137.1/magang/outlet/daftaroutlet.php"),
                            body: {'cari': text});

                        if (response.statusCode == 200) {
                          json = jsonDecode(response.body);
                          setState(() {
                            _outlet = json['data'];
                          });
                        }
                        return _outlet as List<dynamic>;
                      },
                      onChanged: (value) {
                        setState(() {
                          controllerOutlet = value['nama_toko'];
                          _id_outlet = value['id'];
                        });
                      },
                      itemAsString: (item) => item['nama_toko'],
                    ),
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
                        labelText: 'Add Description (Maksimal 5 baris)',
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
                        child: Text('Check In'),
                      ),
                    ),
                  ),
                ],
              )),
        ));
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
