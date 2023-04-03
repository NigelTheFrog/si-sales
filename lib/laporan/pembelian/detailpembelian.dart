import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pt_coronet_crown/class/transaksi/pembelian.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

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

  Future<String> fetchData() async {
    final response = await http.post(
        Uri.parse(
            "http://localhost/magang/laporan/pembelian/detailpembelian.php"),
        body: {'id': widget.laporan_id});
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to read API');
    }
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
    return Container(
      width: 500,
      height: 600,
      alignment: Alignment.topCenter,
      child: Image.memory(base64Decode(_pembelian!.foto)),
    );
  }

  Widget showColumnData(BuildContext context) {
    return Container(
        alignment: Alignment.topCenter,
        height: MediaQuery.of(context).size.height,
        width: 500,
        padding: EdgeInsets.only(left: 20),
        child: Column(children: [
          Text("ID Laporan: ${_pembelian!.id}",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Container(
            padding: EdgeInsets.only(top: 10),
            alignment: Alignment.topCenter,
            width: 231,
            child: Row(
              children: [
                Text(
                  "Tanggal: ${_pembelian!.tanggal}",
                  textAlign: TextAlign.center,
                ),
                Tooltip(
                  message: "",
                  child: IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.edit),
                  ),
                )
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 10),
            alignment: Alignment.topCenter,
            width: 174,
            child: Row(
              children: [
                Text("RINCIAN BARANG ",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                    )),
                Tooltip(
                  message: "Ubah rincian barang",
                  child: IconButton(
                    onPressed: () {},
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
                return DataTable(
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
                                  child: Text(element['quantity'].toString(),
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
                        .toList());
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
          Container(
            alignment: Alignment.topRight,
            padding: EdgeInsets.only(top: 10),
            child: Container(
              width: 158,
              child: Row(
                children: [
                  Tooltip(
                    message: "Ubah Diskon",
                    child: IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.edit),
                    ),
                  ),
                  Text(
                      "Diskon: Rp.  ${NumberFormat('###,000').format(_pembelian!.diskon)}"),
                ],
              ),
            ),
          ),
          Container(
            alignment: Alignment.topRight,
            padding: EdgeInsets.only(top: 10),
            child: Container(
              width: 106,
              child: Row(
                children: [
                  Tooltip(
                      message: "Ubah pajak",
                      child: IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.edit),
                      )),
                  Text("Pajak: ${_pembelian!.ppn}%"),
                ],
              ),
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
                    onPressed: () {},
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
        scrollDirection: kIsWeb
            ? MediaQuery.of(context).size.width >= 1040
                ? Axis.vertical
                : Axis.horizontal
            : Axis.vertical,
        child: Container(
            height: MediaQuery.of(context).size.height,
            width: 1050,
            alignment: Alignment.topLeft,
            padding: EdgeInsets.all(20),
            child: kIsWeb
                ? Row(children: [showPicture(), showColumnData(context)])
                : Column(children: [showPicture(), showColumnData(context)])));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Detail Pembelian"),
        ),
        body: _pembelian == null
            ? Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                alignment: Alignment.center,
                child: const CircularProgressIndicator(),
              )
            : Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                alignment: Alignment.topLeft,
                child: tampilData(context)));
    //ListView(children: [tampilData()])));
  }
}
