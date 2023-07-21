import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:pt_coronet_crown/class/transaksi/penjualan.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  TextEditingController textcontroller = TextEditingController();

  String date = "",
      diskon = "0",
      ppn = "0",
      _id_outlet = "",
      controllerOutlet = "",
      id_jabatan = "";
  List _outlet = [];

  _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    id_jabatan = prefs.getString("idJabatan") ?? '';
  }

  Future<String> fetchData() async {
    final response = await http.post(
        Uri.parse(
            "https://otccoronet.com/otc/laporan/penjualan/detailpenjualan.php"),
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
            "https://otccoronet.com/otc/laporan/penjualan/ubahlaporan.php"),
        body: {
          'id': widget.laporan_id,
          'type': type.toString(),
          'tanggal': date,
          'diskon': diskon,
          'ppn': ppn,
          'id_outlet': _id_outlet
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
                builder: (context) => DetailPenjualan(
                      laporan_id: widget.laporan_id,
                    )));
      }
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
    _loadData();
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
                          labelText: "Tanggal Penjualan",
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
                            labelText: "Daftar Outlet",
                          ),
                          mode: Mode.MENU,
                          showSearchBox: true,
                          onFind: (text) async {
                            Map json;
                            var response = await http.post(
                                Uri.parse(
                                    "https://otccoronet.com/otc/outlet/daftaroutlet.php"),
                                body: {'cari': text});

                            if (response.statusCode == 200) {
                              json = jsonDecode(response.body);
                              setState(() {
                                _outlet = json['data'];
                              });
                            }
                            return _outlet as List<dynamic>;
                          },
                          onChanged: (value) {
                            setState(() {
                              _id_outlet = value['id'];
                            });
                          },
                          itemAsString: (item) => item['nama_toko'],
                        ),
                      ),
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
                    update(context, type);
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          );
        });
  }

  Widget showDataColumn(BuildContext context) {
    return Container(
        alignment: Alignment.topCenter,
        height: MediaQuery.of(context).size.height,
        width: 500,
        padding: kIsWeb
            ? EdgeInsets.only(left: 20)
            : EdgeInsets.only(left: 0, top: 10),
        child: Column(children: [
          Text("ID Laporan: ${_penjualan!.id}",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text(
                  "Penjual: ${_penjualan!.nama_depan}  ${_penjualan!.nama_belakang}",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Tanggal: ${_penjualan!.tanggal}",
                textAlign: TextAlign.center,
              ),
              Tooltip(
                message: "",
                child: IconButton(
                  onPressed: () {
                    updateDialog(context, 1);
                    setState(() {
                      textcontroller.text = _penjualan!.tanggal;
                    });
                  },
                  icon: Icon(Icons.edit),
                ),
              )
            ],
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
                        rows: _penjualan!.produk!
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
                "\n\nTotal jumlah barang: ${_penjualan!.jumlah_barang}",
                textAlign: TextAlign.left,
              )),
          Container(
              padding: EdgeInsets.only(top: 5, bottom: 10),
              alignment: Alignment.topRight,
              child: Text(
                  "\nSubtotal Pembelian: Rp. ${NumberFormat('###,000').format(_penjualan!.total_penjualan)}",
                  textAlign: TextAlign.left)),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Tooltip(
                message: "Ubah Diskon",
                child: IconButton(
                  onPressed: () {
                    updateDialog(context, 2);
                    setState(() {
                      textcontroller.text = _penjualan!.diskon.toString();
                    });
                  },
                  icon: Icon(Icons.edit),
                ),
              ),
              Text(
                  "Diskon: Rp.  ${NumberFormat('###,000').format(_penjualan!.diskon)}"),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Tooltip(
                  message: "Ubah pajak",
                  child: IconButton(
                    onPressed: () {
                      updateDialog(context, 3);
                      setState(() {
                        textcontroller.text = _penjualan!.ppn.toString();
                      });
                    },
                    icon: Icon(Icons.edit),
                  )),
              Text("Pajak: ${_penjualan!.ppn}%"),
            ],
          ),
          Align(
              alignment: Alignment.topRight,
              child: Text(
                  "\nTotal Penjualan: Rp. ${NumberFormat('###,000').format((_penjualan!.total_penjualan - _penjualan!.diskon) + (((_penjualan!.total_penjualan - _penjualan!.diskon) * (_penjualan!.ppn / 100.00))))}",
                  textAlign: TextAlign.left)),
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Outlet: ${_penjualan!.nama_toko}",
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Tooltip(
                  message: "",
                  child: IconButton(
                    onPressed: () {
                      updateDialog(context, 4);
                      setState(() {
                        controllerOutlet = _penjualan!.nama_toko;
                      });
                    },
                    icon: Icon(Icons.edit),
                  ),
                )
              ],
            ),
          ),
          Flexible(
              child: Text(_penjualan!.alamat,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)))
        ]));
  }

  Widget showPicture() {
    if (kIsWeb) {
      return Container(
        width: 500,
        height: 600,
        alignment: _penjualan!.foto == null || _penjualan!.foto == ""
            ? Alignment.center
            : Alignment.topCenter,
        child: _penjualan!.foto == null || _penjualan!.foto == ""
            ? Text("Penjualan ini tidak memakai nota")
            : Image.memory(base64Decode(_penjualan!.foto as String)),
      );
    } else {
      return FittedBox(
        alignment: _penjualan!.foto == null || _penjualan!.foto == ""
            ? Alignment.center
            : Alignment.topCenter,
        child: _penjualan!.foto == null || _penjualan!.foto == ""
            ? Text("Penjualan ini tidak memakai nota")
            : Image.memory(base64Decode(_penjualan!.foto as String)),
      );
    }
  }

  Widget tampilData(BuildContext context) {
    return SingleChildScrollView(
        scrollDirection: kIsWeb
            ? MediaQuery.of(context).size.width >= 1040
                ? Axis.vertical
                : Axis.horizontal
            : Axis.vertical,
        child: Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(20),
            child: kIsWeb
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [showPicture(), showDataColumn(context)])
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [showPicture(), showDataColumn(context)])));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Detail Penjualan"),
          leading: BackButton(
            onPressed: () {
              if (id_jabatan == "1" || id_jabatan == "2") {
                Navigator.popAndPushNamed(context, "/daftarpenjualan");
              } else {
                Navigator.pop(context);
              }
            },
          ),
        ),
        body: _penjualan == null
            ? Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                alignment: Alignment.center,
                child: const CircularProgressIndicator(),
              )
            : Container(
                width: MediaQuery.of(context).size.width,
                alignment: Alignment.topCenter,
                child: tampilData(context)));

    //ListView(children: [tampilData()])));
  }
}
