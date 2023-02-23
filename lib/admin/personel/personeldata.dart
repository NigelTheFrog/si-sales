import 'dart:convert';
import 'dart:developer';
import 'dart:html';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pt_coronet_crown/account/createacount.dart';
import 'package:pt_coronet_crown/class/personaldata.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

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
    final response = await http.post(Uri.parse(
        "http://localhost/magang/admin/personel/personeldata/daftarpersoneldata.php"));
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to read API');
    }
  }

  List<Widget> listPersonel(data) {
    List<Widget> temp = [];
    List<Person> person2 = [];
    Map json = jsonDecode(data);
    for (var pers in json['data']) {
      Person person = Person.fromJson(pers);
      person2.add(person);
    }
    var idx = 0;
    while (idx < person2.length) {
      // print(person2[idx].username);
      Widget w = Container(
          child: Card(
              child: Row(children: [
        Align(
            alignment: Alignment.topLeft,
            child: Container(
                margin: EdgeInsets.only(top: 1),
                width: 100,
                height: 131,
                child: Image.memory(
                  base64Decode(person2[idx].avatar),
                ))),
        Container(
            padding: EdgeInsets.all(5),
            width: 270,
            child: Column(
              children: [
                Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "${person2[idx].nama_depan} ${person2[idx].nama_belakang} - ${person2[idx].jabatan} ${person2[idx].nama_cabang}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )),
                Align(
                    alignment: Alignment.topLeft,
                    child: Text(person2[idx].username)),
                Row(children: [
                  Icon(Icons.mail),
                  Text(person2[idx].email, textAlign: TextAlign.left)
                ]),
                Row(children: [
                  Icon(Icons.phone),
                  Text(person2[idx].no_telp, textAlign: TextAlign.left)
                ]),
                Align(
                    alignment: Alignment.bottomLeft,
                    child: Text("Group : " + person2[idx].nama_grup,
                        textAlign: TextAlign.left))
              ],
            ))
      ])));
      temp.add(w);
      idx++;
    }
    return temp;
  }

  @override
  Widget build(BuildContext context) {
    var ratio = MediaQuery.of(context).size;

    /*24 is for notification bar on Android*/
    final double itemHeight = (ratio.height - kToolbarHeight - 24) / 1.2;
    final double itemWidth = ratio.width;

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
                    height: MediaQuery.of(context).size.height,
                    width: 800,
                    child: FutureBuilder(
                        future: fetchData(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return GridView.count(
                                crossAxisCount: kIsWeb
                                    ? MediaQuery.of(context).size.width >= 870
                                        ? 2
                                        : 1
                                    : 1,
                                crossAxisSpacing: 4.0,
                                childAspectRatio:
                                    (800 / (MediaQuery.of(context).size.height/2.3)),
                                mainAxisSpacing: 8.0,
                                children:
                                    listPersonel(snapshot.data.toString()));
                          } else {
                            return Center(child: CircularProgressIndicator());
                          }
                        }))
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
