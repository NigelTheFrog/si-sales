import 'dart:convert';
import 'dart:math';
import 'dart:io';

//Kendala di hadir kemarin gaada sinyal. Karena tidak ada sinyal foto tidak bisa masuk
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:pt_coronet_crown/absensi/buatkehadiran.dart';
import 'package:pt_coronet_crown/absensi/daftarkehadiran.dart';
import 'package:pt_coronet_crown/absensi/daftarpersetujuan.dart';
import 'package:pt_coronet_crown/account/createacount.dart';
import 'package:pt_coronet_crown/account/login.dart';
// import 'package:pt_coronet_crown/admin/company/daftarkota.dart';
import 'package:pt_coronet_crown/admin/company/daftarprovinsi.dart';
import 'package:http/http.dart' as http;
import 'package:pt_coronet_crown/admin/jabatan/daftarjabatan.dart';
import 'package:pt_coronet_crown/admin/personel/addpersonelgroup.dart';
import 'package:pt_coronet_crown/admin/personel/personeldata.dart';
import 'package:pt_coronet_crown/admin/personel/personelgroup.dart';
import 'package:pt_coronet_crown/admin/company/daftarproduk.dart';
import 'package:pt_coronet_crown/customicon/calendar_icons.dart';
import 'package:pt_coronet_crown/customicon/clip_board_check_icons.dart';
import 'package:pt_coronet_crown/customicon/clippy_icons.dart';
import 'package:pt_coronet_crown/customicon/event_chart_icons.dart';
import 'package:pt_coronet_crown/customicon/jabatan_icons.dart';
import 'package:pt_coronet_crown/customicon/outlet_icons.dart';
import 'package:pt_coronet_crown/customicon/produk_icons.dart';
import 'package:pt_coronet_crown/customicon/proposal_icons.dart';
import 'package:pt_coronet_crown/customicon/transaction_icons.dart';
import 'package:pt_coronet_crown/laporan/event/laporan/buatlaporan.dart';
import 'package:pt_coronet_crown/laporan/event/laporan/daftarevent.dart';
import 'package:pt_coronet_crown/laporan/event/proposal/buatproposal.dart';
import 'package:pt_coronet_crown/laporan/event/proposal/daftarproposal.dart';
import 'package:pt_coronet_crown/laporan/pembelian/buatlaporanbeli.dart';
import 'package:pt_coronet_crown/laporan/pembelian/daftarpembelian.dart';
import 'package:pt_coronet_crown/laporan/penjualan/buatlaporanjual.dart';
import 'package:pt_coronet_crown/laporan/penjualan/daftarpenjualan.dart';
import 'package:pt_coronet_crown/mainpage/home.dart';
import 'package:pt_coronet_crown/mainpage/kunjungan/daftarkunjungan.dart';
import 'package:pt_coronet_crown/mainpage/kunjungan/buatkunjungan.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/date_symbol_data_local.dart';

String username = "",
    idjabatan = "",
    idcabang = "",
    nama = "",
    email = "",
    jabatan = "",
    tanggalAbsen = "";
var avatar = "";
int indexScreen = 0;

Future<String> checkUser() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString("username") ?? '';
}

Future<String> getIdJabatan() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString("idJabatan") ?? '';
}

Future<String> getAvatar() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString("avatar") ?? '';
}

Future<String> getIdCabang() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString("idCabang") ?? '';
}

Future<String> getNama() async {
  final prefs = await SharedPreferences.getInstance();
  return "${prefs.getString("nama_depan")} ${prefs.getString("nama_belakang")}";
}

Future<String> getEmail() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString("email") ?? '';
}

Future<String> getJabatan() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString("jabatan") ?? '';
}

