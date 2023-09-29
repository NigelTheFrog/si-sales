import 'dart:convert';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:pt_coronet_crown/class/admin/absen/visit.dart';
import 'package:pt_coronet_crown/customicon/add_image_icons.dart';
import 'package:pt_coronet_crown/customicon/add_penjualan_icons.dart';
import 'package:http/http.dart' as http;

class DetailVisit extends StatefulWidget {
  int type;
  String id_visit;
  DetailVisit({super.key, required this.type, required this.id_visit});
  @override
  State<StatefulWidget> createState() {
    return _DetailVisitState();
  }
}

class _DetailVisitState extends State<DetailVisit> {
  Kunjungan? kunjungan;
  TextEditingController deskripsi = TextEditingController();
  TextEditingController outlet = TextEditingController();
  var bukti, id_nota;

  Future<String> fetchData() async {
    final response = await http.post(
        Uri.parse("http://192.168.137.1/magang/absensi/visit/detailvisit.php"),
        body: {'id': widget.id_visit});
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to read API');
    }
  }

  bacadata() {
    fetchData().then((value) {
      Map json = jsonDecode(value);
      kunjungan = Kunjungan.fromJson(json['data']);
      setState(() {
        deskripsi.text = kunjungan!.deskripsi;
        outlet.text = kunjungan!.nama_toko;
        bukti = kunjungan!.foto;
        id_nota = kunjungan!.id_nota;
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    bacadata();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Halaman Kunjungan"),
          leading: BackButton(
            onPressed: () {
              if (widget.type == 1) {
                Navigator.popAndPushNamed(context, "/homepage");
              } else if (widget.type == 2) {
                Navigator.pop(context);
              } else {
                Navigator.popAndPushNamed(context, "/dailyvisit");
              }
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
                      child: TextField(
                        controller: outlet,
                        enabled: false,
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width >= 720
                              ? 14
                              : 12,
                        ),
                      )),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: TextField(
                      controller: deskripsi,
                      enabled: false,
                      minLines: 1,
                      maxLines: 5,
                      style: TextStyle(
                        fontSize:
                            MediaQuery.of(context).size.width >= 720 ? 14 : 12,
                      ),
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
                            bukti == ""
                                ? GestureDetector(
                                    onTap: () {},
                                    child: SizedBox(
                                        width: 60,
                                        height: 60,
                                        child:
                                            Image.memory(base64Decode(bukti))),
                                  )
                                : ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white),
                                    onPressed: () {},
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
                                id_nota == null
                                    ? ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white),
                                        onPressed: () {
                                          Navigator.popAndPushNamed(context,
                                              "/tambahlaporanpenjualan");
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
                                    : TextButton(
                                        onPressed: () {},
                                        child:
                                            Text(kunjungan!.id_nota.toString()))
                              ],
                            )),
                      ],
                    ),
                  ),
                  Container(
                    height: 50,
                    margin: const EdgeInsets.all(10),
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Center(
                        child: Text('Check out'),
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
