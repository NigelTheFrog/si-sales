import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:pt_coronet_crown/class/transaksi/penjualan.dart';

class DetailPenjualan extends StatefulWidget {
  String laporan_id;
  DetailPenjualan({super.key, required this.laporan_id});
  @override
  _DetailPenjualanState createState() {
    return _DetailPenjualanState();
  }
}

class _DetailPenjualanState extends State<DetailPenjualan> {
  Penjualan? _penjualan;

  Future<String> fetchData() async {
    final response = await http.post(
        Uri.parse(
            "http://localhost/magang/laporan/penjualan/detailpenjualan.php"),
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
      _penjualan = Penjualan.fromJson(json['data']);
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
                ? Row(children: [
                    Container(
                      width: 500,
                      height: 600,
                      alignment: _penjualan!.foto == null || _penjualan!.foto == "" ? Alignment.center : Alignment.topCenter,
                      child: _penjualan!.foto == null || _penjualan!.foto == ""
                          ? Text("Penjualan ini tidak memakai nota")
                          : Image.memory(
                              base64Decode(_penjualan!.foto as String)),
                    ),
                    Container(
                        alignment: Alignment.topCenter,
                        height: MediaQuery.of(context).size.height,
                        width: 500,
                        padding: EdgeInsets.only(left: 20),
                        child: Column(children: [
                          Text("ID Laporan: ${_penjualan!.id}",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(
                              "Penjual: ${_penjualan!.nama_depan}  ${_penjualan!.nama_belakang}", textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold)),
                          Container(
                            padding: EdgeInsets.only(top: 10),
                            alignment: Alignment.topCenter,
                            width: 500,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Tanggal: ${_penjualan!.tanggal}",
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
                            width: 500,
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
                                                  textAlign:
                                                      TextAlign.center))),
                                      DataColumn(
                                          label: Expanded(
                                              child: Text("Harga \nSatuan",
                                                  textAlign:
                                                      TextAlign.center))),
                                      DataColumn(
                                          label: Expanded(
                                              child: Text("Harga \nTotal",
                                                  textAlign:
                                                      TextAlign.center))),
                                    ],
                                    rows: _penjualan!.produk!
                                        .map<DataRow>((element) =>
                                            DataRow(cells: [
                                              DataCell(Align(
                                                  alignment: Alignment.center,
                                                  child: Text(element['jenis'],
                                                      textAlign:
                                                          TextAlign.center))),
                                              DataCell(Align(
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                      element['quantity']
                                                          .toString(),
                                                      textAlign:
                                                          TextAlign.center))),
                                              DataCell(Align(
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                      "Rp. ${NumberFormat('###,000').format(element['harga'])}",
                                                      style: TextStyle(
                                                          fontSize: 13),
                                                      textAlign:
                                                          TextAlign.center))),
                                              DataCell(Align(
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                      "Rp. ${NumberFormat('###,000').format(element['total_harga'])}",
                                                      style: TextStyle(
                                                          fontSize: 13),
                                                      textAlign:
                                                          TextAlign.center))),
                                            ]))
                                        .toList());
                              }),
                          Align(
                              alignment: Alignment.topRight,
                              child: Text(
                                "\n\nTotal jumlah barang: ${_penjualan!.jumlah_barang}",
                                textAlign: TextAlign.left,
                              )),
                          Container(
                              padding: EdgeInsets.only(top: 5, bottom: 10),
                              alignment: Alignment.topRight,
                              child: Text(
                                  "\nSubtotal Pembelian: Rp. ${NumberFormat('###,000').format(_penjualan!.total_penjualan)}",
                                  textAlign: TextAlign.left)),
                          Container(
                            alignment: Alignment.topRight,
                            padding: EdgeInsets.only(top: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Tooltip(
                                  message: "Ubah Diskon",
                                  child: IconButton(
                                    onPressed: () {},
                                    icon: Icon(Icons.edit),
                                  ),
                                ),
                                Text(
                                    "Diskon: Rp.  ${NumberFormat('###,000').format(_penjualan!.diskon)}"),
                              ],
                            ),
                          ),
                          Container(
                            alignment: Alignment.topRight,
                            padding: EdgeInsets.only(top: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Tooltip(
                                    message: "Ubah pajak",
                                    child: IconButton(
                                      onPressed: () {},
                                      icon: Icon(Icons.edit),
                                    )),
                                Text("Pajak: ${_penjualan!.ppn}%"),
                              ],
                            ),
                          ),
                          Align(
                              alignment: Alignment.topRight,
                              child: Text(
                                  "\nTotal Pembelian: Rp. ${NumberFormat('###,000').format((_penjualan!.total_penjualan - _penjualan!.diskon) + (((_penjualan!.total_penjualan - _penjualan!.diskon) * (_penjualan!.ppn / 100.00))))}",
                                  textAlign: TextAlign.left)),
                          Container(
                            padding: EdgeInsets.only(top: 10),
                            alignment: Alignment.topCenter,
                            width: 500,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("OUTLET: ${_penjualan!.nama_toko}",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                                Tooltip(
                                  message: "Ubah Outlet",
                                  child: IconButton(
                                    onPressed: () {},
                                    icon: Icon(Icons.edit),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Text(
                            _penjualan!.alamat,
                            style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center,
                          )
                        ]))
                  ])
                : Column(children: [
                    Container(
                      alignment: Alignment.topCenter,
                      child: Image.memory(
                          base64Decode(_penjualan!.foto as String)),
                    ),
                    Text("ID Laporan: ${_penjualan!.id}",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Container(
                      padding: EdgeInsets.only(top: 10),
                      alignment: Alignment.topCenter,
                      width: 231,
                      child: Row(
                        children: [
                          Text(
                            "Tanggal: ${_penjualan!.tanggal}",
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
                    Container(
                      alignment: Alignment.topCenter,
                      height: MediaQuery.of(context).size.height,
                      width: 500,
                      child: ListView.builder(
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
                                rows: _penjualan!.produk!
                                    .map<DataRow>((element) => DataRow(cells: [
                                          DataCell(Align(
                                              alignment: Alignment.center,
                                              child: Text(element['jenis'],
                                                  textAlign:
                                                      TextAlign.center))),
                                          DataCell(Align(
                                              alignment: Alignment.center,
                                              child: Text(
                                                  element['quantity']
                                                      .toString(),
                                                  textAlign:
                                                      TextAlign.center))),
                                          DataCell(Align(
                                              alignment: Alignment.center,
                                              child: Text(
                                                  "Rp. ${NumberFormat('###,000').format(element['harga'])}",
                                                  textAlign:
                                                      TextAlign.center))),
                                          DataCell(Align(
                                              alignment: Alignment.center,
                                              child: Text(
                                                  "Rp. ${NumberFormat('###,000').format(element['total'])}",
                                                  textAlign:
                                                      TextAlign.center))),
                                        ]))
                                    .toList());
                          }),
                    ),
                    Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "\n\nTotal jumlah barang: ${_penjualan!.jumlah_barang}",
                          textAlign: TextAlign.left,
                        )),
                    Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                            "\nTotal Harga: Rp. ${NumberFormat('###,000').format(_penjualan!.total_penjualan)}",
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.left)),
                    Container(
                        padding: EdgeInsets.only(top: 10),
                        child: Row(
                          children: [
                            Text(
                                "Diskon: Rp.  ${NumberFormat('###,000').format(10000)}"),
                            Tooltip(
                              message: "Ubah Diskon",
                              child: IconButton(
                                onPressed: () {},
                                icon: Icon(Icons.edit),
                              ),
                            )
                          ],
                        )),
                    Row(
                      children: [
                        Text("Pajak: 10%"),
                        Tooltip(
                          message: "Ubah pajak",
                          child: IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.edit),
                          ),
                        )
                      ],
                    ),
                    Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                            "\nTotal Pembelian: Rp. ${NumberFormat('###,000').format((_penjualan!.total_penjualan - _penjualan!.diskon) + (((_penjualan!.total_penjualan - _penjualan!.diskon) * (_penjualan!.ppn / 100.00))))}}",
                            textAlign: TextAlign.left)),
                    Container(
                      padding: EdgeInsets.only(top: 10),
                      alignment: Alignment.topCenter,
                      width: 300,
                      child: Row(
                        children: [
                          Text("SUPPLIER: PT. CORONET CROWN ",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
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
                  ])));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Detail Penjualan"),
        ),
        body: _penjualan == null
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
