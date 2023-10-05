// import 'dart:convert';
// import 'dart:io';

// import 'package:image/image.dart' as imglib;
// import 'package:camera/camera.dart';
// import 'package:pt_coronet_crown/faceModule/model.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:google_ml_kit/google_ml_kit.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:quiver/collection.dart';
// import 'package:tflite_flutter/tflite_flutter.dart';
// import 'package:pt_coronet_crown/faceModule/detector.dart';
// import 'package:pt_coronet_crown/faceModule/utils.dart';

// class FaceRecognitionView extends StatefulWidget {
//   const FaceRecognitionView({Key? key}) : super(key: key);

//   @override
//   State<FaceRecognitionView> createState() => _FaceRecognitionViewState();
// }

// class _FaceRecognitionViewState extends State<FaceRecognitionView>
//     with WidgetsBindingObserver {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     SystemChrome.setPreferredOrientations(
//         [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

//     _start();
//   }

//   void _start() async {
//     interpreter = await loadModel();
//     initialCamera();
//   }

//   @override
//   void dispose() async {
//     WidgetsBinding.instance.removeObserver(this);
//     if (_camera != null) {
//       await _camera!.stopImageStream();
//       await Future.delayed(const Duration(milliseconds: 200));
//       await _camera!.dispose();
//       _camera = null;
//     }
//     super.dispose();
//   }

//   late File jsonFile;
//   var interpreter;
//   CameraController? _camera;
//   dynamic data = {};
//   bool _isDetecting = false;
//   double threshold = 1.0;
//   dynamic _scanResults;
//   String _predRes = '';
//   bool isStream = true;
//   CameraImage? _cameraimage;
//   Directory? tempDir;
//   bool _faceFound = false;
//   bool _verify = false;
//   List? e1;
//   bool loading = true;
//   final TextEditingController _name = TextEditingController(text: '');

//   void initialCamera() async {
//     CameraDescription description =
//         await getCamera(CameraLensDirection.front); //camera depan;

//     _camera = CameraController(
//       description,
//       ResolutionPreset.low,
//       enableAudio: false,
//       imageFormatGroup: ImageFormatGroup.yuv420,
//     );
//     await _camera!.initialize();
//     // await Future.delayed(const Duration(milliseconds: 500));
//     loading = false;
//     tempDir = await getApplicationDocumentsDirectory();
//     String _embPath = tempDir!.path + '/emb.json';
//     jsonFile = File(_embPath);
//     if (jsonFile.existsSync()) {
//       data = json.decode(jsonFile.readAsStringSync());
//     }

//     await Future.delayed(const Duration(milliseconds: 500));

//     _camera!.startImageStream((CameraImage image) async {
//       if (_camera != null) {
//         if (_isDetecting) return;
//         _isDetecting = true;
//         dynamic finalResult = Multimap<String, Face>();

//         detect(image, getDetectionMethod()).then((dynamic result) async {
//           if (result.length == 0 || result == null) {
//             _faceFound = false;
//             _predRes = 'Tidak dikenali';
//           } else {
//             _faceFound = true;
//           }

//           String res;
//           Face _face;

//           imglib.Image convertedImage =
//               convertCameraImage(image, CameraLensDirection.front);

//           for (_face in result) {
//             double x, y, w, h;
//             x = (_face.boundingBox.left - 10);
//             y = (_face.boundingBox.top - 10);
//             w = (_face.boundingBox.width + 10);
//             h = (_face.boundingBox.height + 10);
//             imglib.Image croppedImage = imglib.copyCrop(
//                 convertedImage, x.round(), y.round(), w.round(), h.round());
//             croppedImage = imglib.copyResizeCropSquare(croppedImage, 112);
//             // res = recog(croppedImage);
//             // finalResult.add(res, _face);
//           }

//           _scanResults = finalResult;
//           _isDetecting = false;
//           setState(() {});
//         }).catchError(
//           (_) async {
//             print({'error': _.toString()});
//             _isDetecting = false;
//             if (_camera != null) {
//               await _camera!.stopImageStream();
//               await Future.delayed(const Duration(milliseconds: 400));
//               await _camera!.dispose();
//               await Future.delayed(const Duration(milliseconds: 400));
//               _camera = null;
//             }
//             Navigator.pop(context);
//           },
//         );
//       }
//     });
//   }

//   // String recog(imglib.Image img) {
//   //   List input = imageToByteListFloat32(img, 112, 128, 128);
//   //   input = input.reshape([1, 112, 112, 3]);
//   //   List output = List.filled(1 * 192, null, growable: false).reshape([1, 192]);
//   //   interpreter.run(input, output);
//   //   output = output.reshape([192]);
//   //   e1 = List.from(output);
//   //   return compare(e1!).toUpperCase();
//   // }

