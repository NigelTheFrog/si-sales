import 'dart:convert';
import 'dart:math';
//Kendala di hadir kemarin gaada sinyal. Karena tidak ada sinyal foto tidak bisa masuk
import 'package:flutter/material.dart';
import 'package:pt_coronet_crown/account/createacount.dart';
import 'package:pt_coronet_crown/account/login.dart';
import 'package:pt_coronet_crown/admin/attendence/dailyvisit.dart';
import 'package:pt_coronet_crown/admin/company/daftarprovinsi.dart';
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
import 'package:pt_coronet_crown/laporan/event/laporan/daftarevent.dart';
import 'package:pt_coronet_crown/laporan/event/proposal/buatproposal.dart';
import 'package:pt_coronet_crown/laporan/event/proposal/daftarproposal.dart';
import 'package:pt_coronet_crown/laporan/pembelian/buatlaporanbeli.dart';
import 'package:pt_coronet_crown/laporan/pembelian/daftarpembelian.dart';
import 'package:pt_coronet_crown/laporan/penjualan/buatlaporanjual.dart';
import 'package:pt_coronet_crown/laporan/penjualan/daftarpenjualan.dart';
import 'package:pt_coronet_crown/mainpage/history.dart';
import 'package:pt_coronet_crown/mainpage/home.dart';
import 'package:pt_coronet_crown/mainpage/kunjungan/daftarkunjungan.dart';
import 'package:pt_coronet_crown/mainpage/kunjungan/buatkunjungan.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image/image.dart' as img;

