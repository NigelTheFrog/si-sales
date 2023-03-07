import 'package:flutter/material.dart';

class DetailPembelian extends StatefulWidget {
  String laporan_id, tanggal, waktu, foto_nota;
  DetailPembelian(
      {super.key,
      required this.laporan_id,
      required this.tanggal,
      required this.waktu,
      required this.foto_nota});
  @override
  _DetailPembelianState createState() {
    return _DetailPembelianState();
  }
}

class _DetailPembelianState extends State<DetailPembelian> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Detail Pembelian"),
        ),
        body: Container(
          alignment: Alignment.center,
          child: Row(
            children: [
              Align(
                  alignment: Alignment.topLeft, child: Text(widget.laporan_id)),
              Align(
                  alignment: Alignment.topLeft, child: Text(widget.laporan_id)),
            ],
          ),
        ));
  }
}
