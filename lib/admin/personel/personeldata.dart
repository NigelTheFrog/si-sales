import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pt_coronet_crown/account/createacount.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';

class PersonelData extends StatefulWidget {
  PersonelData({Key? key}) : super(key: key);
  @override
  _PersonelDataState createState() {
    return _PersonelDataState();
  }
}

class _PersonelDataState extends State<PersonelData> {
  String _txtcari = "";

  Future<String> fetchData() async {
    final response = await http.post(
        Uri.parse("https://ubaya.fun/flutter/160419017/movielist.php"),
        body: {'cari': _txtcari});
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to read API');
    }
  }

  List<Widget> cats() {
    List<Widget> temp = [];
    int i = 0;
    while (i < 15) {
      Widget w = Image.network(
          "https://placekitten.com/120/120?image=" + i.toString());
      temp.add(w);
      i++;
    }
    return temp;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Personnel Data"),
        ),
        body: Container(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.all(10),
                  padding: EdgeInsets.all(10),
                  alignment: Alignment.topCenter,
                  width: 400,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Color.fromARGB(255, 248, 172, 49)),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => CreateAccount()));
                            },
                            child: Text(
                              "Add New Personnel",
                              style:
                                  TextStyle(color: Colors.black, fontSize: 16),
                            )),
                        Container(
                          height: 50,
                          width: 175,
                          child: TextFormField(
                            decoration: const InputDecoration(
                              icon: Icon(Icons.search),
                              labelText: 'Search Personnel',
                            ),
                            onChanged: (value) {
                              _txtcari = value;
                              // bacaData();
                            },
                          ),
                        )
                      ]),
                ),
                Container(
                  alignment: Alignment.topCenter,
                  width: 600,
                  height: MediaQuery.of(context).size.height,
                  child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 4.0,
                      mainAxisSpacing: 8.0,
                      children: cats()),
                )
              ],
            ),
          ),
          // floatingActionButton: FloatingActionButton(
          //   onPressed: _incrementCounter,
          //   tooltip: 'Increment',
          //   child: const Icon(Icons.add),
          // ), // This trailing comma makes auto-formatting nicer for build methods.
        ));
  }
}
