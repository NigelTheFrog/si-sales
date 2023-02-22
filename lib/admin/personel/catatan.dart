// Widget listPersonel(data) {
//     List<Person> person2 = [];
//     Map json = jsonDecode(data);
//     for (var pers in json['data']) {
//       Person person = Person.fromJson(pers);
//       person2.add(person);
//     }
//     return ListView.builder(
//         itemCount: 1,
//         itemBuilder: (BuildContext ctxt, int index) {
//           return Container(
//               height: MediaQuery.of(ctxt).size.height,
//               width: 800,
//               child: GridView.count(
//                   crossAxisCount: kIsWeb
//                       ? window.screen!.width! >= 870
//                           ? 2
//                           : 1
//                       : 1,
//                   crossAxisSpacing: 4.0,
//                   mainAxisSpacing: 8.0,
//                   children: [
//                     Container(
//                         width: 250,
                        
//                         child: Card(
//                             child: Row(children: [
//                           Container(
//                               width: 100,
//                               height: 200,
//                               alignment: Alignment.topCenter,
//                               child: Image.memory(
//                                 base64Decode(person2[index].avatar),
//                               )),
//                           Container(
//                               padding: EdgeInsets.all(5),
//                               width: 270,
//                               child: Column(
//                                 children: [
//                                   Align(
//                                       alignment: Alignment.centerLeft,
//                                       child: Text(
//                                         person2[index].nama_depan,
//                                         //"${person2[idx].nama_depan} ${person2[idx].nama_belakang} ${person2[idx].nama_cabang}",
//                                         style: TextStyle(
//                                             fontWeight: FontWeight.bold),
//                                       )),
//                                   Align(
//                                       alignment: Alignment.topLeft,
//                                       child: Text(person2[index].username)),
//                                   Row(children: [
//                                     Icon(Icons.mail),
//                                     Text(person2[index].email,
//                                         textAlign: TextAlign.left)
//                                   ]),
//                                   Row(children: [
//                                     Icon(Icons.phone),
//                                     Text(person2[index].no_telp,
//                                         textAlign: TextAlign.left)
//                                   ]),
//                                   Align(
//                                       alignment: Alignment.bottomLeft,
//                                       child: Text(
//                                           "Group : " + person2[index].nama_grup,
//                                           textAlign: TextAlign.left))
//                                 ],
//                               ))
//                         ])))
//                   ]));
//         });
//   }