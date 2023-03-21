import 'dart:convert';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Test extends StatefulWidget {
  const Test({Key? key}) : super(key: key);

  @override
  State<Test> createState() => _MyAppState();
}

class _MyAppState extends State<Test> {
  //inizialize variable
  List _get = [];
  String provinsi = '';
  int? kodeProvinsi;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Dropdown Search"),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownSearch<dynamic>(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: "Daftar Outlet",
                    hintText: "Cari outlet",
                  ),
                  mode: Mode.MENU,
                  showSearchBox: true,
                  onFind: (text) async {
                    Map json;
                    var response = await http.post(
                        Uri.parse(
                            "http://localhost/magang/outlet/daftaroutlet.php"),
                        body: {'cari': text});

                    if (response.statusCode == 200) {
                      json = jsonDecode(response.body);

                      setState(() {
                        _get = json['data'];
                      });
                    }

                    return _get as List<dynamic>;
                  },

                  //what do you want anfter item clicked
                  onChanged: (value) {
                    setState(() {
                      print(value['id']);
                      print(value['nama_toko']);
                    });
                  },
                  itemAsString: (item) => item['nama_toko'],
                ),
                SizedBox(
                  height: 10,
                ),
                //show data in text
                Text(
                  "Provinsi yang Dipilih: ${provinsi}",
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Kode Provinsi yang Dipilih: ${kodeProvinsi}",
                  style: TextStyle(fontSize: 18),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
