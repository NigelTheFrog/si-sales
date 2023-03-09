import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pt_coronet_crown/class/transaksi/pembelian.dart';

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

  Widget tampilData(BuildContext context) {
    if (_pembelian == null) {
      return const CircularProgressIndicator();
    } else {
      return Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          alignment: Alignment.topLeft,
          padding: EdgeInsets.only(top: 20),
          child: Row(children: [
            Container(
              height: 600,
              width: 700,
              padding: EdgeInsets.only(left: 10),
              child: Image.memory(base64Decode(_pembelian!.foto)),
            ),
            Container(
                height: MediaQuery.of(context).size.height,
                width: 500,
                child: Column(children: [
                  ListView.builder(
                      shrinkWrap: true,
                      itemCount: _pembelian?.produk?.length,
                      itemBuilder: (BuildContext ctxt, int index) {
                        return Text(_pembelian?.produk?[index]['jenis']);
                      })
                ]))
          ]));
      // child: Row(
      //   children: [
      //     Container(
      //       height: 600,
      //       width: 700,
      //       padding: EdgeInsets.only(left: 10),
      //       child: Image.memory(base64Decode(_pembelian!.foto)),
      //     ),
      //     Container(
      //         child: Column(
      //       children: <Widget>[
      //         Text("ID Laporan: ${widget.laporan_id}",
      //             style:
      //                 TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      //             textAlign: TextAlign.left),
      //         Text(
      //           "Tanggal: ${_pembelian!.tanggal} \n",
      //           textAlign: TextAlign.left,
      //         ),
      //         Padding(
      //             padding: const EdgeInsets.all(10),
      //             child: ListView.builder(
      //                 shrinkWrap: true,
      //                 itemCount: _pembelian?.produk?.length,
      //                 itemBuilder: (BuildContext ctxt, int index) {
      //                   return Text(
      //                       _pembelian?.produk?[index]['genre_name']);
      //                 })),
      //         Text(
      //           "Total barang: ${_pembelian?.jumlah_barang}",
      //           textAlign: TextAlign.left,
      //         ),
      //         Text(
      //           "Biaya total: Rp. ${NumberFormat('###,000').format(_pembelian?.total_pembelian)}",
      //           textAlign: TextAlign.left,
      //         ),
      //       ],
      //     ))
      //   ],
      // ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Detail Pembelian"),
        ),
        body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            alignment: Alignment.topLeft,
            child: tampilData(context)));
    //ListView(children: [tampilData()])));
  }
}