//   // String compare(List currEmb) {
//   //   //mengembalikan nama pemilik akun
//   //   double minDist = 999;
//   //   double currDist = 0.0;
//   //   _predRes = "Tidak dikenali";
//   //   for (String label in data.keys) {
//   //     currDist = euclideanDistance(data[label], currEmb);
//   //     if (currDist <= threshold && currDist < minDist) {
//   //       minDist = currDist;
//   //       _predRes = label;
//   //       if (_verify == false) {
//   //         _verify = true;
//   //       }
//   //     }
//   //   }
//   //   return _predRes;
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset: false,
//       appBar: AppBar(
//         title: const Text('Face Recognition'),
//       ),
//       floatingActionButton: FloatingActionButton(
//           onPressed: () {
//             showDialog(
//                 context: context,
//                 builder: (context) {
//                   return AlertDialog(
//                     content: Column(children: [
//                       TextField(
//                         controller: _name,
//                       ),
//                       ElevatedButton(
//                           onPressed: () async {
//                             Navigator.pop(context);
//                             await Future.delayed(
//                                 const Duration(milliseconds: 400));
//                             data[_name.text] = e1;
//                             jsonFile.writeAsStringSync(json.encode(data));
//                             if (_camera != null) {
//                               await _camera!.stopImageStream();
//                               await Future.delayed(
//                                   const Duration(milliseconds: 400));
//                               await _camera!.dispose();
//                               await Future.delayed(
//                                   const Duration(milliseconds: 400));
//                               _camera = null;
//                             }
//                             Navigator.pop(context);
//                           },
//                           child: const Text('Simpan'))
//                     ]),
//                   );
//                 });
//           },
//           child: const Icon(Icons.add)),
//       body: Builder(builder: (context) {
//         if ((_camera == null || !_camera!.value.isInitialized) || loading) {
//           return const Center(
//             child: CircularProgressIndicator(),
//           );
//         }
//         return Container(
//           constraints: const BoxConstraints.expand(),
//           padding: EdgeInsets.only(
//               top: 0, bottom: MediaQuery.of(context).size.height * 0.2),
//           child: _camera == null
//               ? const Center(child: SizedBox())
//               : Stack(
//                   fit: StackFit.expand,
//                   children: <Widget>[
//                     CameraPreview(_camera!),
//                     _buildResults(),
//                   ],
//                 ),
//         );
//       }),
//     );
//   }

//   Widget _buildResults() {
//     Center noResultsText = const Center(
//         child: Text('Mohon Tunggu ..',
//             style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 17,
//                 color: Colors.white)));
//     if (_scanResults == null ||
//         _camera == null ||
//         !_camera!.value.isInitialized) {
//       return noResultsText;
//     }
//     CustomPainter painter;

//     final Size imageSize = Size(
//       _camera!.value.previewSize!.height,
//       _camera!.value.previewSize!.width,
//     );
//     painter = FaceDetectorPainter(imageSize, _scanResults);
//     return CustomPaint(
//       painter: painter,
//     );
//   }
// }

// // class CameraSwitchTest extends StatefulWidget {
// //   CameraSwitchTest({Key? key}) : super(key: key);

// //   @override
// //   _CameraSwitchTestState createState() => _CameraSwitchTestState();
// // }

// // class _CameraSwitchTestState extends State<CameraSwitchTest> {
// //   CameraController? controller;
// //   bool frontCamera = false;

// //   List<CameraDescription>? cameras;

// //   @override
// //   void initState() {
// //     initCamera();
// //     super.initState();
// //   }

// //   initCamera() async {
// //     if (cameras == null) {
// //       cameras = await availableCameras();
// //     }

// //     if (controller?.value.isInitialized ?? false) {
// //       controller!.dispose();
// //     }
// //     controller = CameraController(
// //         cameras!.firstWhere(
// //           (element) => element.lensDirection == (CameraLensDirection.front),
// //         ),
// //         ResolutionPreset.medium,
// //         enableAudio: false);
// //     controller!.initialize().then((value) {
// //       setState(() {});
// //     });
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: Text("Camera Test")),
// //       body: Column(
// //         children: [
// //           if (controller != null)
// //             Container(
// //               child: CameraPreview(controller!),
// //               height: 400,
// //             ),
// //           Row(
// //             children: [
// //               ElevatedButton(
// //                 onPressed: () {
// //                   frontCamera = !frontCamera;
// //                   initCamera();
// //                 },
// //                 child: Text("Switch"),
// //               ),
// //             ],
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
import 'dart:convert';
import 'dart:io' as io;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_face_api/face_api.dart' as Regula;
import 'package:image_picker/image_picker.dart';

class BuatKehadiran extends StatefulWidget {
  @override
  _BuatKehadiranState createState() => _BuatKehadiranState();
}

