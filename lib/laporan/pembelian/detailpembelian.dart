import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pt_coronet_crown/class/transaksi/pembelian.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dropdown_search/dropdown_search.dart';
import 'package:pt_coronet_crown/laporan/pembelian/detailprodukpembelian.dart';

class DetailPembelian extends StatefulWidget {
  String laporan_id;
  DetailPembelian({super.key, required this.laporan_id});
  @override
  _DetailPembelianState createState() {
    return _DetailPembelianState();
  }
}

class _DetailPembelianState extends State<DetailPembelian> {
  Pembelian? _pembelian;
  TextEditingController textcontroller = TextEditingController();
  String date = "",
      diskon = "0",
      ppn = "0",
      _id_supplier = "",
      controllerSupplier = "";
  List _supplier = [];

  Future<String> fetchData() async {
    final response = await http.post(
        Uri.parse(
            "http://192.168.137.1/magang/laporan/pembelian/detailpembelian.php"),
        body: {'id': widget.laporan_id});
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to read API');
    }
  }

  void update(BuildContext context, type) async {
    final response = await http.post(
        Uri.parse(
            "http://192.168.137.1/magang/laporan/pembelian/ubahlaporan.php"),
        body: {
          'id': widget.laporan_id,
          'type': type.toString(),
          'tanggal': date,
          'diskon': diskon,
          'ppn': ppn,
          'id_supplier': _id_supplier
        });
    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      if (json['result'] == 'success') {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Sukses Mengubah Data')));
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DetailPembelian(
                      laporan_id: widget.laporan_id,
                    )));
      }
    } else {
      throw Exception('Failed to read API');
    }
  }

  updateDialog(BuildContext context, type) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: type == 1
                ? Text('Mengganti Tanggal Nota')
                : type == 2
                    ? Text('Mengganti Jumlah Diskon')
                    : type == 3
                        ? Text('Mengganti Jumlah Pajak (dalam %)')
                        : Text("Mengganti Supplier"),
            content: type == 1
                ? SizedBox(
                    height: 50,
                    width: 300,
                    child: Row(children: [
                      Expanded(
                          child: TextFormField(
                        decoration: InputDecoration(
                          labelText: "Tanggal Pembelian",
                        ),
                        controller: textcontroller,
                      )),
                      ElevatedButton(
                          onPressed: () {
                            showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2200))
                                .then((value) {
                              date = value.toString().substring(0, 10);
                              String formattedDate =
                                  DateFormat.yMMMMEEEEd('id').format(value!);
                              textcontroller.text = formattedDate;
                            });
                          },
                          child: Icon(
                            Icons.calendar_today_sharp,
                            color: Colors.white,
                            size: 24.0,
                          ))
                    ]),
                  )
                : type == 2 || type == 3
                    ? TextField(
                        controller: textcontroller,
                        onChanged: (value) {
                          if (type == 2) {
                            diskon = value;
                          } else {
                            ppn = value;
                          }
                          // nama_produk = value;
                        },
                        decoration: type == 2
                            ? const InputDecoration(
                                hintText: "Isikan jumlah diskon")
                            : const InputDecoration(
                                hintText: "Isikan jumlah ppn"),
                      )
                    : Container(
                        height: 55,
                        alignment: Alignment.center,
                        child: DropdownSearch<dynamic>(
                          dropdownSearchDecoration: InputDecoration(
                            labelText: "Daftar Supplier",
                          ),
                          mode: Mode.MENU,
                          showSearchBox: true,
                          onFind: (text) async {
                            Map json;
                            var response = await http.post(
                                Uri.parse(
                                    "http://192.168.137.1/magang/supplier/daftarsupplier.php"),
                                body: {'cari': text});

                            if (response.statusCode == 200) {
                              json = jsonDecode(response.body);
                              setState(() {
                                _supplier = json['data'];
                              });
                            }
                            return _supplier as List<dynamic>;
                          },
                          onChanged: (value) {
                            setState(() {
                              _id_supplier = value['id'];
                            });
                          },
                          itemAsString: (item) => item['nama_supplier'],
                        ),
                      ),
            actions: <Widget>[
              TextButton(
                child: const Text('CANCEL'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                    // nama_produk = "";
                  });
                },
              ),
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  setState(() {
                    update(context, type);
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          );
        });
  }

  bacaData() {
    fetchData().then((value) {
      Map json = jsonDecode(value);
      _pembelian = Pembelian.fromJson(json['data']);
      setState(() {});
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    bacaData();
  }

  Widget showPicture() {
    if (kIsWeb) {
      return Container(
      width: 500,
      height: 600,
      alignment: Alignment.topCenter,
      child: Image.memory(base64Decode(_pembelian!.foto)),
    );
    } else {
      return FittedBox(
        alignment: Alignment.topCenter,
        child: Image.memory(base64Decode(_pembelian!.foto)),
      );
    }
  }

  Widget showColumnData(BuildContext context) {
    return Container(
        alignment: Alignment.topCenter,
        height: MediaQuery.of(context).size.height,
        width: 500,
        padding: kIsWeb? EdgeInsets.only(left: 20): EdgeInsets.only(left: 0, top: 10),
        child: Column(children: [
          Text("ID Laporan: ${_pembelian!.id}",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Tanggal: ${_pembelian!.tanggal}",
                  textAlign: TextAlign.center,
                ),
                Tooltip(
                  message: "",
                  child: IconButton(
                    onPressed: () {
                      updateDialog(context, 1);
                      setState(() {
                        textcontroller.text = _pembelian!.tanggal;
                      });
                    },
                    icon: Icon(Icons.edit),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("RINCIAN BARANG ",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                    )),
                Tooltip(
                  message: "Ubah rincian barang",
                  child: IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DaftarProdukPembelian(
                                    laporan_id: widget.laporan_id,
                                  )));
                    },
                    icon: Icon(Icons.edit),
                  ),
                )
              ],
            ),
          ),
          ListView.builder(
              shrinkWrap: true,
              itemCount: 1,
              itemBuilder: (BuildContext ctxt, int index) {
                return FittedBox(
                    child: DataTable(
                        columns: [
                      DataColumn(
                          label: Expanded(
                              child: Text(
                        "Jenis \nProduk",
                        textAlign: TextAlign.center,
                      ))),
                      DataColumn(
                          label: Expanded(
                              child: Text("Kuantitas",
                                  textAlign: TextAlign.center))),
                      DataColumn(
                          label: Expanded(
                              child: Text("Harga \nSatuan",
                                  textAlign: TextAlign.center))),
                      DataColumn(
                          label: Expanded(
                              child: Text("Harga \nTotal",
                                  textAlign: TextAlign.center))),
                    ],
                        rows: _pembelian!.produk!
                            .map<DataRow>((element) => DataRow(cells: [
                                  DataCell(Align(
                                      alignment: Alignment.center,
                                      child: Text(element['jenis'],
                                          textAlign: TextAlign.center))),
                                  DataCell(Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                          element['quantity'].toString(),
                                          textAlign: TextAlign.center))),
                                  DataCell(Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                          "Rp. ${NumberFormat('###,000').format(element['harga'])}",
                                          style: TextStyle(fontSize: 13),
                                          textAlign: TextAlign.center))),
                                  DataCell(Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                          "Rp. ${NumberFormat('###,000').format(element['total_harga'])}",
                                          style: TextStyle(fontSize: 13),
                                          textAlign: TextAlign.center))),
                                ]))
                            .toList()));
              }),
          Align(
              alignment: Alignment.topRight,
              child: Text(
                "\n\nTotal jumlah barang: ${_pembelian!.jumlah_barang}",
                textAlign: TextAlign.left,
              )),
          Container(
              padding: EdgeInsets.only(top: 5, bottom: 10),
              alignment: Alignment.topRight,
              child: Text(
                  "\nSubtotal Pembelian: Rp. ${NumberFormat('###,000').format(_pembelian!.total_pembelian)}",
                  textAlign: TextAlign.left)),
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Tooltip(
                  message: "Ubah Diskon",
                  child: IconButton(
                    onPressed: () {
                      updateDialog(context, 2);
                      setState(() {
                        textcontroller.text = _pembelian!.diskon.toString();
                      });
                    },
                    icon: Icon(Icons.edit),
                  ),
                ),
                Text(
                    "Diskon: Rp.  ${NumberFormat('###,000').format(_pembelian!.diskon)}"),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Tooltip(
                    message: "Ubah pajak",
                    child: IconButton(
                      onPressed: () {
                        updateDialog(context, 3);
                        setState(() {
                          textcontroller.text = _pembelian!.ppn.toString();
                        });
                      },
                      icon: Icon(Icons.edit),
                    )),
                Text("Pajak: ${_pembelian!.ppn}%"),
              ],
            ),
          ),
          Align(
              alignment: Alignment.topRight,
              child: Text(
                  "\nTotal Pembelian: Rp. ${NumberFormat('###,000').format((_pembelian!.total_pembelian - _pembelian!.diskon) + (((_pembelian!.total_pembelian - _pembelian!.diskon) * (_pembelian!.ppn / 100.00))))}",
                  textAlign: TextAlign.left)),
          Container(
            padding: EdgeInsets.only(top: 10),
            alignment: Alignment.topCenter,
            width: 300,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("SUPPLIER: ${_pembelian!.nama_supplier}",
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Tooltip(
                  message: "",
                  child: IconButton(
                    onPressed: () {
                      updateDialog(context, 4);
                      setState(() {
                        controllerSupplier = _pembelian!.nama_supplier;
                      });
                    },
                    icon: Icon(Icons.edit),
                  ),
                )
              ],
            ),
          )
        ]));
  }

  Widget tampilData(BuildContext context) {
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
            width: MediaQuery.of(context).size.width,
            alignment: Alignment.topLeft,
            padding: EdgeInsets.all(20),
            child: kIsWeb
                ? Row(mainAxisAlignment: MainAxisAlignment.start,children: [showPicture(), showColumnData(context)])
                : Column(children: [showPicture(), showColumnData(context)])));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Detail Pembelian"),
          leading: BackButton(
            onPressed: () {
              Navigator.popAndPushNamed(context, "/daftarpembelian");
            },
          ),
        ),
        body: _pembelian == null
            ? Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                alignment: Alignment.center,
                child: const CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                scrollDirection: kIsWeb
                    ? MediaQuery.of(context).size.width >= 1040
                        ? Axis.vertical
                        : Axis.horizontal
                    : Axis.vertical,
                child: Container(
                    width: MediaQuery.of(context).size.width,
                    alignment: Alignment.topLeft,
                    child: tampilData(context))));
    //ListView(children: [tampilData()])));
  }
}
