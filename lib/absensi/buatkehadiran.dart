import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_face_api/face_api.dart' as Regula;
import 'package:pt_coronet_crown/main.dart';

class BuatKehadiran extends StatefulWidget {
  @override
  _BuatKehadiranState createState() => _BuatKehadiranState();
}

class _BuatKehadiranState extends State<BuatKehadiran> {
  var image1 = Regula.MatchFacesImage();
  var image2 = Regula.MatchFacesImage();
  var img1 = Image.asset('assets/Nigel1.jpg');
  double _similarity = 0;
  bool processing = false;
  bool match = false;
  bool match_process = false;
  TextEditingController controllerTanggal = TextEditingController(),
      controllerJam = TextEditingController();

  @override
  void initState() {
    setImage(false, base64Decode(avatar), 1);
    captureImage();

    super.initState();
  }

  setImage(bool first, Uint8List? imageFile, int type) {
    if (imageFile == null) return;
    // setState(() => _similarity = "nil");
    if (first) {
      image1.bitmap = base64Encode(imageFile);
      image1.imageType = type;
      setState(() {
        img1 = Image.memory(imageFile);
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
          print(_similarity);
        });
      });
    });
  }

  Widget createImage(image) => Material(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.0),
          child: Image(height: 150, width: 150, image: image),
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
            onPressed: () => Navigator.pop(context, true),
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
                            createImage(img1.image),
                            // Container(
                            //   // margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                            Text(
                                processing == false
                                    ? ""
                                    : processing == true &&
                                            match_process == true
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
                                      fontSize:
                                          MediaQuery.of(context).size.width >=
                                                  720
                                              ? 14
                                              : 12,
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
                                      fontSize:
                                          MediaQuery.of(context).size.width >=
                                                  720
                                              ? 14
                                              : 12,
                                    ),
                                    decoration: const InputDecoration(
                                      labelText: 'Jam hadir',
                                    )))
                          ]))

                  // Container(margin: EdgeInsets.fromLTRB(0, 0, 0, 15)),
                  // createButton("Match", () => matchFaces()),
                ])),
      );
}
