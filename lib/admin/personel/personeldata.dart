import 'dart:convert';
import 'package:dynamic_height_grid_view/dynamic_height_grid_view.dart'
    as dynamicGridView;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pt_coronet_crown/admin/personel/detailpersonel.dart';
import 'package:pt_coronet_crown/class/personel/personel.dart';
import 'package:pt_coronet_crown/drawer.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';

class PersonelData extends StatefulWidget {
  int type;
  PersonelData({super.key, required this.type});
  @override
  _PersonelDataState createState() {
    return _PersonelDataState();
  }
}

class _PersonelDataState extends State<PersonelData> {
  String _txtcari = "";
  String id_jabatan = "";
  String _useraneme = "";

  Future<String> fetchData() async {
    final response = await http.post(
        Uri.parse(
            "https://otccoronet.com/otc/admin/personel/personeldata/daftarpersoneldata.php"),
        body: {"cari": _txtcari, "username": username});
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to read API');
    }
  }

  void deletePersonel(String username) async {
    final response = await http.post(
        Uri.parse(
            "https://otccoronet.com/otc/admin/personel/personeldata/deletepersonel.php"),
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
      username = prefs.getString("username") ?? '';
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadData();
  }

  Widget buildPersonelComponent(data) {
    return Card(
        elevation: 5,
        child: Stack(children: [
          Align(
            alignment: Alignment.topRight,
            child: Column(
              children: [
                Tooltip(
                  message: 'Aktivitas Harian',
                  child: IconButton(
                    icon: Icon(Icons.zoom_in),
                    onPressed: () {},
                  ),
                ),
                Tooltip(
                  message: 'Edit data personnel',
                  child: IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {},
                  ),
                ),
                Tooltip(
                  message: 'Hapus Personnel',
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
                                  "Dengan menekan tombol iya, \nAnda akan menghapus data user: ${data.username}"),
                              actions: [
                                TextButton(
                                  child: Text("Cancel"),
                                  onPressed: () => Navigator.pop(context),
                                ),
                                TextButton(
                                  child: Text("Iya"),
                                  onPressed: () =>
                                      deletePersonel(data.username),
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
            Container(
                alignment: Alignment.topLeft,
                margin: EdgeInsets.only(top: 5, left: 5, bottom: 5, right: 10),
                // child: ClipRRect(borderRadius: BorderRadius.circular(8), child: ,),
                decoration: BoxDecoration(
                  border: Border.all(width: 2, color: Colors.orange),
                ),
                width: 100,
                height: 130,
                child: Image(
                  image: MemoryImage(base64Decode(data.avatar)),
                  alignment: Alignment.center,
                  height: double.infinity,
                  width: double.infinity,
                  fit: BoxFit.fill,
                )
                // child:  Image.memory(
                //   base64Decode(person2[index].avatar),
                //   // fit: BoxFit.fill,
                // )
                ),
            Container(
                padding: EdgeInsets.all(5),
                width: 220,
                child: Column(children: [
                  Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "${data.nama_depan} ${data.nama_belakang} - ${data.jabatan} \n${data.nama_cabang}",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )),
                  Align(
                      alignment: Alignment.topLeft, child: Text(data.username)),
                  Row(children: [
                    Icon(Icons.mail, size: 20),
                    Text(" ${data.email}",
                        textAlign: TextAlign.left,
                        style: TextStyle(fontSize: 12))
                  ]),
                  Row(children: [
                    Icon(Icons.phone, size: 16),
                    Text(" ${data.no_telp}",
                        textAlign: TextAlign.left,
                        style: TextStyle(fontSize: 12))
                  ]),
                  Align(
                      alignment: Alignment.bottomLeft,
                      child: Text("Group : ${data.nama_grup}",
                          textAlign: TextAlign.left,
                          style: TextStyle(fontSize: 12))),
                ]))
          ])
        ]));
  }

  Widget listPersonel(data) {
    List<Person> person2 = [];
    Map json = jsonDecode(data);
    if (json['result'] == "error") {
      return Container();
    } else {
      for (var pers in json['data']) {
        Person person = Person.fromJson(pers);
        person2.add(person);
      }
      if (MediaQuery.of(context).size.width >= 800) {
        return dynamicGridView.DynamicHeightGridView(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            crossAxisSpacing: 4,
            itemCount: person2.length,
            builder: (context, index) {
              return buildPersonelComponent(person2[index]);
            });
      } else {
        return ListView.builder(
            itemCount: person2.length,
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            padding: EdgeInsets.only(left: 5, right: 5),
            itemBuilder: (BuildContext ctxt, int index) {
              return buildPersonelComponent(person2[index]);
            });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.popAndPushNamed(context, "/tambahstaff"),
          child: Tooltip(
              message: "Tambah Personalia",
              child: Icon(
                Icons.add,
                color: Colors.white,
              )),
        ),
        // appBar: AppBar(
        //   title: Text("Personnel Data"),
        // ),
        // drawer: MyDrawer(),
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
                    width: 300,
                    child: Row(
                      children: [
                        Container(
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
                        ))
                      ],
                    )),
                Container(
                    alignment: Alignment.topCenter,
                    padding: EdgeInsets.only(left: 5, right: 5),
                    height: MediaQuery.of(context).size.height,
                    child: FutureBuilder(
                        future: fetchData(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            //return Container();
                            return listPersonel(snapshot.data.toString());
                          } else {
                            return Center(child: CircularProgressIndicator());
                          }
                        }))
              ],
            ),
          ),
        ));
  }
}