class _BuatKehadiranState extends State<BuatKehadiran> {
  var image1 = new Regula.MatchFacesImage();
  var image2 = new Regula.MatchFacesImage();
  var img1 = Image.asset('assets/Nigel1.jpg');
  var img2 = Image.asset('assets/Nigel1.jpg');
  String _similarity = "nil";
  String _liveness = "nil";

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {}

  showAlertDialog(BuildContext context, bool first) => showDialog(
      context: context,
      builder: (BuildContext context) =>
          AlertDialog(title: Text("Select option"), actions: [
            // ignore: deprecated_member_use
            TextButton(
                child: Text("Use gallery"),
                onPressed: () {
                  ImagePicker()
                      .pickImage(source: ImageSource.gallery)
                      .then((value) => {
                            setImage(
                                first,
                                io.File(value!.path).readAsBytesSync(),
                                Regula.ImageType.PRINTED)
                          });
                }),
            // ignore: deprecated_member_use
            TextButton(
                child: Text("Use camera"),
                onPressed: () {
                  Regula.FaceSDK.presentFaceCaptureActivity().then((result) =>
                      setImage(
                          first,
                          base64Decode(Regula.FaceCaptureResponse.fromJson(
                                  json.decode(result))!
                              .image!
                              .bitmap!
                              .replaceAll("\n", "")),
                          Regula.ImageType.LIVE));
                  Navigator.pop(context);
                })
          ]));

  setImage(bool first, Uint8List? imageFile, int type) {
    if (imageFile == null) return;
    setState(() => _similarity = "nil");
    if (first) {
      image1.bitmap = base64Encode(imageFile);
      image1.imageType = type;
      setState(() {
        img1 = Image.memory(imageFile);
        _liveness = "nil";
      });
    } else {
      image2.bitmap = base64Encode(imageFile);
      image2.imageType = type;
      setState(() => img2 = Image.memory(imageFile));
    }
  }

  clearResults() {
    setState(() {
      img1 = Image.asset('assets/Nigel1.jpg');
      img2 = Image.asset('assets/Nigel1.jpg');
      _similarity = "nil";
      _liveness = "nil";
    });
    image1 = new Regula.MatchFacesImage();
    image2 = new Regula.MatchFacesImage();
  }

  matchFaces() {
    setState(() => _similarity = "Processing...");
    var request = new Regula.MatchFacesRequest();
    request.images = [image1, image2];
    Regula.FaceSDK.matchFaces(jsonEncode(request)).then((value) {
      var response = Regula.MatchFacesResponse.fromJson(json.decode(value));
      Regula.FaceSDK.matchFacesSimilarityThresholdSplit(
              jsonEncode(response!.results), 0.75)
          .then((str) {
        var split = Regula.MatchFacesSimilarityThresholdSplit.fromJson(
            json.decode(str));
        setState(() => _similarity = split!.matchedFaces.length > 0
            ? ((split.matchedFaces[0]!.similarity! * 100).toStringAsFixed(2) +
                "%")
            : "error");
      });
    });
  }

  liveness() => Regula.FaceSDK.startLiveness().then((value) {
        var result = Regula.LivenessResponse.fromJson(json.decode(value));
        setImage(true, base64Decode(result!.bitmap!.replaceAll("\n", "")),
            Regula.ImageType.LIVE);
        setState(() => _liveness = result.liveness == 0 ? "passed" : "unknown");
      });

  Widget createButton(String text, VoidCallback onPress) => Container(
        // ignore: deprecated_member_use
        child: TextButton(
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
              backgroundColor: MaterialStateProperty.all<Color>(Colors.black12),
            ),
            onPressed: onPress,
            child: Text(text)),
        width: 250,
      );

  Widget createImage(image, VoidCallback onPress) => Material(
          child: InkWell(
        onTap: onPress,
        child: Container(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: Image(height: 150, width: 150, image: image),
          ),
        ),
      ));

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Container(
            margin: EdgeInsets.fromLTRB(0, 0, 0, 100),
            width: double.infinity,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  createImage(img1.image, () => showAlertDialog(context, true)),
                  createImage(
                      img2.image, () => showAlertDialog(context, false)),
                  Container(margin: EdgeInsets.fromLTRB(0, 0, 0, 15)),
                  createButton("Match", () => matchFaces()),
                  createButton("Liveness", () => liveness()),
                  createButton("Clear", () => clearResults()),
                  Container(
                      margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Similarity: " + _similarity,
                              style: TextStyle(fontSize: 18)),
                          Container(margin: EdgeInsets.fromLTRB(20, 0, 0, 0)),
                          Text("Liveness: " + _liveness,
                              style: TextStyle(fontSize: 18))
                        ],
                      ))
                ])),
      );
}
