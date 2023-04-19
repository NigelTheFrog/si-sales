import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pt_coronet_crown/admin/personel/detailpersonel.dart';
import 'package:pt_coronet_crown/class/personel/personel.dart';
import 'package:pt_coronet_crown/drawer.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';

class PersonelData extends StatefulWidget {
  PersonelData({Key? key}) : super(key: key);
  @override
  _PersonelDataState createState() {
    return _PersonelDataState();
  }
}

String id_jabatan = "";

class _PersonelDataState extends State<PersonelData> {
  String _txtcari = "";

  Future<String> fetchData() async {
    final response = await http.post(
        Uri.parse(
            "http://192.168.137.1/magang/admin/personel/personeldata/daftarpersoneldata.php"),
        body: {"cari": _txtcari});
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to read API');
    }
  }

  void deletePersonel(String username) async {
    final response = await http.post(
        Uri.parse(
            "http://192.168.137.1/magang/admin/personel/personeldata/deletepersonel.php"),
        body: {"username": username});
    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      if (json['result'] == 'success') {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Sukses menghapus data $username')));
      }
    } else {
      throw Exception('Failed to read API');
    }
  }

  _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      id_jabatan = prefs.getString("idJabatan") ?? '';
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadData();
  }

  List<Widget> listPersonel(BuildContext context, data) {
    List<Widget> temp = [];
    List<Person> person2 = [];
    Map json = jsonDecode(data);
    Widget w = Text("");
    if (json['result'] == "error") {
      w = Text("");
    } else {
      for (var pers in json['data']) {
        Person person = Person.fromJson(pers);
        person2.add(person);
      }
      for (int i = 0; i < person2.length; i++) {
        w = Card(
            child: Stack(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Column(
                children: [
                  Tooltip(
                    message: 'Personnel attendance',
                    child: IconButton(
                      icon: Icon(Icons.zoom_in),
                      onPressed: () {},
                    ),
                  ),
                  Tooltip(
                    message: 'Edit data personnel',
                    child: IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DetailPersonel(
                                      username: person2[i].username,
                                      avatar: person2[i].avatar,
                                      namaDepan: person2[i].nama_depan,
                                      namaBelakang: person2[i].nama_belakang,
                                      nomorTelepon: person2[i].no_telp,
                                      namaJabatan: person2[i].jabatan,
                                      namaCabang: person2[i].nama_cabang,
                                      email: person2[i].email,
                                      idcabang: person2[i].id_cabang,
                                      idjabatan:
                                          person2[i].id_jabatan.toString(),
                                      idgrup: person2[i].id_grup,
                                      namaGrup: person2[i].nama_grup,
                                    )));
                      },
                    ),
                  ),
                  Tooltip(
                    message: 'Delete Personnel',
                    child: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("Warning!"),
                                content: Text(
                                    "Dengan menekan tombol iya, \nAnda akan menghapus data user: ${person2[i].username}"),
                                actions: [
                                  TextButton(
                                    child: Text("Cancel"),
                                    onPressed: () {},
                                  ),
                                  TextButton(
                                    child: Text("Iya"),
                                    onPressed: () {
                                      //deletePersonel(person2[i].username);
                                    },
                                  )
                                ],
                              );
                            },
                          );
                          //deletePersonel(person2[idx].username);
                        });
                      },
                    ),
                  )
                ],
              ),
            ),
            Row(children: [
              Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                      margin: EdgeInsets.only(top: 1),
                      width: 100,
                      height: 131,
                      child: Image.memory(
                        base64Decode(person2[i].avatar),
                      ))),
              Container(
                  padding: EdgeInsets.all(5),
                  width: 220,
                  child: Column(
                    children: [
                      Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "${person2[i].nama_depan} ${person2[i].nama_belakang} - ${person2[i].jabatan} \n${person2[i].nama_cabang}",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )),
                      Align(
                          alignment: Alignment.topLeft,
                          child: Text(person2[i].username)),
                      Row(children: [
                        Icon(Icons.mail),
                        Text(person2[i].email, textAlign: TextAlign.left)
                      ]),
                      Row(children: [
                        Icon(Icons.phone),
                        Text(person2[i].no_telp, textAlign: TextAlign.left)
                      ]),
                      Align(
                          alignment: Alignment.bottomLeft,
                          child: Text("Group : " + person2[i].nama_grup,
                              textAlign: TextAlign.left)),
                    ],
                  )),
            ]),
          ],
        ));
        temp.add(w);
      }
    }
    return temp;
  }

  @override
  Widget build(BuildContext context) {
    if (id_jabatan == "1") {
      return Scaffold(
          appBar: AppBar(
            title: Text("Personnel Data"),
          ),
          drawer: MyDrawer(),
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
                                Navigator.popAndPushNamed(
                                    context, "tambahstaff");
                              },
                              child: Text(
                                "Add New Personnel",
                                style: TextStyle(
                                    color: Colors.black, fontSize: 16),
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
                                setState(() {
                                  _txtcari = value;
                                });
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
                                  childAspectRatio: (800 /
                                      (MediaQuery.of(context).size.height /
                                          2.63)),
                                  mainAxisSpacing: 8.0,
                                  children: listPersonel(
                                      context, snapshot.data.toString()));
                            } else {
                              return Center(child: CircularProgressIndicator());
                            }
                          }))
                ],
              ),
            ),
          ));
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text("Personnel Data"),
          leading: BackButton(
            onPressed: () {
              Navigator.popAndPushNamed(context, "homepage");
            },
          ),
        ),
        body: Center(
          child: Text(
            "Anda tidak memiliki akses ke halaman ini \nSilahkan kontak admin",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
  }
}