String username = "",
    idjabatan = "",
    idcabang = "",
    nama = "",
    email = "",
    jabatan = "";
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

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  checkUser().then((String result) {
    if (result == '')
      runApp(MyLogin());
    else {
      username = result;
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
}

void doLogout() async {
  final prefs = await SharedPreferences.getInstance();
  prefs.remove("username");
  main();
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
      themeMode: ThemeMode.light,
      home: const MyHomePage(title: 'Home'),
      debugShowCheckedModeBanner: false,
      routes: {
        "/tambahlaporanpenjualan": (context) =>
            BuatPenjualan(id: Random().nextInt(2)),
        "/tambahlaporanpembelian": (context) => BuatPembelian(),
        "/homepage": (context) => MyApp(),
        "/kunjunganmasuk": (contex) => BuatKunjungan(),

        "/daftarproposal": (context) => DaftarProposal(),
        "/daftarevent": (context) => DaftarEvent(),
        // "/daftarevent": (context) => DaftarEvent(),

        //harus dilakukan pengecekan id jabatan
        "/daftarpembelian": (context) => DaftarPembelian(),
        "/daftarpenjualan": (context) => DaftarPenjualan(),
        "/daftarkunjungan": (context) => DailyVisit(),
        "/daftarpersonel": (context) => PersonelData(),
        "/daftargrup": (context) => PersonelGroup(),
        "tambahstaff": (context) => CreateAccount(),
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
  final List<Widget> screens = [
    Container(),
    PersonelData(),
    PersonelGroup(),
    BuatKunjungan(),
    DaftarKunjungan(
      type: idjabatan == "3" ? 0 : 1,
    ),
    DaftarPembelian(),
    DaftarPenjualan(),
    DaftarProposal(),
    DaftarEvent(),
    DaftarProvinsi()
  ];

  final List<String> _title = [
    'Home',
    'Data Personel',
    'Group Personel',
    'Daftar Kehadiran',
    'Kunjungan',
    'Daftar Pembelian',
    'Daftar Penjualan',
    'Daftar Proposal',
    'Daftar Event',
    'Daftar Provinsi'
  ];

  void doLogout() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove("username");
    main();
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

  Widget buildTile(index, text, icon) {
    return Material(
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
            if (index != 14) {
              setState(() => indexScreen = index);
            } else {
              indexScreen = 0;
              doLogout();
            }
          },
        ));
  }

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
            buildTile(3, "Daftar Kehadiran", Icons.check_rounded),
            buildTile(4, "Kunjungan", Icons.location_on),
          ],
        ),
        ExpansionTile(
          collapsedIconColor: Colors.white,
          iconColor: Colors.amber.shade600,
          title: const Text("Transaksi", style: TextStyle(color: Colors.white)),
          leading: const Icon(Transaction.attach_money, color: Colors.white),
          children: <Widget>[
            buildTile(5, "Pembelian", Clippy.clippy),
            buildTile(6, "Penjualan", ClipBoardCheck.clipboard_check),
          ],
        ),
        ExpansionTile(
          collapsedIconColor: Colors.white,
          iconColor: Colors.amber.shade600,
          title: Text("Event", style: TextStyle(color: Colors.white)),
          leading: Icon(EventChart.chart_line, color: Colors.white),
          children: [
            buildTile(7, "Proposal Event", Proposal.doc_text_inv),
            buildTile(8, "Riwayat Event", Calendar.event),
          ],
        ),
        buildTile(9, "Outlet", Outlet.industrial_building),
        ExpansionTile(
          collapsedIconColor: Colors.white,
          iconColor: Colors.amber.shade600,
          title: const Text("Company", style: TextStyle(color: Colors.white)),
          leading: const Icon(Icons.business_center, color: Colors.white),
          children: <Widget>[
            buildTile(10, "Profile", Icons.business),
            buildTile(11, "Admin", Icons.admin_panel_settings),
            buildTile(12, "Produk", Produk.box_open),
            buildTile(13, "Jabatan", Jabatan.group),
          ],
        ),
        buildTile(14, "Logout", Icons.logout)
      ]));
    } else if (idjabatan == "3") {
      return SingleChildScrollView(
          child: Column(children: [
        buildAvatar(),
        buildTile(0, "Home", Icons.home),
        buildTile(3, "Kehadiran", Icons.check_rounded),
        buildTile(4, "Kunjungan", Icons.location_on),
        buildTile(6, "Penjualan", ClipBoardCheck.clipboard_check),
        ExpansionTile(
          collapsedIconColor: Colors.white,
          iconColor: Colors.amber.shade600,
          title: Text("Event", style: TextStyle(color: Colors.white)),
          leading: Icon(EventChart.chart_line, color: Colors.white),
          children: [
            buildTile(7, "Proposal Event", Proposal.doc_text_inv),
            buildTile(8, "Riwayat Event", Calendar.event),
          ],
        ),
        buildTile(1, "Informasi Akun", Icons.account_circle),
        buildTile(14, "Logout", Icons.logout)
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
            buildTile(3, "Daftar Kehadiran", Icons.check_rounded),
            buildTile(4, "Kunjungan", Icons.location_on),
          ],
        ),
        ExpansionTile(
          collapsedIconColor: Colors.white,
          iconColor: Colors.amber.shade600,
          title: const Text("Transaksi", style: TextStyle(color: Colors.white)),
          leading: const Icon(Transaction.attach_money, color: Colors.white),
          children: <Widget>[
            buildTile(5, "Pembelian", Clippy.clippy),
            buildTile(6, "Penjualan", ClipBoardCheck.clipboard_check),
          ],
        ),
        ExpansionTile(
          collapsedIconColor: Colors.white,
          iconColor: Colors.amber.shade600,
          title: Text("Event", style: TextStyle(color: Colors.white)),
          leading: Icon(EventChart.chart_line, color: Colors.white),
          children: [
            buildTile(7, "Proposal Event", Proposal.doc_text_inv),
            buildTile(8, "Riwayat Event", Calendar.event),
          ],
        ),
        buildTile(9, "Outlet", Outlet.industrial_building),
        buildTile(12, "Produk", Produk.box_open),
        buildTile(14, "Logout", Icons.logout)
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
                //height: 720,
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
