
// class dynamicWidgetPengunjungBaru extends StatefulWidget {
//   String nama = "", telepon = "", alamat = "", username = "", id_event;
//   int gender = 0, usia = 0;
//   List productBought = [];
//   List<dynamicWidgetPenjualanProduct> dynamicPenjualan = [];
//   dynamicWidgetPengunjungBaru({super.key, required this.id_event});
//   @override
//   _dynamicWidgetPengunjungBaruState createState() {
//     return _dynamicWidgetPengunjungBaruState();
//   }
// }

// class _dynamicWidgetPengunjungBaruState
//     extends State<dynamicWidgetPengunjungBaru> {
//   List<String> genderList = <String>[
//     'Laki-laki',
//     'Perempuan',
//   ];
//   double heigtAddProduct = 0;
//   addProductBaru() {
//     setState(() {
//       if (widget.productBought.isNotEmpty) {
//         widget.productBought = [];
//       }
//       widget.dynamicPenjualan
//           .add(dynamicWidgetPenjualanProduct(id_event: widget.id_event));
//       heigtAddProduct += 50;
//     });
//   }

//   Widget dataPenjualan() {
//     return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
//       Text(
//         'Data Penjualan\n',
//         style: TextStyle(fontWeight: FontWeight.bold),
//       ),
//       SizedBox(
//           height: heigtAddProduct,
//           child: ListView.builder(
//             itemCount: widget.dynamicPenjualan.length,
//             itemBuilder: (_, index) {
//               return Row(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//                   widget.dynamicPenjualan[index],
//                   Tooltip(
//                     message: "Delete penjualan",
//                     child: IconButton(
//                       onPressed: () {
//                         setState(() {
//                           widget.dynamicPenjualan.removeAt(index);
//                           heigtAddProduct -= 50;
//                         });
//                       },
//                       icon: Icon(Icons.delete),
//                     ),
//                   )
//                 ],
//               );
//             },
//           )),
//       Container(
//         margin: EdgeInsets.only(top: 10),
//         height: 50,
//         width: 50,
//         child: ElevatedButton(
//           onPressed: () {
//             setState(() {
//               addProductBaru();
//             });
//           },
//           child: Text(
//             '+',
//             textAlign: TextAlign.center,
//             style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//           ),
//         ),
//       ),
//     ]);
//   }

//   Widget dataPengunjung() {
//     return Container(
//         alignment: Alignment.topLeft,
//         width: 480,
//         child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
//           Text(
//             'Data Pengunjung\n',
//             style: TextStyle(fontWeight: FontWeight.bold),
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               SizedBox(
//                   width: 90,
//                   child: TextField(
//                     decoration: const InputDecoration(
//                       labelText: 'Username',
//                     ),
//                     onChanged: (value) {
//                       widget.username = value;
//                     },
//                   )),
//               SizedBox(
//                   width: 175,
//                   child: TextField(
//                     decoration: const InputDecoration(
//                       labelText: 'Nama Lengkap Pembeli',
//                     ),
//                     onChanged: (value) {
//                       widget.nama = value;
//                     },
//                   )),
//               SizedBox(
//                   width: 120,
//                   child: TextField(
//                     decoration: const InputDecoration(
//                       labelText: 'No Telepon',
//                     ),
//                     onChanged: (value) {
//                       widget.telepon = value;
//                     },
//                   )),
//               SizedBox(
//                   width: 50,
//                   child: TextField(
//                     decoration: const InputDecoration(
//                       labelText: 'Usia',
//                     ),
//                     onChanged: (value) {
//                       widget.usia = int.parse(value);
//                     },
//                   )),
//             ],
//           ),
//           Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//             SizedBox(
//                 width: 300,
//                 child: TextField(
//                   maxLines: 3,
//                   decoration: const InputDecoration(
//                     labelText: 'Alamat Pembeli',
//                   ),
//                   onChanged: (value) {
//                     widget.alamat = value;
//                   },
//                 )),
//             Container(
//                 alignment: Alignment.bottomCenter,
//                 width: 50,
//                 height: 40,
//                 child: Text("Gender: ")),
//             Container(
//               alignment: Alignment.bottomCenter,
//               height: 68,
//               width: 100,
//               child: DropdownButton(
//                   hint: Text("Gender"),
//                   value: widget.gender,
//                   items: [
//                     DropdownMenuItem(child: Text("Laki-laki"), value: 0),
//                     DropdownMenuItem(child: Text("Wanita"), value: 1),
//                   ],
//                   onChanged: (value) {
//                     setState(() {
//                       widget.gender = value!;
//                     });
//                   }),
//             ),
//           ])
//         ]));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 1000,
//       alignment: Alignment.topLeft,
//       padding: EdgeInsets.only(top: 20),
//       // child: Row(
//       //   children: [dataPengunjung()],
//       // )
//       child: Table(
//         children: [
//           TableRow(children: [
//             Container(
//               decoration: BoxDecoration(border: Border.all(width: 1)),
//               width: 500,
//               margin: EdgeInsets.only(right: 5),
//               padding: EdgeInsets.all(10),
//               child: dataPengunjung(),
//             ),
//             Container(
//                 decoration: BoxDecoration(border: Border.all(width: 1)),
//                 width: 500,
//                 margin: EdgeInsets.only(left: 5),
//                 padding: EdgeInsets.all(10),
//                 child: dataPenjualan()),

//             // child: ),
//           ])
//         ],
//       ),
//     );
//   }
// }