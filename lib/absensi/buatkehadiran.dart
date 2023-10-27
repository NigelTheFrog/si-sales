import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_face_api/face_api.dart' as Regula;
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:pt_coronet_crown/main.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BuatKehadiran extends StatefulWidget {
  BuatKehadiran({super.key});
  @override
  _BuatKehadiranState createState() => _BuatKehadiranState();
}

class _BuatKehadiranState extends State<BuatKehadiran> {
  var image1 = Regula.MatchFacesImage();
  var image2 = Regula.MatchFacesImage();
  var img1;
  double _similarity = 0;
  int keterangan = 0;
  String tanggal = "", id_jabatan = "";
  bool processing = false;
  bool match = false;
  bool match_process = false;

  TextEditingController controllerTanggal = TextEditingController(),
      controllerJam = TextEditingController(),
      controllerKeterangan = TextEditingController();
  List list = [0, 1, 2];

  @override
  void initState() {
    keterangan = list.first;
    controllerTanggal.text = DateFormat.yMMMMEEEEd('id').format(DateTime.now());
    controllerJam.text = DateFormat.Hm().format(DateTime.now());
    tanggal = DateTime.now().toString().substring(0, 10);
    setImage(false, base64Decode(avatar), 1);
    captureImage();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    main();
    Navigator.popAndPushNamed(context, "/homepage");
  }

