import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pt_coronet_crown/class/personel/grup.dart';
import 'package:pt_coronet_crown/class/produk.dart';
import 'package:pt_coronet_crown/drawer.dart';
import 'package:pt_coronet_crown/laporan/pembelian/detailpembelian.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dropdown_search/dropdown_search.dart';

import '../../main.dart';

class DaftarProdukPembelian extends StatefulWidget {
  String laporan_id;
  DaftarProdukPembelian({super.key, required this.laporan_id});
  @override
  _DaftarProdukPembelianState createState() {
    return _DaftarProdukPembelianState();
  }
}

String id_cabang = "";

class _DaftarProdukPembelianState extends State<DaftarProdukPembelian> {
  TextEditingController quantityProduct = TextEditingController();
  TextEditingController hargaProduct = TextEditingController();
  String controllerProduct = "";
  int idProduk = 0, selisih = 0;
  List _produk = [];

  Future<String> fetchData() async {
    final response = await http.post(
        Uri.parse(
            "http://192.168.137.1/magang/laporan/pembelian/daftarprodukpembelian.php"),
        body: {'id': widget.laporan_id});
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to read API');
    }
  }

  void submit(BuildContext context) async {
    final response = await http.post(
        Uri.parse(
            "http://192.168.137.1/magang/laporan/pembelian/tambahprodukpembelian.php"),
        body: {
          'nota_beli_id': widget.laporan_id,
          'id_produk': idProduk.toString(),
          'quantity': quantityProduct.text,
          'harga': hargaProduct.text,
          'id_cabang': id_cabang,
          'selisih': selisih.toString()
        });
    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      if (json['result'] == 'success') {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Sukses Menambah Data')));
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DaftarProdukPembelian(
                      laporan_id: widget.laporan_id,
                    )));
      }
    } else {
      throw Exception('Failed to read API');
    }
  }

  void update(BuildContext context, id) async {
    final response = await http.post(
        Uri.parse(
            "http://192.168.137.1/magang/laporan/pembelian/ubahprodukpembelian.php"),
        body: {'id': id, 'produk': "nama_produk"});
    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      if (json['result'] == 'success') {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Sukses Mengubah Data')));
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DaftarProdukPembelian(
                      laporan_id: widget.laporan_id,
                    )));
      }
    } else {
      throw Exception('Failed to read API');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Widget daftarProduk(data) {
    List produk = [];
    Map json = jsonDecode(data);
    if (json['result'] == "error") {
      return Container(
          child: DataTable(columns: [
        DataColumn(
            label: Expanded(
                child: Text(
          "Jenis",
          textAlign: TextAlign.center,
        ))),
        DataColumn(
            label:
                Expanded(child: Text("Quantity", textAlign: TextAlign.center))),
        DataColumn(
            label: Expanded(child: Text("Harga", textAlign: TextAlign.center))),
        DataColumn(
            label:
                Expanded(child: Text("Action", textAlign: TextAlign.center))),
      ], rows: []));
    } else {
      for (var prod in json['data']) {
        produk.add(prod);
      }
      return ListView.builder(
          scrollDirection: MediaQuery.of(context).size.width >= 725
              ? Axis.vertical
              : Axis.horizontal,
          itemCount: 1,
          itemBuilder: (BuildContext ctxt, int index) {
            return Container(
                child: DataTable(
                    columns: [
                  DataColumn(
                      label: Expanded(
                          child: Text(
                    "Jenis",
                    textAlign: TextAlign.center,
                  ))),
                  DataColumn(
                      label: Expanded(
                          child:
                              Text("Quantity", textAlign: TextAlign.center))),
                  DataColumn(
                      label: Expanded(
                          child: Text("Harga", textAlign: TextAlign.center))),
                  DataColumn(
                      label: Expanded(
                          child: Text("Action", textAlign: TextAlign.center))),
                ],
                    rows: produk
                        .map<DataRow>((element) => DataRow(cells: [
                              DataCell(Align(
                                  alignment: Alignment.center,
                                  child: Text(element['jenis'],
                                      textAlign: TextAlign.center))),
                              DataCell(Align(
                                  alignment: Alignment.center,
                                  child: Text(element['quantity'].toString(),
                                      textAlign: TextAlign.center))),
                              DataCell(Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                      "Rp. ${NumberFormat('###,000').format(element['harga'])}",
                                      textAlign: TextAlign.center))),
                              DataCell(Align(
                                  alignment: Alignment.center,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Tooltip(
                                        message: 'Edit data produk',
                                        child: IconButton(
                                          icon: Icon(Icons.edit),
                                          onPressed: () {
                                            quantityProduct.text =
                                                element['quantity'].toString();
                                            hargaProduct.text =
                                                element['harga'].toString();
                                            showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    title: Text(
                                                        'Mengubah data produk ${element['jenis']}'),
                                                    content: Container(
                                                        height: 140,
                                                        child:
                                                            Column(children: [
                                                          Align(
                                                              alignment: Alignment
                                                                  .centerLeft,
                                                              child: Text(
                                                                "Jumlah produk:",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .black),
                                                                textAlign:
                                                                    TextAlign
                                                                        .left,
                                                              )),
                                                          Container(
                                                              child: TextField(
                                                            controller:
                                                                quantityProduct,
                                                            onChanged: (value) {
                                                              setState(() {
                                                                quantityProduct
                                                                        .text =
                                                                    value;
                                                              });
                                                            },
                                                            decoration:
                                                                const InputDecoration(
                                                                    hintText:
                                                                        "Isikan jumlah produk"),
                                                          )),
                                                          Align(
                                                              alignment: Alignment
                                                                  .centerLeft,
                                                              child: Text(
                                                                "Harga produk (per barang):",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .black),
                                                                textAlign:
                                                                    TextAlign
                                                                        .left,
                                                              )),
                                                          TextField(
                                                            controller:
                                                                hargaProduct,
                                                            onChanged: (value) {
                                                              setState(() {
                                                                hargaProduct
                                                                        .text =
                                                                    value;
                                                              });
                                                            },
                                                            decoration:
                                                                const InputDecoration(
                                                                    hintText:
                                                                        "Isikan harga produk"),
                                                          ),
                                                        ])),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        child: const Text(
                                                            'CANCEL'),
                                                        onPressed: () {
                                                          setState(() {
                                                            Navigator.pop(
                                                                context);
                                                            //nama_produk = "";
                                                          });
                                                        },
                                                      ),
                                                      TextButton(
                                                        child: const Text('OK'),
                                                        onPressed: () {
                                                          setState(() {
                                                            update(
                                                                context,
                                                                element.id
                                                                    .toString());
                                                          });
                                                        },
                                                      ),
                                                    ],
                                                  );
                                                });
                                          },
                                        ),
                                      ),
                                      Tooltip(
                                        message: 'Delete Produk',
                                        child: IconButton(
                                          icon: Icon(Icons.delete),
                                          onPressed: () {
                                            setState(() {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title: Text("Warning!"),
                                                    content: Text(
                                                        "Dengan menekan tombol iya, \nAnda akan menghapus produk: ${element['jenis']} dari daftar pembelian"),
                                                    actions: [
                                                      TextButton(
                                                        child: Text("Cancel"),
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
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
                                            });
                                          },
                                        ),
                                      )
                                    ],
                                  ))),
                            ]))
                        .toList()));
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: BackButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DetailPembelian(
                            laporan_id: widget.laporan_id,
                          )));
            },
          ),
          title: Text("Daftar Produk Pembelian"),
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              quantityProduct.text = "";
              hargaProduct.text = "";
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Menambah Produk pada pembelian'),
                      content: Container(
                          height: 217,
                          child: Column(children: [
                            Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Jenis produk:",
                                  style: TextStyle(color: Colors.black),
                                  textAlign: TextAlign.left,
                                )),
                            Container(
                              height: 55,
                              alignment: Alignment.center,
                              child: DropdownSearch<dynamic>(
                                dropdownSearchDecoration: InputDecoration(
                                  labelText: "Daftar Produk",
                                ),
                                mode: Mode.MENU,
                                showSearchBox: true,
                                onFind: (text) async {
                                  Map json;
                                  var response = await http.post(
                                      Uri.parse(
                                          "http://192.168.137.1/magang/admin/product/daftarproduct.php"),
                                      body: {'cari': text});

                                  if (response.statusCode == 200) {
                                    json = jsonDecode(response.body);
                                    setState(() {
                                      _produk = json['data'];
                                    });
                                  }
                                  return _produk as List<dynamic>;
                                },
                                onChanged: (value) {
                                  setState(() {
                                    idProduk = value['id'];
                                  });
                                },
                                itemAsString: (item) => item['jenis'],
                              ),
                            ),
                            Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Jumlah produk:",
                                  style: TextStyle(color: Colors.black),
                                  textAlign: TextAlign.left,
                                )),
                            Container(
                                child: TextField(
                              controller: quantityProduct,
                              onChanged: (value) {
                                setState(() {
                                  quantityProduct.text = value;
                                });
                              },
                              decoration: const InputDecoration(
                                  hintText: "Isikan jumlah produk"),
                            )),
                            Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Harga produk (per barang):",
                                  style: TextStyle(color: Colors.black),
                                  textAlign: TextAlign.left,
                                )),
                            TextField(
                              controller: hargaProduct,
                              onChanged: (value) {
                                setState(() {
                                  hargaProduct.text = value;
                                });
                              },
                              decoration: const InputDecoration(
                                  hintText: "Isikan harga produk"),
                            ),
                          ])),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('CANCEL'),
                          onPressed: () {
                            setState(() {
                              Navigator.pop(context);
                            });
                          },
                        ),
                        TextButton(
                          child: const Text('OK'),
                          onPressed: () {
                            setState(() {
                              submit(context);
                            });
                          },
                        ),
                      ],
                    );
                  });
            },
            child: Tooltip(
              child: const Icon(Icons.add),
              message: "Tambah produk",
            )),
        body: Container(
          alignment: Alignment.topCenter,
          padding: EdgeInsets.only(top: 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("ID Laporan: ${widget.laporan_id}",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Container(
                    alignment: Alignment.topCenter,
                    height: MediaQuery.of(context).size.height,
                    width: 800,
                    child: FutureBuilder(
                        future: fetchData(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return daftarProduk(snapshot.data.toString());
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