Future<String> getTanggalAbsen() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString("tanggalAbsen") ?? '';
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  checkUser().then((String result) {
    if (result == '')
      runApp(MyLogin());
    else {
      username = result;
      HttpOverrides.global = MyHttpOverrides();
      runApp(const MyApp());
    }
  });

  getIdJabatan().then((String result) {
    idjabatan = result;
  });

  getAvatar().then((String result) {
    avatar = result;
  });

  getIdCabang().then((String result) {
    idcabang = result;
  });

  getNama().then((String result) {
    nama = result;
  });

  getEmail().then((String result) {
    email = result;
  });

  getJabatan().then((String result) {
    jabatan = result;
  });

  getTanggalAbsen().then((String result) {
    tanggalAbsen = result;
  });
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void doLogout() async {
  final prefs = await SharedPreferences.getInstance();
  prefs.remove("username");
  main();
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PT Coronet Crown',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.orange,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.orange,
        brightness: Brightness.dark,
        /* dark theme settings */
      ),
      scrollBehavior: MyCustomScrollBehavior(),
      themeMode: ThemeMode.light,
      home: const MyHomePage(title: 'Home'),
      debugShowCheckedModeBanner: false,
      routes: {
        "/tambahlaporanpenjualan": (context) =>
            BuatPenjualan(id: Random().nextInt(2)),
        "/tambahlaporanpembelian": (context) => BuatPembelian(),
        "/homepage": (context) => MyApp(),
        "/kunjunganmasuk": (contex) => BuatKunjungan(),

        // "/daftarevent": (context) => DaftarEvent(),
        "/buatkehadiran": (context) => BuatKehadiran(),
        // "/daftarevent": (context) => DaftarEvent(),

        //harus dilakukan pengecekan id jabatan
        "/daftarpembelian": (context) => DaftarPembelian(),
        "/daftarpenjualan": (context) => DaftarPenjualan(),
        "/daftargrup": (context) => PersonelGroup(),
        "/tambahstaff": (context) => CreateAccount(),
        "tambahgrup": (context) => CreateGroup(),
        "/daftarproduk": (context) => DaftarProduk(),
        "/daftarjabatan": (context) => DaftarJabatan(),
        // "/daftaroutlet": (context) => DaftarKota(),
        "/ajukanproposal": (context) =>
            BuatProposal(id_cabang: idcabang, username: username),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String dateNow = "";
  final List<Widget> screens = [
    Home(),
    PersonelData(type: idjabatan == "3" ? 0 : 1),
    PersonelGroup(),
    DaftarKehadiran(type: idjabatan == "3" ? 0 : 1),
    DaftarPersetujuan(),
    DaftarKunjungan(
      type: idjabatan == "3" ? 0 : 2,
    ),
    DaftarPembelian(),
    DaftarPenjualan(),
    DaftarProposal(type: idjabatan == "3" ? 0 : 1),
    DaftarEvent(type: idjabatan == "3" ? 0 : 1),
    DaftarProvinsi()
  ];

  final List<String> _title = [
    'Home',
    'Data Personel',
    'Group Personel',
    'Daftar Kehadiran',
    'Menunggu Persetujuan',
    'Kunjungan',
    'Daftar Pembelian',
    'Daftar Penjualan',
    'Daftar Proposal',
    'Daftar Event',
    'Daftar Provinsi'
  ];

  void doLogout() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
    main();
  }

  @override
  void initState() {
    // TODO: implement initState
    initializeDateFormatting();
    dateNow = DateTime.now().toString().substring(0, 10);
    super.initState();
  }

  Future<void> checkAbsen() async {
    final response = await http.post(
        Uri.parse("https://otccoronet.com/otc/account/absensi/daftarabsen.php"),
        body: {'username': username, "type": "3"});
    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      if (json['result'] == 'success') {
        Navigator.popAndPushNamed(context, "/buatkehadiran");
      } else if (json['result'] == 'error') {
        warningDialog(json['message']);
      }
    } else {
      throw Exception('Failed to read API');
    }
  }

  warningDialog(content) {
    return showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(title: Text("Peringatan"), content: Text(content)));
  }

  Widget NavigationDrawer() {
    return Drawer(
        elevation: 16.0,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width * 0.18,
              color: Colors.grey.shade900,
              child: NavigationContent()),
        ));
  }

  void permission() async {
    LocationPermission permission;
    if (kIsWeb) {
      warningDialog(
          "Fitur absensi tidak tersedia pada versi website atau desktop. \nSilahkan akses dari aplikasi ponsel anda");
    } else {
      if (await Permission.camera.status.isDenied) {
        Permission.camera.request();
      } else if (await Permission.camera.status.isPermanentlyDenied) {
        warningDialog("Anda belum mengizinkan penggunaan kamera");
        openAppSettings();
      }

      permission = await Geolocator.checkPermission();
      if (!await Geolocator.isLocationServiceEnabled()) {
        warningDialog("Anda belum aktivasi lokasi pada perangkat mobile");
      }
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          warningDialog("Harap izinkan aplikasi dalam mengakses aplikasi");
        }
      } else if (permission == LocationPermission.deniedForever) {
        warningDialog(
            "Aplikasi anda melarang akses lokasi, silahkan lakukan perubahan hak akses di setting");
      } else {
        checkAbsen();
      }
    }
  }

  Widget buildTile(index, text, icon) => Material(
      type: MaterialType.transparency,
      child: ListTile(
        tileColor: indexScreen == index
            ? Color.fromARGB(255, 193, 144, 0)
            : Colors.transparent,
        hoverColor: Colors.amber.shade600,
        splashColor: Colors.grey.shade600,
        title: Text(text, style: TextStyle(color: Colors.white)),
        leading: Icon(icon, color: Colors.white),
        onTap: () {
          if (index == 9) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => BuatLaporanEvent(
                          event_id: "6/admin/JTM-SDJ-TAMAN/2023-07-27",
                          penanggung_jawab: "Nigel Kislew William",
                        )));
          }
          if (index != 15) {
            if (dateNow != tanggalAbsen || tanggalAbsen == "") {
              if (index == 3) {
                permission();
              } else {
                warningDialog("Harap lakukan absensi terlebih dahulu");
              }
            } else {
              setState(() => indexScreen = index);
            }
          } else {
            indexScreen = 0;
            doLogout();
          }
        },
      ));

  Widget buildAvatar() {
    return Container(
        color: Colors.grey.shade800,
        padding: EdgeInsets.only(top: 10),
        height: 230,
        width: double.infinity,
        child: Column(children: [
          ClipOval(
              child: Image.memory(
            base64Decode(avatar),
            width: 150,
            height: 150,
            alignment: Alignment.topCenter,
            fit: BoxFit.cover,
          )),
          Padding(
              padding: EdgeInsets.only(top: 5),
              child: Text(nama,
                  style: TextStyle(color: Colors.white, fontSize: 14))),
          Padding(
              padding: EdgeInsets.only(top: 2),
              child: Text('Email: $email \nRole: $jabatan',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 14)))
        ]));
  }

  Widget NavigationContent() {
    if (idjabatan == "1" || idjabatan == "2") {
      return SingleChildScrollView(
          child: Column(children: [
        buildAvatar(),
        buildTile(0, "Home", Icons.home),
        ExpansionTile(
          collapsedIconColor: Colors.white,
          iconColor: Colors.amber.shade600,
          title: const Text("Personnel", style: TextStyle(color: Colors.white)),
          leading: const Icon(Icons.person, color: Colors.white),
          children: <Widget>[
            buildTile(1, "Personel Data", Icons.account_box),
            buildTile(2, "Personel Group", Icons.group),
            buildTile(3, "Kehadiran", Icons.check_rounded),
            buildTile(4, "Menunggu Persetujuan", Icons.watch_later_outlined),
            buildTile(5, "Kunjungan", Icons.location_on),
          ],
        ),
        ExpansionTile(
          collapsedIconColor: Colors.white,
          iconColor: Colors.amber.shade600,
          title: const Text("Transaksi", style: TextStyle(color: Colors.white)),
          leading: const Icon(Transaction.attach_money, color: Colors.white),
          children: <Widget>[
            buildTile(6, "Pembelian", Clippy.clippy),
            buildTile(7, "Penjualan", ClipBoardCheck.clipboard_check),
          ],
        ),
        ExpansionTile(
          collapsedIconColor: Colors.white,
          iconColor: Colors.amber.shade600,
          title: Text("Event", style: TextStyle(color: Colors.white)),
          leading: Icon(EventChart.chart_line, color: Colors.white),
          children: [
            buildTile(8, "Proposal Event", Proposal.doc_text_inv),
            buildTile(9, "Riwayat Event", Calendar.event),
          ],
        ),
        buildTile(10, "Outlet", Outlet.industrial_building),
        ExpansionTile(
          collapsedIconColor: Colors.white,
          iconColor: Colors.amber.shade600,
          title: const Text("Company", style: TextStyle(color: Colors.white)),
          leading: const Icon(Icons.business_center, color: Colors.white),
          children: <Widget>[
            buildTile(11, "Profile", Icons.business),
            buildTile(12, "Admin", Icons.admin_panel_settings),
            buildTile(13, "Produk", Produk.box_open),
            buildTile(14, "Jabatan", Jabatan.group),
          ],
        ),
        buildTile(15, "Logout", Icons.logout)
      ]));
    } else if (idjabatan == "3") {
      return SingleChildScrollView(
          child: Column(children: [
        buildAvatar(),
        buildTile(0, "Home", Icons.home),
        buildTile(3, "Kehadiran", Icons.check_rounded),
        buildTile(5, "Kunjungan", Icons.location_on),
        buildTile(7, "Penjualan", ClipBoardCheck.clipboard_check),
        ExpansionTile(
          collapsedIconColor: Colors.white,
          iconColor: Colors.amber.shade600,
          title: Text("Event", style: TextStyle(color: Colors.white)),
          leading: Icon(EventChart.chart_line, color: Colors.white),
          children: [
            buildTile(8, "Proposal Event", Proposal.doc_text_inv),
            buildTile(9, "Riwayat Event", Calendar.event),
          ],
        ),
        buildTile(1, "Informasi Akun", Icons.account_circle),
        buildTile(15, "Logout", Icons.logout)
      ]));
    } else {
      return SingleChildScrollView(
          child: Column(children: [
        buildAvatar(),
        buildTile(0, "Home", Icons.home),
        ExpansionTile(
          collapsedIconColor: Colors.white,
          iconColor: Colors.amber.shade600,
          title: const Text("Personnel", style: TextStyle(color: Colors.white)),
          leading: const Icon(Icons.person, color: Colors.white),
          children: <Widget>[
            buildTile(1, "Personel Data", Icons.account_box),
            buildTile(2, "Personel Group", Icons.group),
            buildTile(3, "Kehadiran", Icons.check_rounded),
            buildTile(4, "Menunggu Persetujuan", Icons.watch_later_outlined),
            buildTile(5, "Kunjungan", Icons.location_on),
          ],
        ),
        ExpansionTile(
          collapsedIconColor: Colors.white,
          iconColor: Colors.amber.shade600,
          title: const Text("Transaksi", style: TextStyle(color: Colors.white)),
          leading: const Icon(Transaction.attach_money, color: Colors.white),
          children: <Widget>[
            buildTile(6, "Pembelian", Clippy.clippy),
            buildTile(7, "Penjualan", ClipBoardCheck.clipboard_check),
          ],
        ),
        ExpansionTile(
          collapsedIconColor: Colors.white,
          iconColor: Colors.amber.shade600,
          title: Text("Event", style: TextStyle(color: Colors.white)),
          leading: Icon(EventChart.chart_line, color: Colors.white),
          children: [
            buildTile(8, "Proposal Event", Proposal.doc_text_inv),
            buildTile(9, "Riwayat Event", Calendar.event),
          ],
        ),
        buildTile(10, "Outlet", Outlet.industrial_building),
        buildTile(13, "Produk", Produk.box_open),
        buildTile(15, "Logout", Icons.logout)
      ]));
    }
  }

  Widget NavigationPane() {
    return Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width * 0.18,
        color: Colors.grey.shade900,
        child: NavigationContent());
  }

  @override
  Widget build(BuildContext context) {
    // if (idjabatan == "1" || idjabatan == "2") {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.orange,
          iconTheme: IconThemeData(color: Colors.white),
          title: MediaQuery.of(context).size.width <= 1050
              ? Text(
                  _title[indexScreen],
                  style: TextStyle(color: Colors.white),
                )
              : IconButton(
                  iconSize: 150,
                  icon: Image.asset('assets/herocyn.png'),
                  onPressed: () => setState(() => indexScreen = 0)),
          // leading: IconButton(
          //   icon: Image.asset('assets/herocyn.png'),
          //   // iconSize: 100,
          //   onPressed: () {},
          // ),
          // title: Text(widget.title),
        ),
        body: Container(
            alignment: Alignment.topCenter,
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,

            // height: MediaQuery.of(context).size.height,
            // width: MediaQuery.of(context).size.width,
            child: Row(children: [
              if (MediaQuery.of(context).size.width >= 1050) NavigationPane(),
              SizedBox(
                width: MediaQuery.of(context).size.width >= 1050
                    ? MediaQuery.of(context).size.width * 0.82
                    : MediaQuery.of(context).size.width,
                child: screens[indexScreen],
              )
            ])),
        // body: Center(
        //   child: Column(
        //     mainAxisAlignment: MainAxisAlignment.center,
        //     children: <Widget>[],
        //   ),
        // ),

        drawer: MediaQuery.of(context).size.width <= 1050
            ? NavigationDrawer()
            : null);
    // } else {
    //   return Scaffold(
    //     appBar: AppBar(
    //         title: Row(
    //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //       children: [
    //         Image.asset('assets/crn.png', height: 50, fit: BoxFit.cover),
    //         CircleAvatar(
    //           backgroundImage: Image.memory(base64Decode(avatar)).image,
    //           radius: 23,
    //         )
    //       ],
    //     )
    //         // actions: <Widget>[

    //         // ],
    //         ),
    //     body: Container(),
    //     bottomNavigationBar: myBottomNavBar(),
    //     floatingActionButton: FloatingActionButton.extended(
    //       onPressed: () {
    //         doLogout();
    //       },
    //       label: Text("Logout", style: TextStyle(color: Colors.white)),
    //       icon: const Icon(Icons.logout),
    //     ),
    //   );
    // }
  }
}