  void submit(BuildContext context) async {
    double lintang = 0, bujur = 0;
    Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best,
            forceAndroidLocationManager: true)
        .then((Position position) {
      setState(() {
        lintang = position.latitude;
        bujur = position.longitude;
      });
    });
    final response = await http.post(
        Uri.parse(
            "https://otccoronet.com/otc/account/absensi/buatkehadiran.php"),
        body: {
          'bukti': img1,
          'lintang': lintang.toString(),
          'bujur': bujur.toString(),
          'id_jabatan': idjabatan,
          'keterangan': keterangan == 0
              ? 'Menetap di kantor'
              : keterangan == 1
                  ? 'Keliling'
                  : controllerKeterangan.text,
          "username": username,
          "type": "0"
        });
    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      if (json['result'] == 'success') {
        final prefs = await SharedPreferences.getInstance();
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Kehadiran telah diajukan')));
        prefs.setString("tanggalAbsen", json["tanggal"]);
        dispose();
      }
    } else {
      throw Exception('Failed to read API');
    }
  }

  setImage(bool first, imageFile, int type) {
    if (imageFile == null) return;
    // setState(() => _similarity = "nil");
    if (first) {
      image1.bitmap = base64Encode(imageFile);
      image1.imageType = type;
      setState(() {
        img1 = base64Encode(imageFile);
      });
    } else {
      image2.bitmap = base64Encode(imageFile);
      image2.imageType = type;
    }
  }

  captureImage() {
    Regula.FaceSDK.presentFaceCaptureActivity().then((result) {
      setImage(
          true,
          base64Decode(Regula.FaceCaptureResponse.fromJson(json.decode(result))!
              .image!
              .bitmap!
              .replaceAll("\n", "")),
          Regula.ImageType.LIVE);
      matchFaces();
    });
  }

  matchFaces() {
    setState(() {
      processing = true;
      match_process = true;
    });
    var request = Regula.MatchFacesRequest();
    request.images = [image1, image2];
    Regula.FaceSDK.matchFaces(jsonEncode(request)).then((value) {
      var response = Regula.MatchFacesResponse.fromJson(json.decode(value));
      Regula.FaceSDK.matchFacesSimilarityThresholdSplit(
              jsonEncode(response!.results), 0.75)
          .then((str) {
        var split = Regula.MatchFacesSimilarityThresholdSplit.fromJson(
            json.decode(str));
        setState(() {
          _similarity = split!.matchedFaces.length > 0
              ? (split.matchedFaces[0]!.similarity! * 100)
              : 0;
          if (_similarity >= 90) {
            match = true;
            match_process = false;
          } else {
            match = false;
            match_process = false;
          }
        });
      });
    });
  }

  Widget createImage() => Material(
        child: img1 == null
            ? SizedBox(height: 150, width: 150)
            : ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: Image(
                    height: 150,
                    width: 150,
                    image: MemoryImage(base64Decode(img1))),
              ),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: Text(
          "Lakukan Kehadiran",
          style: TextStyle(color: Colors.white),
        ),
        leading: BackButton(
          onPressed: () => dispose(),
          color: Colors.white,
        ),
      ),
      body: Container(
          alignment: Alignment.topCenter,
          padding: EdgeInsets.only(top: 20),
          // margin: EdgeInsets.fromLTRB(0, 0, 0, 100),
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                    alignment: Alignment.topCenter,
                    width: 390,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          createImage(),
                          // Container(
                          //   // margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                          Text(
                              processing == false
                                  ? ""
                                  : processing == true && match_process == true
                                      ? "Gambar sedang diproses"
                                      : processing == true &&
                                              match_process == false &&
                                              match == true
                                          ? "Status kecocokan: \nAnda bisa melakukan absen"
                                          : "Status kecocokan: \nWajah tidak sama. \nSilahkan lakukan \npemotretan ulang",
                              style: TextStyle(fontSize: 15),
                              textAlign: TextAlign.center),
                          // )
                        ])),
                Container(
                    padding: EdgeInsets.only(top: 20),
                    width: 390,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                              width: 170,
                              child: TextField(
                                  controller: controllerTanggal,
                                  readOnly: true,
                                  style: TextStyle(
                                    fontSize: 12,
                                  ),
                                  decoration: const InputDecoration(
                                    labelText: 'Tanggal',
                                  ))),
                          SizedBox(
                              width: 170,
                              child: TextField(
                                  controller: controllerJam,
                                  readOnly: true,
                                  style: TextStyle(
                                    fontSize: 12,
                                  ),
                                  decoration: const InputDecoration(
                                    labelText: 'Jam hadir',
                                  ))),
                        ])),
                Container(
                    margin: EdgeInsets.only(top: 20),
                    height: 50,
                    width: 390,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                              // alignment: Alignment.bo,
                              width: 170,
                              height: 50,
                              child: Stack(children: [
                                Container(
                                    height: 15,
                                    margin: EdgeInsets.only(top: 10),
                                    child: Text(
                                      "Keterangan",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey.shade700),
                                    )),
                                Container(
                                    decoration: BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                                width: 1,
                                                color: Colors.grey.shade600)))),
                                // padding: EdgeInsets.only(top: 15),
                                Container(
                                    margin: EdgeInsets.only(top: 20),
                                    child: DropdownButtonHideUnderline(
                                        child: DropdownButton(
                                            value: keterangan,
                                            icon: const Icon(
                                                Icons.arrow_drop_down),
                                            elevation: 16,
                                            // style: const TextStyle(color: Colors.deepPurple),
                                            underline: Container(
                                                margin:
                                                    EdgeInsets.only(top: 20),
                                                height: 1,
                                                color: Colors.grey
                                                // color: Colors.deepPurpleAccent,
                                                ),
                                            onChanged: (value) {
                                              // This is called when the user selects an item.
                                              setState(() {
                                                keterangan = value!;
                                              });
                                            },
                                            items: list
                                                .map<DropdownMenuItem>((value) {
                                              return DropdownMenuItem(
                                                  value: value,
                                                  child: Text(
                                                    value == 0
                                                        ? 'Menetap di kantor'
                                                        : value == 1
                                                            ? 'Keliling'
                                                            : 'Lain-lain',
                                                    style:
                                                        TextStyle(fontSize: 14),
                                                  ));
                                            }).toList()))),
                              ])),
                          if (keterangan == 2)
                            SizedBox(
                                width: 170,
                                child: TextField(
                                    controller: controllerKeterangan,
                                    style: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width >=
                                                  720
                                              ? 14
                                              : 12,
                                    ),
                                    decoration: const InputDecoration(
                                      labelText: 'Silahkan diisi',
                                    ))),
                        ])),
                Container(
                    margin: EdgeInsets.only(top: 30),
                    height: 50,
                    width: 390,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                                processing == true && match_process == true
                                    ? Colors.orange.shade200
                                    : Colors.orange),
                        onPressed: () {
                          if (processing == true && match_process == true) {
                            null;
                          } else if (processing == true &&
                              match_process == false &&
                              match == true) {
                            submit(context);
                          } else {
                            captureImage();
                          }
                        },
                        child: Text(
                            processing == true && match_process == true
                                ? "Gambar sedang diproses"
                                : processing == true &&
                                        match_process == false &&
                                        match == true
                                    ? "Submit"
                                    : "Ambil foto ulang",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white))))
              ])));
}
