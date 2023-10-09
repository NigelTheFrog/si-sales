import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_face_api/face_api.dart' as Regula;
import 'package:intl/intl.dart';
import 'package:pt_coronet_crown/main.dart';
import 'package:http/http.dart' as http;

class BuatKehadiran extends StatefulWidget {
  @override
  _BuatKehadiranState createState() => _BuatKehadiranState();
}

class _BuatKehadiranState extends State<BuatKehadiran> {
  var image1 = Regula.MatchFacesImage();
  var image2 = Regula.MatchFacesImage();
  var img1;
  double _similarity = 0;
  int rand = 0;
  String keterangan = "", tanggal = "";
  bool processing = false;
  bool match = false;
  bool match_process = false;
  TextEditingController controllerTanggal = TextEditingController(),
      controllerJam = TextEditingController();
  List<String> list = <String>['Kantor', 'Keliling', 'Lain-Lain'];

  @override
  void initState() {
    controllerTanggal.text = DateFormat.yMMMMEEEEd('id').format(DateTime.now());
    controllerJam.text = DateFormat.Hm().format(DateTime.now());
    tanggal = DateTime.now().toString().substring(0, 10);
    rand = Random().nextInt(100);
    setImage(false, base64Decode(avatar), 1);
    captureImage();
    super.initState();
  }

  void submit(BuildContext context) async {
    final response = await http.post(
        Uri.parse("https://otccoronet.com/otc/laporan/event/buatproposal.php"),
        body: {
          'id': "$rand/$tanggal/$username",
          'nama': nama,
          'tanggal': tanggal,
          'jam': controllerJam.text,
          'bukti': img1,
          'keterangan': keterangan,
          "username": username
        });
    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      if (json['result'] == 'success') {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Laporan telah diajukan')));
        Navigator.popAndPushNamed(context, "/daftarproposal");
      }
      // else if (json['Error'] ==
      //     "Got a packet bigger than 'max_allowed_packet' bytes") {
      //   setState(() {
      //     warningDialog(context, "Ukuran gambar terlalu besar");
      //   });
      // } else {
      //   setState(() {
      //     warningDialog(context,
      //         "${json['Error']}\nSilahkan contact leader anda untuk menambahkan jumlah stock pada sistem");
      //   });

      // }
    } else {
      throw Exception('Failed to read API');
    }
  }

  setImage(bool first, Uint8List? imageFile, int type) {
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
                                    fontSize:
                                        MediaQuery.of(context).size.width >= 720
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
                                        MediaQuery.of(context).size.width >= 720
                                            ? 14
                                            : 12,
                                  ),
                                  decoration: const InputDecoration(
                                    labelText: 'Jam hadir',
                                  ))),
                        ])),
                Container(
                  margin: EdgeInsets.only(top: 30),
                  height: 50,
                  width: 390,
                ),
                Container(
                    margin: EdgeInsets.only(top: 30),
                    height: 50,
                    width: 390,
                    child: ElevatedButton(
                        onPressed: () {},
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
